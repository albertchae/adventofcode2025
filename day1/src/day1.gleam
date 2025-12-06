import gleam/io
import argv
import file_streams/file_stream
import file_streams/file_stream_error
import gleam/string
import gleam/int

pub fn main() -> Nil {
  let filename = get_filename()

  // echo filename
  let assert Ok(stream) = file_stream.open_read(filename)

  let instruction_list = read_filestream_into_list(stream)

  let password = count_zeros(instruction_list, 50, 0)

  echo password

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

fn read_filestream_into_list(stream) -> List(#(String, Int)) {
  let result = file_stream.read_line(stream)

  case result {
    Ok(line) -> [parse_instruction(line), ..read_filestream_into_list(stream)]
    Error(file_stream_error.Eof) -> []
    _ -> panic as "File reading error!!!"
  }
}

fn parse_instruction(line) -> #(String, Int) {
  case line {
    "R" <> num_string -> {
      let assert Ok(num) = int.parse(string.trim(num_string))
      #("R", num)
    }
    "L" <> num_string -> {
      let assert Ok(num) = int.parse(string.trim(num_string))
      #("L", num)
    }
    _ -> panic as "input should only have R and L"
  }
}

fn count_zeros(list, pos, num_zeros) -> Int {
  case list {
    [] -> num_zeros
    [head, ..tail] -> {
      let new_pos = add_instruction(head, pos)
      case new_pos == 0 {
        True -> count_zeros(tail, new_pos, num_zeros + 1)
        False -> count_zeros(tail, new_pos, num_zeros)
      }
    }
  }
}

fn add_instruction(instruction, pos) -> Int {
  let assert Ok(new_pos) = case instruction {
    #("R", num) -> int.modulo(pos + num, 100)
    #("L", num) -> int.modulo(pos - num, 100)
    _ -> panic as "instruction is malformed"
  }
  new_pos
}
