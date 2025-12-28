import day11
import gleam/dict
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn parse_input_line_test() {
  assert day11.parse_input_line("aaa: you hhh") == #("aaa", ["you", "hhh"])
  assert day11.parse_input_line("ggg: out") == #("ggg", ["out"])
}

pub fn count_paths_test() {
  assert day11.count_paths(
      dict.from_list([
        #("aaa", ["you", "hhh"]),
        #("bbb", ["ddd", "eee"]),
        #("ccc", ["ddd", "eee", "fff"]),
        #("ddd", ["ggg"]),
        #("eee", ["out"]),
        #("fff", ["out"]),
        #("ggg", ["out"]),
        #("hhh", ["ccc", "fff", "iii"]),
        #("iii", ["out"]),
        #("you", ["bbb", "ccc"]),
      ]),
      "you",
      "out",
    )
    == 5
}
