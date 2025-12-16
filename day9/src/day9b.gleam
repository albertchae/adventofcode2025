import argv
import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile

pub fn main() {
  let filename = parse_argv()
  let assert Ok(input) = simplifile.read(filename)
  let point_strings = input |> string.trim() |> string.split("\n")

  let points = point_strings |> list.map(parse_point_string)

  // get all edges
  // for points in min x, min y to max x, max y, determine if they are in polygon or not
  // for all candidate_rectangle_corners, determine if all points in candidate rectangle are in polygon
  // get the max rectangle that qualifies
  let edges = polygon_edges(points)
  let top_left_corner =
    Point(
      points |> list.map(fn(p) { p.col }) |> list.fold(100_000, int.min),
      points |> list.map(fn(p) { p.row }) |> list.fold(100_000, int.min),
    )
  let bottom_right_corner =
    Point(
      points |> list.map(fn(p) { p.col }) |> list.fold(0, int.max),
      points |> list.map(fn(p) { p.row }) |> list.fold(0, int.max),
    )

  let #(horizontal_edges, vertical_edges) =
    edges
    |> list.partition(fn(e) { edge_orientation(e) == Horizontal })

  let points_in_polygon =
    rectangle_map(top_left_corner, bottom_right_corner, fn(point: Point) {
      case is_in_polygon(point, horizontal_edges, vertical_edges) {
        True -> Ok(point)
        False -> Error("not in polygon")
      }
    })
    |> list.filter_map(function.identity)
    |> set.from_list()
    |> echo

  print_grid(top_left_corner, bottom_right_corner, points_in_polygon)

  let candidate_rectangle_corners = points |> list.combination_pairs()

  let rectangle_corners_in_polygon =
    candidate_rectangle_corners
    |> list.filter(fn(corners) {
      rectangle_map(corners.0, corners.1, fn(p) {
        points_in_polygon |> set.contains(p)
      })
      |> list.all(function.identity)
    })
    |> echo

  rectangle_corners_in_polygon
  |> largest_rectangle_area
  |> echo
}

fn largest_rectangle_area(corners: List(#(Point, Point))) {
  corners
  |> list.map(fn(pair) { rectangle_area(pair.0, pair.1) })
  |> list.sort(int.compare)
  |> list.last()
}

// given a top left and bottom right corner of a rectangle, map a function over every point
pub fn rectangle_map(p1: Point, p2: Point, function: fn(Point) -> a) -> List(a) {
  list.range(p1.row, p2.row)
  |> list.map(fn(row) {
    list.range(p1.col, p2.col)
    |> list.map(fn(col) {
      let point = Point(col:, row:)
      function(point)
    })
  })
  |> list.flatten
}

pub fn is_in_polygon(
  p: Point,
  horizontal_edges: List(Edge),
  vertical_edges: List(Edge),
) {
  { horizontal_edges |> list.any({ is_point_on_edge(p, _) }) }
  || { vertical_edges |> list.any({ is_point_on_edge(p, _) }) }
  || { intersects_vertical_edges_odd_times(p, vertical_edges) }
}

pub fn intersects_vertical_edges_odd_times(
  p: Point,
  vertical_edges: List(Edge),
) -> Bool {
  vertical_edges
  |> list.count({ is_intersecting_horizontal_ray(p, _) })
  |> int.is_odd
}

// assume we are casting ray from point on x axis to the right, e.g. increasing col
// point is not on edge, we will have checked this separately before
pub fn is_intersecting_horizontal_ray(p: Point, vertical: Edge) -> Bool {
  assert Vertical == edge_orientation(vertical)
  {
    p.row >= { vertical.0 }.row
    && p.row <= { vertical.1 }.row
    || p.row >= { vertical.1 }.row
    && p.row <= { vertical.0 }.row
  }
  && p.col <= { vertical.0 }.col
  // only need to check one vertex col because it's a vertical edge
}

// we are assuming purely vertical or horizontal edges
pub fn is_point_on_edge(p: Point, e: Edge) -> Bool {
  case edge_orientation(e) {
    Horizontal ->
      p.row == { e.0 }.row && p.col |> is_between({ e.0 }.col, { e.1 }.col)
    Vertical ->
      p.col == { e.0 }.col && p.row |> is_between({ e.0 }.row, { e.1 }.row)
  }
}

pub fn edge_orientation(e: Edge) -> EdgeOrientation {
  case { e.0 }.col == { e.1 }.col {
    True -> Vertical
    False ->
      case { e.0 }.row == { e.1 }.row {
        True -> Horizontal
        _ -> panic as "non horizontal or vertical edge found"
      }
  }
}

// checks if x is in between the bounds, regardless of which value is bigger
fn is_between(x: Int, bound1: Int, bound2: Int) -> Bool {
  case bound1 < bound2 {
    True -> x <= bound2 && x >= bound1
    False -> x <= bound1 && x >= bound2
  }
}

pub fn polygon_edges(points: List(Point)) -> List(Edge) {
  let assert Ok(last) = list.last(points)
  let assert Ok(first) = list.first(points)
  let wraparound_edge = #(last, first)
  [wraparound_edge, ..list.window_by_2(points)]
}

pub fn parse_point_string(s: String) -> Point {
  let assert [col, row] = s |> string.split(",")
  Point(
    col |> int.parse() |> result.unwrap(-1),
    row |> int.parse() |> result.unwrap(-1),
  )
}

pub type EdgeOrientation {
  Horizontal
  Vertical
}

pub type Edge =
  #(Point, Point)

pub type Point {
  Point(col: Int, row: Int)
}

pub fn rectangle_area(p1: Point, p2: Point) -> Int {
  { int.absolute_value(p1.col - p2.col) + 1 }
  * { int.absolute_value(p1.row - p2.row) + 1 }
}

pub fn print_grid(p1: Point, p2: Point, inside_polygon: Set(Point)) {
  list.range(p1.row, p2.row)
  |> list.each(fn(row) {
    list.range(p1.col, p2.col)
    |> list.each(fn(col) {
      let point = Point(col:, row:)
      case set.contains(inside_polygon, point) {
        True -> io.print("#")
        False -> io.print(".")
      }
    })
    io.println("")
  })
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
