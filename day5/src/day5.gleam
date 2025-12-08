import gleam/list
import gleam/int
import argv
import simplifile

import gleam/io
import gleam/string

pub fn main() -> Nil {
  let filename = get_filename()
  let assert Ok(input) = simplifile.read(filename)

  let assert [range_strings, ingredient_ids] = input |> string.trim() |> string.split("\n\n")

  let ranges = parse_ranges(range_strings |> string.split("\n"))

  ingredient_ids
  |> string.split("\n")
  |> list.filter(fn(id_string) {
    let assert Ok(id) = int.parse(id_string)
    case ranges |> list.find({in_range(_, id)}) {
      Ok(_) -> True
      Error(_) -> False
    }
  })
  |> list.length() 
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

pub type Range {
  Range(low: Int, high: Int)
}

fn in_range(range: Range, n: Int) -> Bool {
  n >= range.low && n <= range.high
}

pub fn parse_ranges(range_strings: List(String)) -> List(Range) {
  parse_ranges_helper(range_strings, [])
}

fn parse_ranges_helper(range_strings: List(String), ranges: List(Range)) -> List(Range) {
  case range_strings {
    [] -> ranges
    [head, ..tail] -> parse_ranges_helper(tail, [parse_range(head), ..ranges])
  }
}

fn parse_range(range_string: String) -> Range {
  let assert Ok(#(low_string, high_string)) = range_string |> string.split_once("-")
  let assert Ok(low) = int.parse(low_string)
  let assert Ok(high) = int.parse(high_string)

  Range(low, high)
}
