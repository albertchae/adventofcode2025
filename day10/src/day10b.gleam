import argv
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/order
import gleam/pair
import gleam/result
import gleam/string
import gleam/yielder
import gleam_community/maths
import parallel_map.{MatchSchedulersOnline}
import simplifile

pub fn main() {
  let filename = parse_argv()
  let assert Ok(input) = simplifile.read(filename)
  input
  |> string.trim()
  |> string.split("\n")
  |> list.map(parse_machine_string)
  |> parallel_map.list_pmap(
    fn(problem) {
      let machine_goal = problem.0
      let buttons = problem.1

      find_fewest_button_presses(buttons, machine_goal)
      |> echo
    },
    MatchSchedulersOnline,
    100_000_000,
  )
  |> list.map(result.unwrap(_, -1))
  |> list.fold(0, int.add)
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
    goal,
    dict.new() |> dict.insert(initial_joltage, 0),
    [#(buttons, initial_joltage)],
  )
}

/// The first 2 arguments to this are static, the others are the iteration state
/// dp_log is the number of button presses to get to this JoltageState from 0
fn do_find_fewest_button_presses(
  goal: JoltageState,
  dp_log: Dict(JoltageState, Int),
  current_states: List(#(List(List(Int)), JoltageState)),
) -> Int {
  echo list.length(current_states) as "current_states length"
  case current_states {
    [] -> dp_log |> dict.get(goal) |> result.unwrap(-1)
    [head, ..rest] -> {
      let current_buttons = head.0
      let current_state = head.1
      // for each current state
      // - get index of smallest difference d to goal joltage
      // - get every button that touches that index
      // - every possible combination of these buttons to 
      //     maths.list_combination_with_repetition(buttons, d)
      //   - for each sublist here, collapse it into a next state
      let index = find_index_with_fewest_buttons(current_buttons)
      let JoltageState(g_dict) = goal
      let JoltageState(cs_dict) = current_state

      let diff =
        { g_dict |> dict.get(index) |> result.unwrap(-1) }
        - { cs_dict |> dict.get(index) |> result.unwrap(1) }

      let #(buttons_for_index, remaining_buttons) =
        current_buttons
        |> partition_buttons_for_index(index)
      let assert Ok(possible_button_combinations) =
        buttons_for_index
        |> maths.list_combination_with_repetitions(diff)

      // idea 1, i don't actually need all these lists, so write my own generator
      // idea 2, start with spaces that are touched by the fewest buttons

      let next_states =
        possible_button_combinations
        |> yielder.to_list()
        |> list.map(fn(buttons) {
          buttons
          |> list.fold(current_state, fn(acc, button) {
            acc |> toggle_button(button)
          })
        })

      // recurse, but remove all those buttons?
      // this won't necessarily find the shortest path first like BFS, so we should continue until we exhaust all next states instead of stopping as soon as we reach the goal

      let new_states =
        next_states
        |> list.filter(fn(s) {
          // disqualify states that will never satisfy the goal
          is_possible_intermediate_joltage(s, goal)
        })

      // update dynamic programming log
      let assert Ok(current_distance) = dp_log |> dict.get(current_state)
      let updated_distance = current_distance + diff
      let updated_dp_log =
        new_states
        |> list.fold(dp_log, fn(acc, s) {
          acc
          |> dict.upsert(s, fn(opt) {
            case opt {
              Some(i) ->
                case updated_distance < i {
                  True -> updated_distance
                  False -> i
                }
              None -> updated_distance
            }
          })
        })

      case remaining_buttons {
        [] -> do_find_fewest_button_presses(goal, updated_dp_log, rest)
        _ -> {
          // filter out goal from new_states, then add it to rest and continue
          let states_to_recurse =
            new_states
            |> list.filter(fn(s) { s != goal })
            |> list.map(fn(s) { #(remaining_buttons, s) })
            |> list.append(rest)
          do_find_fewest_button_presses(goal, updated_dp_log, states_to_recurse)
        }
      }
    }
  }
}

pub type DifferenceToGoal {
  DifferenceToGoal(index: Int, d: Int)
}

// find index with fewest buttons that can affect it
// if there's a tiebreaker, find the index with a set of buttons that touches the fewest other indices
pub fn find_index_with_fewest_buttons(buttons: List(List(Int))) -> Int {
  buttons
  |> list.fold(dict.new(), fn(acc, button) {
    button
    |> list.fold(acc, fn(inner_acc, index) {
      inner_acc
      |> dict.upsert(index, fn(opt) {
        case opt {
          None -> [button]
          Some(buttons) -> [button, ..buttons]
        }
      })
    })
  })
  |> dict.fold(#(-1, []), fn(acc, k, v) {
    case acc.0 == -1 {
      True -> #(k, v)
      False ->
        case int.compare(list.length(v), list.length(acc.1)) {
          order.Gt -> acc
          order.Lt -> #(k, v)
          order.Eq ->
            case sum_sublist_lengths(v) < sum_sublist_lengths(acc.1) {
              True -> acc
              False -> #(k, v)
            }
        }
    }
  })
  |> pair.first()
}

fn sum_sublist_lengths(list_of_lists: List(List(any))) -> Int {
  list_of_lists
  |> list.fold(0, fn(acc, sublist) { acc + list.length(sublist) })
}

// smallest non zero difference to goal
pub fn smallest_difference_to_goal(
  current_state: JoltageState,
  goal: JoltageState,
) -> DifferenceToGoal {
  let JoltageState(cs_dict) = current_state
  let JoltageState(g_dict) = goal

  cs_dict
  |> dict.keys()
  |> list.fold(DifferenceToGoal(-1, 100_000), fn(acc, k) {
    let smallest_diff_so_far = acc.d

    let diff =
      { g_dict |> dict.get(k) |> result.unwrap(-1) }
      - { cs_dict |> dict.get(k) |> result.unwrap(-1) }

    case diff != 0 && diff < smallest_diff_so_far {
      True -> DifferenceToGoal(k, diff)
      False -> acc
    }
  })
}

fn partition_buttons_for_index(
  buttons: List(List(Int)),
  index: Int,
) -> #(List(List(Int)), List(List(Int))) {
  buttons
  |> list.partition(fn(button) {
    button
    |> list.contains(index)
  })
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