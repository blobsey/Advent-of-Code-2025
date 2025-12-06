import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/string
import simplifile

type Range {
  Range(lower: Int, upper: Int)
}

fn part_one(ranges: List(Range), ids: List(Int)) -> Int {
  ids
  |> list.count(fn(id) {
    list.any(ranges, fn(range) { id >= range.lower && id <= range.upper })
  })
}

fn part_two(ranges: List(Range)) -> Int {
  ranges
  // Sort by lower then upper
  |> list.sort(fn(a, b) {
    case int.compare(a.lower, b.lower) {
      order.Eq -> int.compare(a.upper, b.upper)
      other -> other
    }
  })
  |> list.fold_right(from: [], with: fn(accumulator: List(Range), range: Range) {
    case accumulator {
      [] -> [range]
      [prev_range, ..rest] -> {
        case prev_range.lower <= range.upper {
          True -> [
            // Merge overlapping intervals
            Range(
              lower: range.lower,
              upper: int.max(range.upper, prev_range.upper),
            ),
            ..rest
          ]
          False -> [range, prev_range, ..rest]
        }
      }
    }
  })
  |> list.map(fn(range) { 1 + range.upper - range.lower })
  |> int.sum
}

pub fn main() {
  let assert Ok(content) = simplifile.read("input/day05.txt")
  let assert [ranges_str, ids_str] = string.split(content, on: "\n\n")

  let ranges =
    ranges_str
    |> string.trim
    |> string.split(on: "\n")
    |> list.map(fn(range_str) {
      let assert Ok([lower, upper]) =
        range_str
        |> string.split("-")
        |> list.try_map(int.parse)
      Range(lower: lower, upper: upper)
    })

  let assert Ok(ids) =
    ids_str
    |> string.trim
    |> string.split(on: "\n")
    |> list.try_map(int.parse)

  io.println("Part 1: " <> int.to_string(part_one(ranges, ids)))
  io.println("Part 2: " <> int.to_string(part_two(ranges)))
}
