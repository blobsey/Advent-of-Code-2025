import gleam/int
import gleam/io
import gleam/list
import gleam/set.{type Set}
import gleam/string
import simplifile

fn part_one(rolls: Set(#(Int, Int))) -> Int {
  rolls
  |> set.filter(fn(roll: #(Int, Int)) {
    let adjacencies = [
      #(roll.0 - 1, roll.1 - 1),
      #(roll.0 - 1, roll.1),
      #(roll.0 - 1, roll.1 + 1),
      #(roll.0, roll.1 - 1),
      #(roll.0, roll.1 + 1),
      #(roll.0 + 1, roll.1 - 1),
      #(roll.0 + 1, roll.1),
      #(roll.0 + 1, roll.1 + 1),
    ]
    list.count(adjacencies, fn(adj) { set.contains(rolls, adj) }) < 4
  })
  |> set.size
}

fn part_two(rolls: Set(#(Int, Int))) -> Int {
  do_part_two(rolls: rolls, removed_count: 0)
}

fn do_part_two(
  rolls rolls: Set(#(Int, Int)),
  removed_count removed_count: Int,
) -> Int {
  let rolls_to_remove =
    rolls
    |> set.filter(fn(roll: #(Int, Int)) {
      let adjacencies = [
        #(roll.0 - 1, roll.1 - 1),
        #(roll.0 - 1, roll.1),
        #(roll.0 - 1, roll.1 + 1),
        #(roll.0, roll.1 - 1),
        #(roll.0, roll.1 + 1),
        #(roll.0 + 1, roll.1 - 1),
        #(roll.0 + 1, roll.1),
        #(roll.0 + 1, roll.1 + 1),
      ]
      list.count(adjacencies, fn(adj) { set.contains(rolls, adj) }) < 4
    })

  case rolls_to_remove |> set.is_empty {
    True -> removed_count
    False ->
      do_part_two(
        rolls: set.difference(rolls, rolls_to_remove),
        removed_count: removed_count + set.size(rolls_to_remove),
      )
  }
}

pub fn main() {
  let assert Ok(content) = simplifile.read("input/day04.txt")
  let rolls: Set(#(Int, Int)) =
    content
    |> string.trim
    |> string.split(on: "\n")
    |> list.index_fold(set.new(), fn(acc: Set(#(Int, Int)), line, i) {
      line
      |> string.to_graphemes
      |> list.index_fold(acc, fn(acc: Set(#(Int, Int)), char, j) {
        case char {
          "." -> acc
          "@" -> acc |> set.insert(#(i, j))
          _ -> panic as { "What the heck?: " <> string.inspect(char) }
        }
      })
    })

  io.println("Part 1: " <> int.to_string(part_one(rolls)))
  io.println("Part 2: " <> int.to_string(part_two(rolls)))
}
