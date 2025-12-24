import argv
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile

pub fn main() {
  let filename = parse_argv()
  let assert Ok(input) = simplifile.read(filename)
  let machine_strings =
    input
    |> string.trim()
    |> string.split("\n")
    |> list.map(parse_machine_string)
    |> list.fold(0, fn(acc, problem) {
      let machine_goal = problem.0
      let buttons = problem.1

      acc + find_fewest_button_presses(buttons, machine_goal)
    })
    |> echo
}

// s looks like "[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}"
pub fn parse_machine_string(s: String) -> #(MachineState, List(List(Int))) {
  let split_machine_string = s |> string.split(" ")

  let assert Ok(machine_spec) = list.first(split_machine_string)

  let assert Ok(rest) = list.rest(split_machine_string)

  let buttons = parse_buttons(rest, [])

  #(parse_machine_spec(machine_spec), buttons)
}

// s looks like the list of split string "(3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}"
fn parse_buttons(
  buttons_and_joltage: List(String),
  buttons: List(List(Int)),
) -> List(List(Int)) {
  case buttons_and_joltage {
    [] -> panic as "malformed input"
    [_joltage] -> buttons
    [head, ..rest] -> {
      parse_buttons(rest, [parse_button(head), ..buttons])
    }
  }
}

fn parse_button(button_string: String) -> List(Int) {
  let numbers_only = button_string |> string.drop_start(1) |> string.drop_end(1)

  numbers_only
  |> string.split(",")
  |> list.map(fn(x) { int.parse(x) |> result.unwrap(-1) })
}

// dp_log is the number of button presses to get to this MachineState from 0
pub fn find_fewest_button_presses(
  buttons: List(List(Int)),
  goal: MachineState,
) -> Int {
  do_find_fewest_button_presses(
    buttons,
    goal,
    dict.new() |> dict.insert(MachineState(0), 0),
    [MachineState(0)],
    1,
  )
}

// The first 2 arguments to this are static, the others are the iteration state
fn do_find_fewest_button_presses(
  buttons: List(List(Int)),
  goal: MachineState,
  dp_log: Dict(MachineState, Int),
  current_states: List(MachineState),
  current_depth: Int,
) {
  case dp_log |> dict.get(goal) {
    Ok(steps) -> steps
    Error(Nil) -> {
      let next_states =
        process_single_pass_states(current_states, buttons, set.new())
      let new_states =
        next_states
        |> set.filter(fn(s) { !dict.has_key(dp_log, s) })
      let updated_dp_log =
        new_states
        |> set.fold(dp_log, fn(acc, s) {
          acc
          |> dict.upsert(s, fn(opt) {
            case opt {
              // by definition this will be smaller than current_depth
              Some(i) -> i
              None -> current_depth
            }
          })
        })
      do_find_fewest_button_presses(
        buttons,
        goal,
        updated_dp_log,
        new_states |> set.to_list(),
        current_depth + 1,
      )
    }
  }
}

// a single BFS pass essentially
// tries to toggle every button once on the depth of states and returns next state + count
// we will throw away longer states outside of this function
fn process_single_pass_states(
  current_pass_states: List(MachineState),
  buttons: List(List(Int)),
  next_states: Set(MachineState),
) -> Set(MachineState) {
  case current_pass_states {
    [] -> next_states
    [head, ..rest] -> {
      let more_states = process_single_state_all_buttons(buttons, head)

      let updated_states =
        more_states
        |> set.from_list()
        |> set.union(next_states)

      process_single_pass_states(rest, buttons, updated_states)
    }
  }
}

// generates all possible next state
fn process_single_state_all_buttons(
  buttons: List(List(Int)),
  state: MachineState,
) -> List(MachineState) {
  buttons
  |> list.fold([], fn(acc, b) { [toggle_button(state, b), ..acc] })
}

pub type MachineState {
  MachineState(state: Int)
}

pub fn toggle_button(machine: MachineState, button: List(Int)) -> MachineState {
  let MachineState(state) = machine
  state
  |> int.bitwise_exclusive_or(convert_button_to_int(button))
  |> MachineState()
}

// convert a button to the Int we can use to XOR with machine state
pub fn convert_button_to_int(button: List(Int)) -> Int {
  button
  |> list.fold(0, fn(acc, x) { int.bitwise_shift_left(1, x) + acc })
}

pub fn parse_machine_spec(machine_spec: String) -> MachineState {
  // this could be reduced to a single pass over the string
  machine_spec
  |> string.drop_start(1)
  |> string.drop_end(1)
  |> string.replace(".", "0")
  |> string.replace("#", "1")
  |> string.reverse()
  |> int.base_parse(2)
  |> result.unwrap(-1)
  |> MachineState()
}

fn parse_argv() -> String {
  case argv.load().arguments {
    [path] -> path
    _ -> {
      io.println("Usage: gleam run <directory_path> <count>")
      ""
    }
  }
}