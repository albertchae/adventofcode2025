import argv
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn main() -> Nil {
  let filename = get_filename()
  let assert Ok(input) = simplifile.read(filename)
  input
  |> echo
  |> parse_input
  |> list.transpose()
  |> list.map(solve_problem)
  |> echo
  |> list.fold(0, fn(acc, a) { acc + a })
  |> echo

  Nil
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

pub fn parse_input(input: String) -> List(List(ProblemElement)) {
  // TODO: if performance matters, we can parse into the transposed list directly
  // but for first attempt simplicity, will make it look exactly like the input (except reversed)
  input
  |> string.split("\n")
  |> parse_input_helper([])
}

fn parse_input_helper(
  input: List(String),
  result: List(List(ProblemElement)),
) -> List(List(ProblemElement)) {
  case input {
    [] -> result
    [head, ..rest] -> {
      let values =
        head
        |> string.split(" ")
        |> list.filter_map(fn(x) {
          case x {
            "" -> Error("filter empty strings")
            _ -> Ok(string.trim(x))
          }
        })

      let elements =
        values
        |> list.map(fn(x) {
          case int.parse(x) {
            Ok(n) -> Number(n)
            Error(_) ->
              case x {
                "*" -> OperatorElement(Multiply)
                "+" -> OperatorElement(Add)
                _ -> panic as "unknown operator"
              }
          }
        })

      parse_input_helper(rest, [elements, ..result])
    }
  }
}

pub type Operator {
  Add
  Multiply
}

pub type ProblemElement {
  OperatorElement(Operator)
  Number(value: Int)
}

// a problem is a list of integers except the first element is an operator + or *
pub fn solve_problem(problem: List(ProblemElement)) -> Int {
  let assert Ok(operator) = list.first(problem)
  let assert Ok(terms) = list.rest(problem)
  // TODO: how to make ProblemElement be the functions themselves
  // TODO: how to say terms is a List(Int) for sure
  let initial_term = case operator {
    OperatorElement(Add) -> 0
    OperatorElement(Multiply) -> 1
    _ -> panic as "malformed input"
  }
  terms
  |> list.fold(initial_term, fn(acc, a) {
    case a {
      OperatorElement(_) -> acc
      Number(val) ->
        case operator {
          OperatorElement(Add) -> acc + val
          OperatorElement(Multiply) -> acc * val
          _ -> acc
        }
    }
  })
}
