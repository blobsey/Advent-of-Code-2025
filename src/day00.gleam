import gleam/io
import simplifile
import gleam/erlang/application

pub fn main() {
  let assert Ok(priv_dir) = application.priv_directory("advent_of_code_2025")
  let assert Ok(content) = simplifile.read(priv_dir <> "/input/day00.txt")
  io.println(content)
}
