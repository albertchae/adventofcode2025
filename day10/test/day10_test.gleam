import day10.{MachineState}
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn parse_machine_string_test() {

}

pub fn parse_machine_goal_test() {
  assert day10.parse_machine_spec("[.##.]") == MachineState(6)
  assert day10.parse_machine_spec("[...#.]") == MachineState(8)
  assert day10.parse_machine_spec("[.###.#]") == MachineState(46)
}

pub fn convert_button_to_int_test() {
  assert day10.convert_button_to_int([0]) == 1
  assert day10.convert_button_to_int([0, 2, 3, 4]) == 29
  assert day10.convert_button_to_int([0, 4]) == 17
}

pub fn toggle_button_test() {
  assert day10.toggle_button(MachineState(6), [3]) == MachineState(14)

  // from problem examples
  assert MachineState(0)
    |> day10.toggle_button([3])
    |> day10.toggle_button([1, 3])
    |> day10.toggle_button([2])
    == MachineState(6)

  assert MachineState(0)
    |> day10.toggle_button([1, 3])
    |> day10.toggle_button([2, 3])
    |> day10.toggle_button([0, 1])
    |> day10.toggle_button([0, 1])
    == MachineState(6)

  assert MachineState(0)
    |> day10.toggle_button([3])
    |> day10.toggle_button([2])
    |> day10.toggle_button([2, 3])
    |> day10.toggle_button([0, 2])
    |> day10.toggle_button([0, 1])
    == MachineState(6)

  assert MachineState(0)
    |> day10.toggle_button([0, 2])
    |> day10.toggle_button([0, 1])
    == MachineState(6)
}

pub fn find_fewest_button_presses_test() {
  // [.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
  assert day10.find_fewest_button_presses(
      [[3], [1, 3], [2], [2, 3], [0, 2], [0, 1]],
      day10.parse_machine_spec("[.##.]"),
    )
    == 2

  // [...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
  assert day10.find_fewest_button_presses(
      [[0, 2, 3, 4], [2, 3], [0, 4], [0, 1, 2], [1, 2, 3, 4]],
      day10.parse_machine_spec("[...#.]"),
    )
    == 3

  // [.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}
  assert day10.find_fewest_button_presses(
      [[0, 1, 2, 3, 4], [0, 3, 4], [0, 1, 2, 4, 5], [1, 2]],
      day10.parse_machine_spec("[.###.#]"),
    )
    == 2
}
