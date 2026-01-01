import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile

type Shape =
  Set(#(Int, Int))

type RegionChallenge {
  RegionChallenge(width: Int, height: Int, shape_counts: Dict(Int, Int))
}

fn part_one(shapes: Dict(Int, Shape), regions: Set(RegionChallenge)) -> Int {
  let trivially_possible =
    regions
    |> set.filter(fn(region) {
      let area = { region.width / 3 * 3 } * { region.height / 3 * 3 }
      let total_shape_area_upper_bound =
        region.shape_counts
        |> dict.values
        |> list.map(fn(shape_count) { 3 * 3 * shape_count })
        |> int.sum

      total_shape_area_upper_bound <= area
    })

  let trivially_impossible =
    regions
    |> set.filter(fn(region) {
      let area = { region.width / 3 * 3 } * { region.height / 3 * 3 }

      // Check if possible at all from dumb area check
      let total_shape_area_lower_bound =
        region.shape_counts
        |> dict.fold(0, fn(area_acc, shape_id, shape_count) {
          let assert Ok(shape) = dict.get(shapes, shape_id)
          // Area is number of points in the shape
          area_acc + { set.size(shape) * shape_count }
        })

      total_shape_area_lower_bound >= area
    })

  let hard_regions =
    regions
    |> set.difference(trivially_possible)
    |> set.difference(trivially_impossible)

  use <- bool.guard(set.is_empty(hard_regions), set.size(trivially_possible))

  // Actually calculate hard_regions
  panic as "Uh oh, NP Hard!"
}

pub fn main() {
  let assert Ok(content) = simplifile.read("input/day12.txt")

  let chunks =
    content
    |> string.split("\n\n")
    |> list.filter_map(fn(chunk) {
      case string.split(chunk, "\n") {
        [_id_row, row1, row2, row3, ..] -> Ok([row1, row2, row3])
        _ -> Error(Nil)
      }
    })

  let shapes: Dict(Int, Shape) =
    chunks
    |> list.index_fold(dict.new(), fn(shapes_acc, chunk, shape_id) {
      let shape: Shape =
        chunk
        |> list.index_fold(set.new(), fn(acc, row_str, i) {
          row_str
          |> string.to_graphemes
          |> list.index_fold(acc, fn(acc, char, j) {
            case char {
              "#" -> set.insert(acc, #(i, j))
              _ -> acc
            }
          })
        })

      dict.insert(into: shapes_acc, for: shape_id, insert: shape)
    })

  let regions: Set(RegionChallenge) =
    content
    |> string.split("\n")
    |> list.filter_map(fn(chunk) {
      use #(dimensions, counts) <- result.try(string.split_once(chunk, ": "))
      use #(width_str, height_str) <- result.try(string.split_once(
        dimensions,
        "x",
      ))
      use width <- result.try(int.parse(width_str))
      use height <- result.try(int.parse(height_str))

      let shape_counts =
        counts
        |> string.trim
        |> string.split(" ")
        |> list.index_fold(dict.new(), fn(acc, piece_count_str, piece_id) {
          let assert Ok(piece_count) = int.parse(piece_count_str)
          dict.insert(acc, piece_id, piece_count)
        })

      Ok(RegionChallenge(width, height, shape_counts))
    })
    |> set.from_list

  io.println("Part 1: " <> int.to_string(part_one(shapes, regions)))
}
