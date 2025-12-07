import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import simplifile

type Coord {
  Coord(i: Int, j: Int)
}

type State {
  State(
    splitters: set.Set(Coord),
    active_beams: set.Set(Coord),
    splits: Int,
    max_i: Int,
    max_j: Int,
  )
}

fn is_in_bound(beam: Coord, max_i: Int, max_j: Int) {
  beam.i >= 0 && beam.i < max_i && beam.j >= 0 && beam.j < max_j
}

fn process(state: State) -> State {
  // Base case: if no more active beams we are done
  use <- bool.guard(set.is_empty(state.active_beams), state)

  let empty_state = State(..state, active_beams: set.new())

  state.active_beams
  |> set.fold(from: empty_state, with: fn(prev_state, beam) {
    let stepped_beam = Coord(beam.i + 1, beam.j)
    case set.contains(in: state.splitters, this: stepped_beam) {
      True ->
        State(
          ..prev_state,
          splits: prev_state.splits + 1,
          active_beams: set.union(
              prev_state.active_beams,
              set.from_list([
                Coord(stepped_beam.i, stepped_beam.j - 1),
                Coord(stepped_beam.i, stepped_beam.j + 1),
              ]),
            )
            |> set.filter(is_in_bound(_, prev_state.max_i, prev_state.max_j)),
        )
      False ->
        State(
          ..prev_state,
          active_beams: set.insert(prev_state.active_beams, stepped_beam)
            |> set.filter(is_in_bound(_, prev_state.max_i, prev_state.max_j)),
        )
    }
  })
  |> process
}

fn part_one(content: String) {
  let rows = content |> string.trim |> string.split("\n")

  let initial_state =
    State(
      splitters: set.new(),
      active_beams: set.new(),
      splits: 0,
      max_i: list.length(rows),
      max_j: rows
        |> list.map(string.length)
        |> list.reduce(int.max)
        |> result.unwrap(0),
    )

  content
  |> string.trim
  |> string.split("\n")
  // Parsing
  |> list.index_fold(from: initial_state, with: fn(prev_state, row, i) {
    row
    |> string.to_graphemes
    |> list.index_fold(from: prev_state, with: fn(prev_state, char, j) {
      case char {
        "." -> prev_state
        "S" ->
          State(
            ..prev_state,
            active_beams: set.insert(prev_state.active_beams, Coord(i, j)),
          )
        "^" ->
          State(
            ..prev_state,
            splitters: set.insert(prev_state.splitters, Coord(i, j)),
          )
        _ -> panic as "What the hekc?!"
      }
    })
  })
  |> process
}

pub fn main() {
  let assert Ok(content) = simplifile.read("input/day07.txt")
  io.println("Part 1: " <> int.to_string(part_one(content).splits))
  Nil
}
