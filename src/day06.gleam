import gleam/int
import gleam/io
import gleam/list
import gleam/regexp
import gleam/result
import gleam/string
import simplifile

type Operator {
  Add
  Multiply
}

type Equation {
  Equation(operator: Operator, operands: List(Int))
}

fn part_one(content: String) {
  let assert Ok(re) = regexp.from_string("\\s+")
  let grid =
    content
    |> string.trim
    |> string.split("\n")
    |> list.map(fn(row) { regexp.split(re, string.trim(row)) })

  let grid_transpose = list.transpose(grid)

  let equations =
    grid_transpose
    |> list.map(fn(row) {
      let #(operand_strs, operator_str_list) =
        row
        |> list.split_while(satisfying: fn(str) { result.is_ok(int.parse(str)) })

      let operator = case list.first(operator_str_list) {
        Ok("+") -> Add
        Ok("*") -> Multiply
        _ -> panic as "Invalid Operator?!"
      }

      let assert Ok(operands) = operand_strs |> list.try_map(int.parse)

      Equation(operator: operator, operands: operands)
    })

  equations
  |> list.map(fn(equation) {
    case equation.operator {
      Add -> int.sum(equation.operands)
      Multiply -> int.product(equation.operands)
    }
  })
  |> int.sum
}

fn part_two(content: String) {
  let assert Ok(re) = regexp.from_string("\\s+")

  // Isolate operator line from number lines
  let assert #(number_lines, [operator_line]) =
    content
    |> string.split("\n")
    |> list.filter(fn(line) { line != "" })
    |> list.split_while(satisfying: fn(line) {
      line
      |> string.trim
      |> regexp.split(re, _)
      |> list.all(fn(str) { str |> int.parse |> result.is_ok })
    })

  let operand_lists =
    number_lines
    |> list.map(string.to_graphemes)
    // Cols become lines
    |> list.transpose
    // Chunk for lines without any chars
    |> list.chunk(by: list.any(_, fn(char) { char != " " }))
    // Filter out blank lines; after chunking they look like ["", "", "", ...]
    |> list.filter(fn(chunk) {
      chunk |> list.flatten |> list.any(fn(c) { c != " " })
    })
    |> list.map(fn(chunk) {
      // Parse number out of raw chars
      list.map(chunk, fn(chars) {
        list.fold(chars, from: 0, with: fn(acc, char) {
          case int.parse(char) {
            Ok(num) -> acc * 10 + num
            Error(_) -> acc
          }
        })
      })
    })

  let operators =
    operator_line
    |> string.trim
    |> regexp.split(re, _)

  list.map2(operand_lists, operators, fn(operand_list, operator) {
    case operator {
      "*" -> int.product(operand_list)
      "+" -> int.sum(operand_list)
      _ -> panic as "Invalid operator"
    }
  })
  |> int.sum
}

pub fn main() {
  let assert Ok(content) = simplifile.read("input/day06.txt")

  io.println("Part 1: " <> int.to_string(part_one(content)))
  io.println("Part 2: " <> int.to_string(part_two(content)))
}
