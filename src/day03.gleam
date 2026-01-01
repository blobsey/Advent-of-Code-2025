import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

fn part_two(battery_banks: List(List(Int))) -> Int {
  let best_joltages =
    battery_banks
    |> list.map(fn(joltages) {
      joltages
      |> list.index_fold([], fn(acc, joltage, i) {
        let higher_joltages_right =
          joltages
          |> list.drop(i + 1)
          |> list.filter(fn(other_joltage) { other_joltage > joltage })
      })
    })

  todo
}

fn part_one(battery_banks: List(List(Int))) -> Int {
  battery_banks
  |> list.map(fn(joltages) {
    joltages
    |> list.index_fold(0, fn(acc, joltage_a, i) {
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
