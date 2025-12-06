import argv
import gleam/int
import gleam/list
import gleam/yielder
import gleam/io
import gleam/string
import simplifile

pub fn main() -> Nil {
  let filename = get_filename()
  let assert Ok(comma_separated_ranges) = simplifile.read(filename)
  comma_separated_ranges
  |> parse_comma_separated_ranges
  |> find_invalid_multiple_ranges
  |> sum_nested
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

pub fn halve_string(s: String) -> #(String, String) {
  let len = string.length(s)

  let len1 = len/2
  let len2 = case int.is_even(len) {
    True -> len/2
    False -> len/2 + 1
  }

  let s1 = string.slice(from: s, at_index: 0, length: len1)
  let s2 = string.slice(from: s, at_index: len1, length: len2)

  #(s1, s2)
}


pub fn find_invalid_in_range(from: Int, to: Int) -> List(Int) {
  yielder.range(from, to)
  |> yielder.filter(is_invalid_with_repeated)
  |> yielder.to_list()
}

pub fn is_invalid_with_repeated(n: Int) -> Bool {
  int.to_string(n)
  |> repeated_substring(1)
}

pub fn repeated_substring(full: String, current_substring_length: Int) -> Bool {
  let len = string.length(full)
  let times = len / current_substring_length
  let times_remainder = len % current_substring_length
  case times < 2 {
    True -> False
    False -> case times_remainder > 0 {
      True -> repeated_substring(full, current_substring_length + 1)
      False -> case full == full |> string.slice(0, current_substring_length) |> string.repeat(times) {
        True -> True
        False -> repeated_substring(full, current_substring_length + 1)
      }
    }
  }
}


pub fn find_invalid_multiple_ranges(ranges: List(#(Int, Int))) -> List(List(Int)) {
  case ranges {
    [] -> []
    [#(n1, n2), ..tail] -> [find_invalid_in_range(n1, n2), ..find_invalid_multiple_ranges(tail)]
  }
}

pub fn sum_nested(nums: List(List(Int))) -> Int {
  nums
  |> list.fold(from: 0, with: fn(acc, list) { 
    acc + list.fold(list, 0, fn(x, y) { x + y } ) 
  })
}

pub fn parse_comma_separated_ranges(input: String) -> List(#(Int, Int)) {
  input
  |> string.split(on: ",")
  |> list.map(parse_range_string)
}


pub fn parse_range_string(range_string: String) -> #(Int, Int) {
  let assert [s1, s2] = string.split(string.trim(range_string), "-")
  let assert Ok(n1) = int.parse(s1)
  let assert Ok(n2) = int.parse(s2)
  #(n1, n2)
}
