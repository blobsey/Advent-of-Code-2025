import gleam/dict
import gleam/io
import gleam/list
import shellout

import day01
import day02
import day03
import day04
import day05
import day06
import day07_part1
import day07_part2
import day08
import day09
import day10_part1
import day10_part2
import day11
import day12

fn header(text: String) {
  shellout.style(
    "\n═══ " <> text <> " ═══",
    with: shellout.color(["cyan"]),
    custom: [],
  )
  |> io.println
}

pub fn main() {
  shellout.style(
    "🎄 Advent of Code 2025 🎄",
    with: shellout.display(["bold"])
      |> dict.merge(shellout.color(["green"])),
    custom: [],
  )
  |> io.println

  let days = [
    #("Day 01", [day01.main]),
    #("Day 02", [day02.main]),
    #("Day 03", [day03.main]),
    #("Day 04", [day04.main]),
    #("Day 05", [day05.main]),
    #("Day 06", [day06.main]),
    #("Day 07", [day07_part1.main, day07_part2.main]),
    #("Day 08", [day08.main]),
    #("Day 09", [day09.main]),
    #("Day 10", [day10_part1.main, day10_part2.main]),
    #("Day 11", [day11.main]),
    #("Day 12", [day12.main]),
  ]

  list.each(days, fn(day) {
    let #(name, funcs) = day
    header(name)
    list.each(funcs, fn(f) { f() })
  })
}