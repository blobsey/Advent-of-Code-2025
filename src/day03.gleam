import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

fn count_digits(n: Int) -> Int {
  case n >= 10 {
    True -> 1 + count_digits(n / 10)
    False -> 1
  }
}

/// Get power of 10, i.e. pow10(0) = 1, pow10(1) = 10, pow10(2) = 100, etc.
fn pow10(exp: Int) -> Int {
  case exp {
    0 -> 1
    exp if exp < 0 -> panic as "Negative exponents not supported"
    _ -> 10 * pow10(exp - 1)
  }
}

/// Pop out a joltage in the middle, append a new one at the end
/// Ex. pop_append_joltage
fn pop_append_joltage(total_joltage: Int, index: Int, to_append: Int) {
  let num_digits = count_digits(total_joltage)
  let shift = pow10(num_digits - index - 1)
  let left = total_joltage / {shift * 10}
  let right = total_joltage % shift

  {left * shift * 10} + {right * 10} + to_append
}

fn part_two(battery_banks: List(List(Int))) -> Int {
  battery_banks
  |> list.map(fn(joltages) {
    joltages
    |> list.fold(0, fn(acc, joltage) {
      use <- bool.guard(
        count_digits(acc) < 12,
        acc * 10 + joltage,
      )

      let possible_joltages = 
        list.range(0, 11)
        |> list.map(pop_append_joltage(acc, _, joltage))
      
      let assert Ok(max) = [acc, ..possible_joltages] |> list.reduce(int.max)
      max
    })
  })
  |> int.sum
}

fn part_one(battery_banks: List(List(Int))) -> Int {
  battery_banks
  |> list.map(fn(joltages) {
    joltages
    |> list.index_fold(0, fn(acc, joltage_a, i) {
      // Find max joltage, assuming we use joltage_a as left
      use <- bool.guard(i == list.length(joltages) - 1, acc)
      let assert Ok(joltage_b) =
        joltages |> list.drop(i + 1) |> list.max(int.compare)

      let calculated_joltage = joltage_a * 10 + joltage_b
      int.max(calculated_joltage, acc)
    })
  })
  |> int.sum
}

pub fn main() {
  let assert Ok(content) = simplifile.read("input/day03.txt")

  let assert Ok(battery_banks) =
    content
    |> string.trim
    |> string.split("\n")
    |> list.try_map(fn(battery_bank) {
      battery_bank
      |> string.to_graphemes
      |> list.try_map(int.parse)
    })

  io.println("Part 1: " <> int.to_string(part_one(battery_banks)))
  io.println("Part 2: " <> int.to_string(part_two(battery_banks)))
}
