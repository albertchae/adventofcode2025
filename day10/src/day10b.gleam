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
  input
  |> string.trim()
  |> string.split("\n")
  |> list.map(parse_machine_string)
  |> list.index_fold(0, fn(acc, problem, index) {
    echo index as "machine number"
    let machine_goal = problem.0
    let buttons = problem.1

    acc + find_fewest_button_presses(buttons, machine_goal)
  })
  |> echo
}

/// s looks like "[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}"
pub fn parse_machine_string(s: String) -> #(JoltageState, List(List(Int))) {
  let split_machine_string = s |> string.split(" ")

  let assert Ok(_) = list.first(split_machine_string)

  let assert Ok(rest) = list.rest(split_machine_string)

  let #(buttons, joltage_goal) = parse_buttons(rest, [])

  #(joltage_goal, buttons)
}

/// s looks like the list of split string "(3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}"
fn parse_buttons(
  buttons_and_joltage: List(String),
  buttons: List(List(Int)),
) -> #(List(List(Int)), JoltageState) {
  case buttons_and_joltage {
    [] -> panic as "malformed input"
    [joltage] -> #(buttons, parse_joltage_spec(joltage))
    [head, ..rest] -> {
      parse_buttons(rest, [parse_comma_separated_numbers(head), ..buttons])
    }
  }
}

/// repurposed to use for joltage too
fn parse_comma_separated_numbers(button_string: String) -> List(Int) {
  let numbers_only = button_string |> string.drop_start(1) |> string.drop_end(1)

  numbers_only
  |> string.split(",")
  |> list.map(fn(x) { int.parse(x) |> result.unwrap(-1) })
}

pub fn find_fewest_button_presses(
  buttons: List(List(Int)),
  goal: JoltageState,
) -> Int {
  let JoltageState(jd) = goal
  let initial_joltage =
    list.range(0, dict.size(jd) - 1)
    |> list.map(fn(index) { #(index, 0) })
    |> dict.from_list()
    |> JoltageState()

  do_find_fewest_button_presses(
    buttons,
    goal,
    dict.new() |> dict.insert(initial_joltage, 0),
    [initial_joltage],
    1,
  )
}

/// The first 2 arguments to this are static, the others are the iteration state
/// dp_log is the number of button presses to get to this JoltageState from 0
fn do_find_fewest_button_presses(
  buttons: List(List(Int)),
  goal: JoltageState,
  dp_log: Dict(JoltageState, Int),
  current_states: List(JoltageState),
  current_depth: Int,
) {
  case dp_log |> dict.get(goal) {
    Ok(steps) -> steps
    Error(Nil) -> {
      let next_states =
        process_single_pass_states(current_states, buttons, set.new())
      let new_states =
        next_states
        |> set.filter(fn(s) {
          // filter out states we've already visited
          // and others that are disqualified because they will never satisfy the goal
          !dict.has_key(dp_log, s) && is_possible_intermediate_joltage(s, goal)
        })
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

pub fn is_possible_intermediate_joltage(
  candidate_joltage: JoltageState,
  goal: JoltageState,
) -> Bool {
  let JoltageState(cj_dict) = candidate_joltage
  let JoltageState(g_dict) = goal
  cj_dict
  |> dict.keys()
  |> list.all(fn(index) {
    let assert Ok(cj) = cj_dict |> dict.get(index)
    let assert Ok(gj) = g_dict |> dict.get(index)

    cj <= gj
  })
}

/// a single BFS pass essentially
/// tries to toggle every button once on the depth of states and returns next state + count
/// we will throw away longer states outside of this function
fn process_single_pass_states(
  current_pass_states: List(JoltageState),
  buttons: List(List(Int)),
  next_states: Set(JoltageState),
) -> Set(JoltageState) {
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

/// generates all possible next state
fn process_single_state_all_buttons(
  buttons: List(List(Int)),
  state: JoltageState,
) -> List(JoltageState) {
  buttons
  |> list.fold([], fn(acc, b) { [toggle_button(state, b), ..acc] })
}

pub type JoltageState {
  JoltageState(state: Dict(Int, Int))
}

pub fn toggle_button(machine: JoltageState, button: List(Int)) -> JoltageState {
  let JoltageState(state) = machine

  button
  |> list.fold(state, fn(acc, index) {
    acc
    |> dict.upsert(index, fn(opt) {
      case opt {
        Some(i) -> i + 1
        None -> panic as "dict was set up improperly or malformed input"
      }
    })
  })
  |> JoltageState()
}

// Need to use the more generic form of dict, instead of a bitwise map which was just an Int
pub fn parse_joltage_spec(joltage_spec: String) -> JoltageState {
  joltage_spec
  |> parse_comma_separated_numbers()
  |> list.index_fold(dict.new(), fn(acc, joltage, index) {
    acc
    |> dict.insert(index, joltage)
  })
  |> JoltageState()
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