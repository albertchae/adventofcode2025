import day10b.{DifferenceToGoal, JoltageState}
import gleam/dict
import gleam/set
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn parse_joltage_spec_test() {
  assert day10b.parse_joltage_spec("{3,5,4,7}")
    == JoltageState(dict.from_list([#(0, 3), #(1, 5), #(2, 4), #(3, 7)]))
  assert day10b.parse_joltage_spec("{7,5,12,7,2}")
    == JoltageState(
      dict.from_list([#(0, 7), #(1, 5), #(2, 12), #(3, 7), #(4, 2)]),
    )
}

pub fn toggle_button_test() {
  assert day10b.toggle_button(
      JoltageState(dict.from_list([#(0, 0), #(1, 0), #(2, 0), #(3, 0)])),
      [3],
    )
    == JoltageState(dict.from_list([#(0, 0), #(1, 0), #(2, 0), #(3, 1)]))

  // from problem examples
  assert JoltageState(dict.from_list([#(0, 0), #(1, 0), #(2, 0), #(3, 0)]))
    |> day10b.toggle_button([3])
    |> day10b.toggle_button([1, 3])
    |> day10b.toggle_button([1, 3])
    |> day10b.toggle_button([1, 3])
    |> day10b.toggle_button([2, 3])
    |> day10b.toggle_button([2, 3])
    |> day10b.toggle_button([2, 3])
    |> day10b.toggle_button([0, 2])
    |> day10b.toggle_button([0, 1])
    |> day10b.toggle_button([0, 1])
    == JoltageState(dict.from_list([#(0, 3), #(1, 5), #(2, 4), #(3, 7)]))
}

pub fn find_fewest_button_presses_test() {
  // [.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
  assert day10b.find_fewest_button_presses(
      [[3], [1, 3], [2], [2, 3], [0, 2], [0, 1]],
      day10b.parse_joltage_spec("{3,5,4,7}"),
    )
    == 10

  // [...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
  assert day10b.find_fewest_button_presses(
      [[0, 2, 3, 4], [2, 3], [0, 4], [0, 1, 2], [1, 2, 3, 4]],
      day10b.parse_joltage_spec("{7,5,12,7,2}"),
    )
    == 12

  // [.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}
  assert day10b.find_fewest_button_presses(
      [[0, 1, 2, 3, 4], [0, 3, 4], [0, 1, 2, 4, 5], [1, 2]],
      day10b.parse_joltage_spec("{10,11,11,5,10,5}"),
    )
    == 11
}

pub fn smallest_difference_to_goal_test() {
  assert day10b.smallest_difference_to_goal(
      JoltageState(dict.from_list([#(0, 0), #(1, 0), #(2, 0), #(3, 0)])),
      day10b.parse_joltage_spec("{3,5,4,7}"),
    )
    == DifferenceToGoal(0, 3)

  assert day10b.smallest_difference_to_goal(
      JoltageState(
        dict.from_list([#(0, 0), #(1, 0), #(2, 0), #(3, 0), #(4, 0)]),
      ),
      day10b.parse_joltage_spec("{7,5,12,7,2}"),
    )
    == DifferenceToGoal(4, 2)
}

pub fn find_index_with_fewest_buttons_test() {
  // [.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
  assert day10b.find_index_with_fewest_buttons([
      [3],
      [1, 3],
      [2],
      [2, 3],
      [0, 2],
      [0, 1],
    ])
    == 1
  // [...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
  assert day10b.find_index_with_fewest_buttons([
      [0, 2, 3, 4],
      [2, 3],
      [0, 4],
      [0, 1, 2],
      [1, 2, 3, 4],
    ])
    == 1

  // [.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}
  assert day10b.find_index_with_fewest_buttons([
      [0, 1, 2, 3, 4],
      [0, 3, 4],
      [0, 1, 2, 4, 5],
      [1, 2],
    ])
    == 5
}

pub fn stars_and_bars_distribution_test() {
  assert day10b.stars_and_bars_distribution(3, 2, dict.from_list([#(0, 3), #(1, 3)])) |> set.from_list()
    == set.from_list([[3, 0], [2, 1], [1, 2], [0, 3]])

  assert day10b.stars_and_bars_distribution(3, 2, dict.from_list([#(0, 3), #(1, 2)])) |> set.from_list()
    == set.from_list([[3, 0], [2, 1], [1, 2]])

  assert day10b.stars_and_bars_distribution(3, 3, dict.from_list([#(0, 3), #(1, 3), #(2, 3)])) |> set.from_list()
    == set.from_list([
      [3, 0, 0],
      [2, 1, 0],
      [2, 0, 1],
      [0, 2, 1],
      [1, 2, 0],
      [1, 0, 2],
      [0, 1, 2],
      [1, 1, 1],
      [0, 0, 3],
      [0, 3, 0],
    ])

  assert day10b.stars_and_bars_distribution(3, 3, dict.from_list([#(0, 3), #(1, 1), #(2, 1)])) |> set.from_list()
    == set.from_list([
      [3, 0, 0],
      [2, 1, 0],
      [2, 0, 1],
      [1, 1, 1],
    ])
}
