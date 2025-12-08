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

// sort the ranges
// then merge adjacent
// then count

  ranges
  |> list.sort(fn(r1, r2) {
    int.compare(r1.low, r2.low)
  })
  |> coalesce_ranges()
  |> list.map(count_range_elements(_))
  |> int.sum()
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

fn count_range_elements(range: Range) -> Int {
  range.high - range.low + 1
}

// returns 1 merged range if they can be merged
// otherwise returns the original ranges
// r2 should be the one that comes after r1 from the original sorted list of ranges
fn merge_ranges_if_overlap(r1: Range, r2: Range) -> List(Range) {
  case r1.high >= r2.low {
    True -> [Range(int.min(r1.low, r2.low), int.max(r1.high, r2.high))]
    False -> [r2, r1] // return the "later" range first, since it'll be a coalesce candidate
  }
}

pub fn coalesce_ranges(ranges: List(Range)) -> List(Range) {
  coalesce_ranges_helper(ranges, [])
}

fn coalesce_ranges_helper(original_ranges: List(Range), coalesced_ranges: List(Range)) -> List(Range) {
  case original_ranges, coalesced_ranges {
    [], _ -> coalesced_ranges
    [head, ..rest], [] -> coalesce_ranges_helper(rest, [head])
    [head1, ..rest1], [head2, ..rest2] -> {
      case merge_ranges_if_overlap(head2, head1) {
        [r] -> coalesce_ranges_helper(rest1, [r, ..rest2])
        [r2, r1] -> coalesce_ranges_helper(rest1, [r2, r1, ..rest2])
        _ -> panic as "I am too lazy to create a union type for coalesce_ranges_helper"
      }
    }
  }
}
