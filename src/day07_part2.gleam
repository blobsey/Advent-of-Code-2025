import gleam/bool
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/result
import gleam/set
import gleam/string
import simplifile

type TimelineCount =
  Int

type Coord {
  Coord(i: Int, j: Int)
}

type State {
  State(
    splitters: set.Set(Coord),
    active_beams: dict.Dict(Coord, TimelineCount),
    max_timelines: TimelineCount,
    max_i: Int,
    max_j: Int,
  )
}

fn is_in_bound(beam: Coord, max_i: Int, max_j: Int) {
  beam.i >= 0 && beam.i < max_i && beam.j >= 0 && beam.j < max_j
}

fn process(state: State) -> State {
  // Base case: if no more active beams we are done
  use <- bool.guard(dict.is_empty(state.active_beams), state)

  let empty_state = State(..state, active_beams: dict.new())

  state.active_beams
  |> dict.fold(from: empty_state, with: fn(prev_state, coord, timeline_count) {
    let stepped_coord = Coord(..coord, i: coord.i + 1)
    case set.contains(in: state.splitters, this: stepped_coord) {
      True -> {
        let left = Coord(..stepped_coord, j: stepped_coord.j - 1)
        let right = Coord(..stepped_coord, j: stepped_coord.j + 1)
        let in_bounds =
          [left, right]
          |> list.filter(is_in_bound(_, prev_state.max_i, prev_state.max_j))
        let exited = { 2 - list.length(in_bounds) } * timeline_count

        let new_beams =
          in_bounds
          |> list.fold(prev_state.active_beams, fn(beams, coord) {
            dict.upsert(in: beams, update: coord, with: fn(existing) {
              case existing {
                option.Some(existing_timelines) ->
                  existing_timelines + timeline_count
                option.None -> timeline_count
              }
            })
          })

        State(
          ..prev_state,
          active_beams: new_beams,
          max_timelines: prev_state.max_timelines + exited,
        )
      }
      False ->
        case is_in_bound(stepped_coord, prev_state.max_i, prev_state.max_j) {
          True ->
            State(
              ..prev_state,
              active_beams: dict.upsert(
                prev_state.active_beams,
                stepped_coord,
                fn(existing) {
                  case existing {
                    option.Some(existing_timelines) ->
                      existing_timelines + timeline_count
                    option.None -> timeline_count
                  }
                },
              ),
            )
          False ->
            // Beam exits bottom
            State(
              ..prev_state,
              max_timelines: prev_state.max_timelines + timeline_count,
            )
        }
    }
  })
  |> process
}

fn part_two(content: String) -> Int {
  let rows = content |> string.trim |> string.split("\n")

  let initial_state =
    State(
      splitters: set.new(),
      active_beams: dict.new(),
      max_timelines: 0,
      max_i: list.length(rows),
      max_j: rows
        |> list.map(string.length)
        |> list.reduce(int.max)
        |> result.unwrap(0),
    )

  let final_state =
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
              active_beams: dict.insert(prev_state.active_beams, Coord(i, j), 1),
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
    // Processing
    |> process

  final_state.max_timelines
}

pub fn main() {
  let assert Ok(content) = simplifile.read("input/day07.txt")
  io.println("Part 2: " <> int.to_string(part_two(content)))
  Nil
}
