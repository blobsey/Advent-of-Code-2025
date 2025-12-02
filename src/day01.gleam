import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

type Direction {
  Left
  Right
}

type Instruction {
  Instruction(direction: Direction, distance: Int)
}

type Dial {
  Dial(pos: Int, zero_count: Int)
}

const dial_max = 100

fn part_one(instructions: List(Instruction)) -> Nil {
  let initial = Dial(pos: 50, zero_count: 0)
  let end =
    list.fold(instructions, from: initial, with: fn(dial, instruction) {
      let delta = case instruction.direction {
        Left -> -instruction.distance
        Right -> instruction.distance
      }
      let assert Ok(new_pos) = int.modulo(dial.pos + delta, dial_max)

      let new_count = case new_pos {
        0 -> dial.zero_count + 1
        _ -> dial.zero_count
      }
      Dial(new_pos, new_count)
    })

  io.println("Part 1 Answer: " <> int.to_string(end.zero_count))
}

fn part_two(instructions: List(Instruction)) -> Nil {
  let initial = Dial(pos: 50, zero_count: 0)
  let end =
    list.fold(instructions, from: initial, with: fn(dial, instruction) {
      let delta = case instruction.direction {
        Left -> -instruction.distance
        Right -> instruction.distance
      }
      let assert Ok(new_pos) = int.modulo(dial.pos + delta, dial_max)

      let passed_zero_count: Int = case instruction.direction {
        // Right: just divide to get number of wraps
        Right -> { dial.pos + instruction.distance } / dial_max
        Left -> {
          // Left: divide, but first convert dial pos to if left was positive
          // also mod by dial_max to pretend that 100 is 0
          let dial_pos_flipped = {dial_max - dial.pos} % dial_max
          {dial_pos_flipped + instruction.distance} / dial_max
        }
      }
      Dial(pos: new_pos, zero_count: dial.zero_count + passed_zero_count)
    })

  io.println("Part 2 Answer: " <> int.to_string(end.zero_count))
}

pub fn main() {
  let assert Ok(content) = simplifile.read("input/day01.txt")
  let lines = content |> string.trim |> string.split(on: "\n")
  let instructions =
    lines
    |> list.map(fn(line) {
      let assert Ok(#(direction_str, distance_str)) = string.pop_grapheme(line)
      let assert Ok(distance) = int.parse(distance_str)
      case direction_str {
        "L" -> Instruction(direction: Left, distance: distance)
        "R" -> Instruction(direction: Right, distance: distance)
        _ -> panic
      }
    })

  part_one(instructions)
  part_two(instructions)
}
