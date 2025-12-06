import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

type Range {
  Range(lower: Int, upper: Int)
}

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

/// Generate invalid ID from a "base number" ex. 123 -> 123123
fn generate_invalid_id(base: Int) {
  base * pow10(count_digits(base)) + base
}

fn get_invalid_ids_part_one(range: Range) -> List(Int) {
  let num_digits_lower = count_digits(range.lower)

  // Get the first "base" (i.e. to generate 123123 the base is 123)
  let first: Int = case int.is_even(num_digits_lower) {
    // Even: Derive starting number from first half of digits
    True -> {
      let maybe_first = range.lower / pow10(num_digits_lower / 2)
      case generate_invalid_id(maybe_first) < range.lower {
        // Suppose range starts at 123999, maybe_first would be 123123 (too low)
        // so the real first is 124
        True -> maybe_first + 1
        False -> maybe_first
      }
    }
    // Odd: Can't split evenly, find the lowest base 1, 10, 100, ... in range
    False -> pow10(num_digits_lower / 2)
  }

  let num_digits_upper = count_digits(range.upper)

  let last: Int = case int.is_even(num_digits_upper) {
    // Even: Derive starting number from first half of digits
    True -> {
      let maybe_last = range.upper / pow10(num_digits_upper / 2)
      case generate_invalid_id(maybe_last) > range.upper {
        // Suppose range ends at 123000, maybe_first would be 123123 (too high)
        // so real starting number is 122
        True -> maybe_last - 1
        False -> maybe_last
      }
    }
    // Odd: Can't split evenly, find the number 99, 9999, 999999 in range
    False -> pow10(num_digits_upper / 2) - 1
  }

  use <- bool.guard(first > last, [])

  list.range(from: first, to: last) |> list.map(generate_invalid_id)
}

fn part_one(ranges: List(Range)) {
  ranges
  |> list.flat_map(get_invalid_ids_part_one)
  |> int.sum
}

// fn get_invalid_ids_part_two(range) {

// }

// fn part_two(ranges: List(Range)) {

// }

pub fn main() {
  let assert Ok(content) = simplifile.read("input/day02.txt")
  let ranges =
    content
    |> string.trim
    |> string.split(on: ",")
    |> list.map(fn(range_str) {
      let assert [lower_str, upper_str] = string.split(range_str, on: "-")
      let assert Ok(lower) = int.parse(lower_str)
      let assert Ok(upper) = int.parse(upper_str)
      Range(lower: lower, upper: upper)
    })

  io.println("Part 1: " <> int.to_string(part_one(ranges)))
}
