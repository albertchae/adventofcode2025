import gleeunit

import gleam/dict
import gleam/set

import day4.{Coordinate, Roll, Empty}

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn adjacent_positions_test() {
  assert {
    day4.adjacent_positions(Coordinate(1, 1), 3, 3) ==
      set.from_list([                  Coordinate(1, 2),
                     Coordinate(2, 2), Coordinate(2, 1)])
  }
  assert {
    day4.adjacent_positions(Coordinate(1, 2), 3, 3) ==
      set.from_list([Coordinate(1, 1),                   Coordinate(1, 3),
                     Coordinate(2, 1), Coordinate(2, 2), Coordinate(2, 3)])
  }
  assert {
    day4.adjacent_positions(Coordinate(1, 3), 3, 3) ==
      set.from_list([Coordinate(1, 2),
                     Coordinate(2, 2), Coordinate(2, 3)])
  }

  assert { 
    day4.adjacent_positions(Coordinate(2, 1), 3, 3) ==
      set.from_list([Coordinate(1, 1), Coordinate(1, 2), 
                                       Coordinate(2, 2),
                     Coordinate(3, 1), Coordinate(3, 2)])
  }
  assert set.size(day4.adjacent_positions(Coordinate(2, 2), 3, 3)) == 8
  assert { 
    day4.adjacent_positions(Coordinate(2, 3), 3, 3) ==
      set.from_list([Coordinate(1, 2), Coordinate(1, 3),
                     Coordinate(2, 2),
                     Coordinate(3, 2), Coordinate(3, 3)])
  }

  assert { 
    day4.adjacent_positions(Coordinate(3, 1), 3, 3) ==
      set.from_list([Coordinate(2, 1), Coordinate(2, 2),
                     Coordinate(3, 2)])
  }
  assert { 
    day4.adjacent_positions(Coordinate(3, 2), 3, 3) ==
      set.from_list([Coordinate(2, 1), Coordinate(2, 2), Coordinate(2, 3),
                     Coordinate(3, 1),                   Coordinate(3, 3)])
  }
  assert { 
    day4.adjacent_positions(Coordinate(3, 3), 3, 3)  ==
      set.from_list([Coordinate(2, 2), Coordinate(2, 3),
                                       Coordinate(3, 2)])
  }
}

// D'oh
//pub fn set_equal_test() {
//  assert day4.set_equal(set.from_list([Coordinate(1, 1)]), set.from_list([Coordinate(1, 1)]))
//  assert day4.set_equal(set.from_list([Coordinate(1, 1)]), set.from_list([Coordinate(1, 2)])) == False
//  assert day4.set_equal(set.from_list([Coordinate(1, 1)]), set.new()) == False
//}

pub fn parse_input_test() {
  let input = ["..@", "@@@"]
  assert day4.parse_input(input) ==
    dict.from_list([#(Coordinate(1, 1), Empty), #(Coordinate(1, 2), Empty), #(Coordinate(1, 3), Roll), 
                    #(Coordinate(2, 1), Roll), #(Coordinate(2, 2), Roll), #(Coordinate(2, 3), Roll),])
}

pub fn add_row_to_grid_test() {
  assert day4.add_row_to_grid("..@", 1, 1, dict.new()) ==
    dict.from_list([#(Coordinate(1, 1), Empty), #(Coordinate(1, 2), Empty), #(Coordinate(1, 3), Roll)])

  assert day4.add_row_to_grid("@@@", 2, 1, dict.new()) ==
    dict.from_list([ #(Coordinate(2, 1), Roll), #(Coordinate(2, 2), Roll), #(Coordinate(2, 3), Roll)])

}
