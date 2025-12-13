import argv
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn main() -> Nil {
  let filename = get_filename()
  let assert Ok(input) = simplifile.read(filename)

  let #(rows, operators) = input |> drop_last_newline_if_necessary() |> parse_input

  // it may have been simpler to split the input by "" and then transpose that and join before doing anything else

  let problem_terms =
    rows
    |> list.transpose()
    |> list.map(fn(c) { c |> list.reverse() |> read_column_vertically() })

  list.zip(operators, problem_terms)
  |> list.map(fn(x) {
    let #(operator, terms) = x
    solve_problem(operator, terms)
  })
  |> echo
  |> list.fold(0, fn(acc, a) { acc + a })
  |> echo

  Nil
}

// the official input has a newline at the end and we can't just use string.trim because
// that'll drop whitespace that is significant to the problem
fn drop_last_newline_if_necessary(input: String) -> String {
  case string.ends_with(input, "\n") {
    True -> input |> string.drop_end(1)
    False -> input
  }
}

fn get_filename() -> String {
  case argv.load().arguments {
    [path] -> path
    _ -> {
      io.println("Usage: gleam run <directory_path>")
      ""
    }
  }
}

pub fn read_column_vertically(col: List(String)) -> List(Int) {
  col
  |> list.map({ string.split(_, "") })
  |> list.transpose()
  |> list.map(fn(a) {
    let n = a |> string.join("") |> string.trim() |> int.parse()
    case n {
      Ok(x) -> x
      Error(_) -> panic as "unknown operator"
    }
  })
}

pub fn parse_input(input: String) -> #(List(List(String)), List(Operator)) {
  // TODO: if performance matters, we can parse into the transposed list directly
  // but for first attempt simplicity, will make it look exactly like the input (except reversed)
  let lines = input |> string.split("\n")

  let assert Ok(operator_row) = lines |> list.last()
  let #(operators, lengths) = operator_row |> parse_operator_row()

  echo operators
  echo lengths

  // parse rows by digit lengths
  // transpose
  // join + convert to int, compute with operator

  #(lines |> split_rows_by_digit_lengths(lengths, []), operators)
}

// This function splits each input row by the number of digits needed for each column
// it keeps whitespace so we can use it later when transposing
// skips last row
fn split_rows_by_digit_lengths(
  input: List(String),
  lengths: List(Int),
  result: List(List(String)),
) -> List(List(String)) {
  case input {
    [] -> panic as "should skip this because last row is operators"
    [_operator_row] -> result
    [head, ..rest] -> {
      let values = head |> split_row_by_digit_lengths(lengths)

      split_rows_by_digit_lengths(rest, lengths, [values, ..result])
    }
  }
}

pub fn split_row_by_digit_lengths(
  row: String,
  lengths: List(Int),
) -> List(String) {
  do_split_row_by_digit_lengths(string.split(row, ""), lengths)
}

fn do_split_row_by_digit_lengths(
  row: List(String),
  lengths: List(Int),
) -> List(String) {
  case lengths {
    [] -> []
    [head, ..rest] -> {
      let current_num = row |> list.take(head) |> string.join("")
      let rest_nums = row |> list.drop(head + 1)
      [current_num, ..do_split_row_by_digit_lengths(rest_nums, rest)]
    }
  }
}

pub type Operator {
  Add
  Multiply
}

pub fn solve_problem(operator: Operator, terms: List(Int)) -> Int {
  let initial_term = case operator {
    Add -> 0
    Multiply -> 1
  }
  terms
  |> list.fold(initial_term, fn(acc, a) {
    case operator {
      Add -> acc + a
      Multiply -> acc * a
    }
  })
}

// this function parses the operator string for 2 things
// - which operator we care about
// - the number of characters between operators (this is needed to correctly align the numbers we parse)
pub fn parse_operator_row(row: String) -> #(List(Operator), List(Int)) {
  row
  |> split_before_operator
  |> do_parse_operator_row
}

fn do_parse_operator_row(row: List(String)) -> #(List(Operator), List(Int)) {
  case row {
    [] -> #([], [])
    [head, ..rest] -> {
      let #(operators, lengths) = do_parse_operator_row(rest)

      #([do_parse_operator(head), ..operators], [
        head |> string.length(),
        ..lengths
      ])
    }
  }
}

fn do_parse_operator(o: String) -> Operator {
  case string.trim(o) {
    "*" -> Multiply
    "+" -> Add
    _ -> panic as "unknown operator"
  }
}

pub fn split_before_operator(s: String) -> List(String) {
  s
  |> string.split("")
  |> do_split_before_operator([], [])
  |> list.reverse
}

fn do_split_before_operator(
  input: List(String),
  result: List(String),
  wip: List(String),
) -> List(String) {
  case input {
    [] -> [wip |> list.reverse() |> string.join(""), ..result]
    [head, ..rest] ->
      case head {
        " " -> do_split_before_operator(rest, result, [head, ..wip])
        _ ->
          case wip {
            // skip materializing wip into a string on the first pass or we end up with an extraneous empty string
            [] -> do_split_before_operator(rest, result, [head])
            _ -> {
              // chop off the space in between operators. 
              // This won't affect the last operator because that hits the base case
              let assert Ok(trimmed_wip) = wip |> list.rest()

              do_split_before_operator(
                rest,
                [trimmed_wip |> list.reverse() |> string.join(""), ..result],
                [head],
              )
            }
          }
      }
  }
}
