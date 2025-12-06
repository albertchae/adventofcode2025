import argv
import gleam/int
import gleam/list
import gleam/result
import file_streams/file_stream
import file_streams/file_stream_error
//import gleam/yielder
import gleam/io
import gleam/string
//import simplifile

pub fn main() -> Nil {
  let filename = get_filename()

  let assert Ok(stream) = file_stream.open_read(filename)

  let battery_list = read_filestream_into_list(stream)

  battery_list
  |> list.map(find_largest_2digit_joltage)
  |> list.fold(0, int.add)
  |> echo

  // part b
  battery_list
  |> list.map(find_largest_12_digit_joltage)
  |> list.fold(0, int.add)
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

fn read_filestream_into_list(stream) -> List(String) {
  let result = file_stream.read_line(stream)

  case result {
    Ok(line) -> [string.trim(line), ..read_filestream_into_list(stream)]
    Error(file_stream_error.Eof) -> []
    _ -> panic as "File reading error!!!"
  }
}

pub fn find_largest_digit(s: String) -> Int {
  s
  |> string.split("")
  |> list.map(fn (n) { n |> int.parse |> result.unwrap(0)})
  |> list.fold(0, int.max)
}

pub fn find_largest_2digit_joltage(s: String) -> Int {
  //let first_digit = find_largest_digit(s |> string.drop_end(1))
  //let assert Ok(#(_, after_first_digit)) = s |> string.split_once(int.to_string(first_digit))
  //let second_digit = find_largest_digit(after_first_digit)

  //first_digit * 10 + second_digit
  find_largest_n_digit_joltage(s, 2, 0)
}

pub fn find_largest_12_digit_joltage(s: String) -> Int {
  find_largest_n_digit_joltage(s, 12, 0)
}

pub fn find_largest_n_digit_joltage(s: String, n: Int, joltage_so_far: Int) -> Int {
  case n {
    0 -> joltage_so_far
    _ -> {
      let first_digit = find_largest_digit(s |> string.drop_end(n-1))
      let assert Ok(#(_, after_first_digit)) = s |> string.split_once(int.to_string(first_digit))
      find_largest_n_digit_joltage(after_first_digit, n - 1, joltage_so_far * 10 + first_digit)
    }
  }
}
