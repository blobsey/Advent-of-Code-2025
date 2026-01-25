import gleam/erlang/application
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/regexp
import gleam/string
import shellout
import simplifile

type Machine {
  Machine(buttons: List(List(Int)), joltages: List(Int))
}

const glpsol_tmp_path = "/tmp/bruh.lp"

fn part_two(machines: List(Machine)) -> Int {
  let assert Ok(priv_dir) = application.priv_directory("advent_of_code_2025")

  machines
  |> list.map(fn(machine) {
    let minimize_section =
      "Minimize\n  obj: "
      <> {
        // Num variables = num buttons
        list.range(0, list.length(machine.buttons) - 1)
        |> list.map(fn(i) { "x" <> int.to_string(i) })
        |> string.join(" + ")
      }

    // Num constraints = num joltages
    let constraints_section =
      "Subject To\n"
      <> {
        machine.joltages
        // Construct equation strings, ex. 
        // c0: x4 + x5 = 3
        // c1: x1 + x5 = 5
        |> list.index_map(fn(joltage, joltage_i) {
          let exp: String =
            machine.buttons
            |> list.index_fold([], fn(acc, button, button_i) {
              case button |> list.contains(joltage_i) {
                True -> acc |> list.append(["x" <> int.to_string(button_i)])
                False -> acc
              }
            })
            // Join together strings like ["x0", "x1", "x2", ...]
            |> string.join(" + ")

          "  c"
          <> int.to_string(joltage_i)
          <> ": "
          <> exp
          <> " = "
          <> int.to_string(joltage)
        })
        |> string.join("\n")
      }

    // Ex:
    // General
    //   x0 x1 x2 x3 x4 x5
    let general_section =
      "General\n  "
      <> {
        list.range(0, list.length(machine.buttons) - 1)
        |> list.map(fn(i) { "x" <> int.to_string(i) })
        |> string.join(" ")
      }

    let lp_content =
      [minimize_section, constraints_section, general_section, "End\n"]
      |> string.join("\n\n")

    let _ = simplifile.write(glpsol_tmp_path, lp_content)
    let assert Ok(output) =
      shellout.command(
        run: priv_dir <> "/glpsol",
        with: ["--lp", glpsol_tmp_path, "-o", "/dev/stdout"],
        in: ".",
        opt: [],
      )

    let assert Ok(re) = regexp.from_string("obj = (\\d+)")
    let assert [regexp.Match(submatches: [option.Some(num_str)], ..)] =
      regexp.scan(re, output)
    let assert Ok(result) = int.parse(num_str)

    result
  })
  |> int.sum
}

pub fn main() {
  let assert Ok(priv_dir) = application.priv_directory("advent_of_code_2025")
  let assert Ok(content) = simplifile.read(priv_dir <> "/input/day10.txt")

  let assert Ok(buttons_regex) = regexp.from_string("\\(([^)]+)\\)")
  let assert Ok(joltages_regex) = regexp.from_string("\\{([^}]+)\\}")

  let machines =
    content
    |> string.trim
    |> string.split("\n")
    |> list.map(fn(line) {
      let button_matches = regexp.scan(buttons_regex, line)
      let joltages_matches = regexp.scan(joltages_regex, line)

      let buttons =
        button_matches
        |> list.map(fn(match) {
          let assert regexp.Match(submatches: [option.Some(button_str)], ..) =
            match

          let assert Ok(buttons) =
            button_str
            |> string.split(",")
            |> list.try_map(int.parse)

          buttons
        })

      let assert [regexp.Match(submatches: [option.Some(joltages_str)], ..)] =
        joltages_matches
      let assert Ok(joltages) =
        joltages_str
        |> string.split(",")
        |> list.try_map(int.parse)

      Machine(buttons: buttons, joltages: joltages)
    })

  io.println("Part 2 Answer: " <> int.to_string(part_two(machines)))
}
