import argv
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/result
import gleam/set
import gleam/string
import simplifile

@external(erlang, "Elixir.VectorCombinationSolver", "solve")
pub fn solve(basis_vectors: List(List(Int)), target: List(Int)) -> Int

@external(erlang, "Elixir.VectorCombinationSolver", "two")
pub fn two() -> Int

pub fn main() {
  let filename = parse_argv()
  let assert Ok(input) = simplifile.read(filename)
  input
  |> string.trim()
  |> string.split("\n")
  |> list.map(parse_machine_string)
  |> list.index_map(fn(problem, index) { #(index + 1, problem) })
  |> list.map(
    fn(problem_with_index) {
      let index = problem_with_index.0
      let problem = problem_with_index.1
      let JoltageState(machine_goal) = problem.0
      let goal_vector = machine_goal
      |> dict.to_list()
      |> list.sort(fn (a, b) {
        int.compare(a.0, b.0)
      })
      |> list.map(pair.second)
      |> echo

      let vector_length = list.length(goal_vector)

      let buttons = problem.1

      let basis_vectors = buttons
      |> list.map(fn (button) {
        let button_set = set.from_list(button)

        list.range(1, vector_length)
        |> list.map(fn (i) {
          case button_set |> set.contains(i-1) {
            False -> 0
            True -> 1
          }
        })
      })
      |> echo

      let answer = solve(basis_vectors, goal_vector)

      echo #(index, answer)

      answer
    }
  )
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


pub type JoltageState {
  JoltageState(state: Dict(Int, Int))
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

// https://en.wikipedia.org/wiki/Stars_and_bars_(combinatorics)
pub fn stars_and_bars_distribution(
  total: Int,
  bins: Int,
  max_per_bin: Dict(Int, Int),
) -> List(List(Int)) {
  do_stars_and_bars_distribution(bins, max_per_bin, [#([], total, bins)])
}

fn do_stars_and_bars_distribution(
  bins: Int,
  max_per_bin: Dict(Int, Int),
  work_so_far: List(#(List(Int), Int, Int)),
) -> List(List(Int)) {
  case work_so_far {
    [head, ..] ->
      case list.length(head.0) == bins {
        True -> work_so_far |> list.map(fn(x) { x.0 })
        False ->
          do_stars_and_bars_distribution(
            bins,
            max_per_bin,
            work_so_far
              |> list.map(fn(wip) {
                distribute_next_bin(max_per_bin, wip.0, wip.1, wip.2)
              })
              |> list.flatten(),
          )
      }
    _ -> panic as "this should never happen"
  }
}

fn distribute_next_bin(
  max_per_bin: Dict(Int, Int),
  current_distribution: List(Int),
  remaining_total: Int,
  remaining_bins: Int,
) -> List(#(List(Int), Int, Int)) {
  let bin_index = remaining_bins - 1
  let assert Ok(bin_max) = max_per_bin |> dict.get(bin_index)

  case remaining_bins {
    0 -> panic as "should never reach this base case"
    1 -> [#([remaining_total, ..current_distribution], 0, 0)]
    _ -> {
      list.range(0, int.min(bin_max, remaining_total))
      |> list.fold([], fn(acc, next_bin_amount) {
        [
          #(
            [next_bin_amount, ..current_distribution],
            remaining_total - next_bin_amount,
            remaining_bins - 1,
          ),
          ..acc
        ]
      })
    }
  }
}