import gleam/result
import gleam/list
import gleam/string
import argv
import simplifile
import gleam/int
import gleam/io

pub fn main() {
  let filename = parse_argv()
  let assert Ok(input) = simplifile.read(filename)
  let point_strings = input |> string.trim() |> string.split("\n")

  let points = point_strings |> list.map(parse_point_string)

  let point_pairs = points |> list.combination_pairs()

  point_pairs
  |> list.map(fn (pair) {
    rectangle_area(pair.0, pair.1)
  })
  |> list.sort(int.compare)
  |> list.last()
  |> echo
}

pub fn parse_point_string(s: String) -> Point {
  let assert [x, y,] = s |> string.split(",")
  Point(
    x |> int.parse() |> result.unwrap(-1),
    y |> int.parse() |> result.unwrap(-1),
  )
}

pub type Point {
  Point(x: Int, y: Int)
}

pub fn rectangle_area(p1: Point, p2: Point) -> Int {
  { int.absolute_value(p1.x - p2.x) + 1 }
  * { int.absolute_value(p1.y - p2.y) + 1 }
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
