import gleam/bool
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/set
import gleam/string
import simplifile

type CacheKey {
  CacheKey(device: String, has_fft: Bool, has_dac: Bool)
}

fn part_two_process(
  device_to_outputs: dict.Dict(String, List(String)),
  cache: dict.Dict(CacheKey, Int),
  input: CacheKey,
) -> #(dict.Dict(CacheKey, Int), Int) {
  case dict.get(cache, input) {
    Ok(paths) -> #(cache, paths)
    Error(_) -> {
      let assert Ok(outputs) = dict.get(device_to_outputs, input.device)

      let #(new_cache, paths) =
        outputs
        |> list.fold(#(cache, 0), fn(acc, output) {
          let #(cache, paths) = acc
          let key =
            CacheKey(
              device: output,
              has_fft: input.has_fft || input.device == "fft",
              has_dac: input.has_dac || input.device == "dac",
            )

          let #(new_cache, new_paths) =
            part_two_process(device_to_outputs, cache, key)

          #(new_cache, paths + new_paths)
        })

      #(dict.insert(new_cache, input, paths), paths)
    }
  }
}

fn part_two(device_to_outputs: dict.Dict(String, List(String))) {
  let base_cache =
    dict.new()
    |> dict.insert(CacheKey(device: "out", has_fft: False, has_dac: False), 0)
    |> dict.insert(CacheKey(device: "out", has_fft: True, has_dac: False), 0)
    |> dict.insert(CacheKey(device: "out", has_fft: False, has_dac: True), 0)
    |> dict.insert(CacheKey(device: "out", has_fft: True, has_dac: True), 1)

  part_two_process(
    device_to_outputs,
    base_cache,
    CacheKey(device: "svr", has_fft: False, has_dac: False),
  )
}

fn part_one_process(
  device_to_outputs: dict.Dict(String, List(String)),
  device: String,
  seen: set.Set(String),
) -> Int {
  use <- bool.guard(set.contains(seen, device), 0)

  case device == "out" {
    True -> 1
    False -> {
      let assert Ok(outputs) = dict.get(device_to_outputs, device)
      outputs
      |> list.map(fn(output) {
        part_one_process(device_to_outputs, output, set.insert(seen, device))
      })
      |> int.sum
    }
  }
}

fn part_one(device_to_outputs: dict.Dict(String, List(String))) {
  part_one_process(device_to_outputs, "you", set.new())
}

pub fn main() {
  let assert Ok(content) = simplifile.read("input/day11.txt")

  let device_to_outputs: dict.Dict(String, List(String)) =
    content
    |> string.trim
    |> string.split("\n")
    |> list.map(fn(line) {
      let assert [name, outputs_str] = string.split(line, ": ")
      let outputs = string.split(outputs_str, " ")
      #(name, outputs)
    })
    |> dict.from_list

  io.println("Part 1: " <> int.to_string(part_one(device_to_outputs)))
  io.println("Part 2: " <> int.to_string(part_two(device_to_outputs).1))
}
