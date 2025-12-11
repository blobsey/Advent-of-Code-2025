import gleam/io
import gleam/set
import gleam/int
import gleam/list
import gleam/option
import gleam/regexp
import gleam/string
import simplifile

type Machine {
  Machine(
    lights_target: Int,
    buttons: List(Int),
    joltages: List(Int),
  )
}

fn part_one_process(machine: Machine, current_states: set.Set(Int), visited: set.Set(Int)) -> Int {
  case set.contains(current_states, machine.lights_target) {
    // Found solution
    True -> 0
    False -> {
      let next_states = 
        current_states 
        |> set.to_list
        |> list.flat_map(fn (state) {
          machine.buttons
          // XOR each button with state "presses" it
          |> list.map(int.bitwise_exclusive_or(_, state))
        })
        |> set.from_list
        |> set.difference(visited)

      let new_visited = set.union(next_states, visited)

      1 + part_one_process(machine, next_states, new_visited)
    }
  }
}

fn part_one(machines: List(Machine)) {
  machines
  |> list.map(part_one_process(_, set.insert(set.new(), 0), set.new()))
  |> int.sum
}

pub fn main() {
  let assert Ok(content) = simplifile.read("input/day10.txt")

  let assert Ok(lights_regex) = regexp.from_string("\\[([#.]+)\\]")
  let assert Ok(buttons_regex) = regexp.from_string("\\(([^)]+)\\)")
  let assert Ok(joltages_regex) = regexp.from_string("\\{([^}]+)\\}")

  let machines =
    content
    |> string.trim
    |> string.split("\n")
    |> list.map(fn(line) {
      let lights_matches = regexp.scan(lights_regex, line)
      let button_matches = regexp.scan(buttons_regex, line)
      let joltages_matches = regexp.scan(joltages_regex, line)

      let assert [regexp.Match(submatches: [option.Some(lights_str)], ..)] =
        lights_matches

      let assert Ok(lights_target) =
        lights_str
        |> string.to_graphemes
        |> list.map(fn(light) {
          case light {
            "." -> "0"
            "#" -> "1"
            _ -> panic as { "Unknown light symbol: " <> light }
          }
        })
        |> string.join("")
        |> int.base_parse(2)

      let buttons = 
        button_matches
        |> list.map(fn (match) {
          let assert regexp.Match(submatches: [option.Some(button_str)], ..) = match

          let assert Ok(nums) =
            button_str
            |> string.split(",")
            |> list.try_map(int.parse)
            
          let nums_set = nums |> set.from_list
          
          let assert Ok(bits) = 
            list.range(0, string.length(lights_str) - 1)
            |> list.map(fn (i) {
              case set.contains(in: nums_set, this: i) {
                True -> "1"
                False -> "0"
              }
            })
            |> string.join("")
            |> int.base_parse(2)

          bits
        })
        
        Machine(lights_target: lights_target, buttons: buttons, joltages: list.new())
    })

  io.println("Part 1 Answer: " <> int.to_string(part_one(machines)))
}
