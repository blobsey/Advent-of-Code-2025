import gleam/dict
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import simplifile

type JunctionBox {
  JunctionBox(x: Int, y: Int, z: Int)
}

/// For tracking state through part two
type ConnectionStep {
  ConnectionStep(
    graph: dict.Dict(JunctionBox, JunctionBox),
    last_pair: option.Option(#(JunctionBox, JunctionBox)),
  )
}

fn distance(pair: #(JunctionBox, JunctionBox)) -> Float {
  let dx = int.to_float({ pair.0 }.x - { pair.1 }.x)
  let dy = int.to_float({ pair.0 }.y - { pair.1 }.y)
  let dz = int.to_float({ pair.0 }.z - { pair.1 }.z)
  let assert Ok(dist) = float.square_root(dx *. dx +. dy *. dy +. dz *. dz)
  dist
}

fn find(junction_box: JunctionBox, graph: dict.Dict(JunctionBox, JunctionBox)) {
  case dict.get(graph, junction_box) {
    Error(Nil) -> junction_box
    Ok(parent) if parent == junction_box -> junction_box
    Ok(parent) -> find(parent, graph)
  }
}

fn part_two(junction_boxes: List(JunctionBox)) {
  let connections =
    junction_boxes
    |> list.combination_pairs
    |> list.sort(by: fn(pair1, pair2) {
      float.compare(distance(pair1), distance(pair2))
    })

  let initial_state = ConnectionStep(graph: dict.new(), last_pair: option.None)

  let end_state =
    connections
    |> list.fold_until(from: initial_state, with: fn(state, pair) {
      let root_a = find(pair.0, state.graph)
      let root_b = find(pair.1, state.graph)

      let graph = case root_a == root_b {
        // Already in same group
        True -> state.graph
        // Not same group, connect
        False -> dict.insert(state.graph, root_a, root_b)
      }

      let roots =
        junction_boxes
        |> list.fold(dict.new(), fn(counts, next_box) {
          let root = find(next_box, graph)
          dict.upsert(in: counts, update: root, with: fn(existing) {
            case existing {
              option.Some(n) -> n + 1
              option.None -> 1
            }
          })
        })
        |> dict.values

      let next_state =
        ConnectionStep(graph: graph, last_pair: option.Some(pair))

      case
        list.all(roots, fn(root) { root == result.unwrap(list.first(roots), 0) })
      {
        True -> list.Stop(next_state)
        False -> list.Continue(next_state)
      }
    })

  case end_state.last_pair {
    option.None -> panic as "WHAR"
    option.Some(last_pair) -> { last_pair.0 }.x * { last_pair.1 }.x
  }
}

fn part_one(junction_boxes: List(JunctionBox)) {
  // Connect top 10 (or 1000 for real input)
  let connections =
    junction_boxes
    |> list.combination_pairs
    |> list.sort(by: fn(pair1, pair2) {
      float.compare(distance(pair1), distance(pair2))
    })
    |> list.take(up_to: 1000)

  // Make into groups
  let circuits =
    connections
    |> list.fold(from: dict.new(), with: fn(acc, next_pair) {
      let root_a = find(next_pair.0, acc)
      let root_b = find(next_pair.1, acc)

      case root_a == root_b {
        // Already in same group
        True -> acc
        // Not same group, connect
        False -> dict.insert(acc, root_a, root_b)
      }
    })

  junction_boxes
  |> list.fold(dict.new(), fn(counts, next_box) {
    let root = find(next_box, circuits)
    dict.upsert(in: counts, update: root, with: fn(existing) {
      case existing {
        option.Some(n) -> n + 1
        option.None -> 1
      }
    })
  })
  |> dict.values
  |> list.sort(int.compare)
  |> list.reverse
  |> list.take(3)
  |> int.product
}

pub fn main() {
  let assert Ok(content) = simplifile.read("input/day08.txt")
  let junction_boxes =
    content
    |> string.trim
    |> string.split("\n")
    |> list.map(fn(coords_str) {
      case string.split(coords_str, ",") {
        [x_str, y_str, z_str] -> {
          let assert Ok(x) = int.parse(x_str)
          let assert Ok(y) = int.parse(y_str)
          let assert Ok(z) = int.parse(z_str)
          JunctionBox(x, y, z)
        }
        _ -> panic as { "What the heck?: " <> coords_str }
      }
    })

  io.println("Part 1: " <> int.to_string(part_one(junction_boxes)))
  io.println("Part 2: " <> int.to_string(part_two(junction_boxes)))
}
