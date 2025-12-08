import gleam/list
import gleam/int
import argv
import simplifile

import gleam/io
import gleam/string
import gleam/set.{type Set}

pub fn main() -> Nil {
  let filename = get_filename()
  let assert Ok(input) = simplifile.read(filename)

  let assert [range_strings, _] = input |> string.trim() |> string.split("\n\n")

  let ranges = parse_ranges(range_strings |> string.split("\n"))

  ranges
  |> list.fold(
    from: set.new(), 
    with: fn(s, range) {
      range_to_set(range, s)
    })
  |> set.size()
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

pub fn range_to_set(range: Range, s: Set(Int)) -> Set(Int) {
  let updated_set = s |> set.insert(range.low)
  case range {
    Range(a, b) if a == b -> updated_set
    Range(a, b) -> range_to_set(Range(a+1, b), updated_set)
  }
}
