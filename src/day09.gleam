import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

/// Check if any line intersects with the bounding box created by corners
fn is_valid(
  tiles: List(#(Int, Int)),
  box_corners: #(#(Int, Int), #(Int, Int)),
) -> Bool {
  let assert Ok(first_tile) = list.first(tiles)
  let tiles_circular = list.append(tiles, [first_tile])
  let x_lower = int.min(box_corners.0.0, box_corners.1.0)
  let x_upper = int.max(box_corners.0.0, box_corners.1.0)
  let y_lower = int.min(box_corners.0.1, box_corners.1.1)
  let y_upper = int.max(box_corners.0.1, box_corners.1.1)

  tiles_circular
  |> list.window_by_2
  |> list.all(fn(tile_pair) {
    let #(tile_one, tile_two) = tile_pair
    case tile_one.0 == tile_two.0 {
      // X values are same, vertical line
      True -> {
        let x = tile_one.0
        let y_to_check_lower = int.min(tile_one.1, tile_two.1)
        let y_to_check_upper = int.max(tile_one.1, tile_two.1)

        x <= x_lower
        || x >= x_upper
        || y_to_check_upper <= y_lower
        || y_to_check_lower >= y_upper
      }
      // If not vertical, then horizontal
      False -> {
        let y = tile_one.1
        let x_to_check_lower = int.min(tile_one.0, tile_two.0)
        let x_to_check_upper = int.max(tile_one.0, tile_two.0)

        y <= y_lower
        || y >= y_upper
        || x_to_check_upper <= x_lower
        || x_to_check_lower >= x_upper
      }
    }
  })
}

fn part_two(tiles: List(#(Int, Int))) -> Int {
  tiles
  |> list.combination_pairs
  |> list.filter_map(fn(tile_pair) {
    case is_valid(tiles, tile_pair) {
      True -> {
        let area =
          { int.absolute_value(tile_pair.0.0 - tile_pair.1.0) + 1 }
          * { int.absolute_value(tile_pair.0.1 - tile_pair.1.1) + 1 }
        Ok(area)
      }
      False -> Error(Nil)
    }
  })
  |> list.max(int.compare)
  |> result.unwrap(0)
}

fn part_one(tiles: List(#(Int, Int))) -> Int {
  tiles
  |> list.combination_pairs
  |> list.map(fn(tile_pair) {
    { int.absolute_value(tile_pair.0.0 - tile_pair.1.0) + 1 }
    * { int.absolute_value(tile_pair.0.1 - tile_pair.1.1) + 1 }
  })
  |> list.max(int.compare)
  |> result.unwrap(0)
}

pub fn main() {
  let assert Ok(content) = simplifile.read("input/day09.txt")
  let tiles: List(#(Int, Int)) =
    content
    |> string.trim
    |> string.split("\n")
    |> list.map(fn(coords_str) {
      let assert [x_str, y_str] = string.split(coords_str, on: ",")
      let assert Ok(x) = int.parse(x_str)
      let assert Ok(y) = int.parse(y_str)
      #(x, y)
    })

  io.println("Part 1 Answer: " <> int.to_string(part_one(tiles)))
  io.println("Part 2 Answer: " <> int.to_string(part_two(tiles)))
}
