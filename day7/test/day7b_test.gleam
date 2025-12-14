import gleeunit

import day7b.{Coordinate, Empty, Splitter, Start}
import gleam/dict
import gleam/list

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn parse_input_test() {
  let input = [".S.", ".^."]
  assert day7b.parse_input(input)
    == dict.from_list([
      #(Coordinate(1, 1), Empty),
      #(Coordinate(1, 2), Start),
      #(Coordinate(1, 3), Empty),
      #(Coordinate(2, 1), Empty),
      #(Coordinate(2, 2), Splitter),
      #(Coordinate(2, 3), Empty),
    ])
}

pub fn add_row_to_grid_test() {
  assert day7b.add_row_to_grid(".S.", 1, 1, dict.new())
    == dict.from_list([
      #(Coordinate(1, 1), Empty),
      #(Coordinate(1, 2), Start),
      #(Coordinate(1, 3), Empty),
    ])

  assert day7b.add_row_to_grid(".^.", 2, 1, dict.new())
    == dict.from_list([
      #(Coordinate(2, 1), Empty),
      #(Coordinate(2, 2), Splitter),
      #(Coordinate(2, 3), Empty),
    ])
}

pub fn run_simulation_test() {
  // This test relies on parse_input working to generate test data
  let input = [".S.", "...", ".^.", "..."]
  input
  |> day7b.parse_input()
  |> list.wrap()
  |> day7b.run_simulation(4, 3, 2)
  |> list.length()
  |> echo
  // too lazy to write the assertion
}

pub fn dict_unique_test() {
  assert dict.from_list([
      #(Coordinate(1, 1), Empty),
      #(Coordinate(1, 2), Start),
      #(Coordinate(1, 3), Empty),
    ])
    == dict.from_list([
      #(Coordinate(1, 1), Empty),
      #(Coordinate(1, 2), Start),
      #(Coordinate(1, 3), Empty),
    ])

  assert [
      dict.from_list([
        #(Coordinate(1, 1), Empty),
        #(Coordinate(1, 2), Start),
        #(Coordinate(1, 3), Empty),
      ]),
      dict.from_list([
        #(Coordinate(1, 1), Empty),
        #(Coordinate(1, 2), Start),
        #(Coordinate(1, 3), Empty),
      ]),
    ]
    |> list.unique()
    |> list.length()
    == 1
}
