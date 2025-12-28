import gleam/dict.{type Dict}
import gleam/list
import argv
import simplifile
import gleam/io
import gleam/string

pub fn main() {
  io.println("Hello from day11!")

  // run parse_input_line on every line
  // |> dict.from_list
  // start from you, run DFS/BFS
  let filename = parse_argv()
  let assert Ok(input) = simplifile.read(filename)
  input
  |> string.trim()
  |> string.split("\n")
  |> list.map(parse_input_line)
  |> dict.from_list()
  |> count_paths()
  |> echo
}

pub fn count_paths(graph: Dict(String, List(String))) -> Int {
  do_count_paths(graph, ["you"], 0)
}

fn do_count_paths(graph: Dict(String, List(String)), stack: List(String), count_so_far: Int) -> Int {
  case stack {
    [] -> count_so_far
    [head, ..rest] -> case head == "out" {
      True -> do_count_paths(graph, rest, 1 + count_so_far)
      False -> {
        let assert Ok(next_nodes) = graph |> dict.get(head)
        do_count_paths(graph, list.append(next_nodes, rest), count_so_far)
      }
    }
  }

}

pub fn parse_input_line(s: String) -> #(String, List(String)) {
  let assert Ok(#(node, edges_string)) = string.split_once(s, ":")

  #(
    node,
    edges_string
      |> string.trim()
      |> string.split(" "),
  )
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
