import argv
import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import simplifile

pub fn main() {
  io.println("Hello from day11!")

  let #(filename, source, sink) = parse_argv()
  let assert Ok(input) = simplifile.read(filename)
  let nodes_and_edges =
    input
    |> string.trim()
    |> string.split("\n")
    |> list.map(parse_input_line)

  let node_dict =
    nodes_and_edges
    |> dict.from_list()
    |> dict.insert("out", [])

  // notes about data:
  // svr has no inward edge
  // out has no outward edge
  // there are no cycles

  node_dict
  |> count_paths(source, sink)
  |> echo as { "paths from " <> source <> "->" <> sink }

  // part 1
  node_dict
  |> count_paths("you", "out")
  |> echo as "part 1: paths from you->out"

  // part 2
  // fft and dac can only be visited in one order otherwise there'd be a cycle
  { node_dict |> count_paths("svr", "fft") }
  * { node_dict |> count_paths("fft", "dac") }
  * { node_dict |> count_paths("dac", "out") }
  |> echo as "part 2: paths from svr->fft * fft->dac * dac->out"
}

pub fn count_paths(
  graph: Dict(String, List(String)),
  source: String,
  sink: String,
) -> Int {
  let path_counter = do_count_paths(graph, dict.new(), [#(source, 1)], sink)
  let assert Ok(paths) = path_counter |> dict.get(sink)
  paths
}

fn do_count_paths(
  graph: Dict(String, List(String)),
  path_counter: Dict(String, Int),
  current_nodes: List(#(String, Int)),
  sink: String,
) -> Dict(String, Int) {
  case current_nodes {
    [] -> path_counter
    _ -> {
      let updated_path_counter =
        current_nodes
        |> list.fold(path_counter, fn(acc, pair) {
          let #(node, count) = pair
          acc
          |> dict.upsert(node, fn(opt) {
            case opt {
              None -> count
              Some(i) -> i + count
            }
          })
        })
      let next_nodes =
        current_nodes
        |> list.filter(fn(pair) {
          let #(node, _) = pair
          node != sink
        })
        |> list.map(fn(pair) {
          let #(node, count) = pair
          let assert Ok(children) = graph |> dict.get(node)

          children
          |> list.map(fn(c) { #(c, count) })
        })
        |> list.flatten()
        |> list.fold(dict.new(), fn(acc, pair) {
          // reduce recursion branching factor by collapsing next nodes
          let #(node, count) = pair
          acc
          |> dict.upsert(node, fn(opt) {
            case opt {
              None -> count
              Some(i) -> i + count
            }
          })
        })
        |> dict.to_list()

      do_count_paths(graph, updated_path_counter, next_nodes, sink)
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

fn parse_argv() -> #(String, String, String) {
  case argv.load().arguments {
    [path, source, sink] -> #(path, source, sink)
    _ -> {
      io.println("Usage: gleam run <directory_path> <source> <sink>")
      #("", "", "")
    }
  }
}
