import gleam/io
import argv
import file_streams/file_stream
import file_streams/file_stream_error
import gleam/string
import gleam/int

pub fn main() -> Nil {
  let filename = get_filename()

  echo filename
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
      let #(new_pos, passed_zeros) = add_instruction(head, pos)
      // echo #(new_pos, passed_zeros)
      count_zeros(tail, new_pos, num_zeros + passed_zeros)
    }
  }
}

fn add_instruction(instruction, pos) -> #(Int, Int) {
  let modified_pos = case instruction {
    #("R", num) -> pos + num
    #("L", num) -> pos - num
    _ -> panic as "instruction is malformed"
  }

  let assert Ok(new_pos) = int.modulo(modified_pos, 100)
  let passed_zeros = int.absolute_value(modified_pos / 100)
  let positive_to_negative = modified_pos < 0 && pos > 0 // intentionally leaves out when previous pos was 0, dial has to cross from positive to negative
  let actual_zero = modified_pos == 0 // this adds an additional click on 0 that isn't captured by the integer division

  // echo #(instruction, positive_to_negative, new_pos, modified_pos)

  case positive_to_negative || actual_zero {
    True -> #(new_pos, passed_zeros + 1)
    False -> #(new_pos, passed_zeros)
  }
}
