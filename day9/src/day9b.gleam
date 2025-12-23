import argv
import gleam/bool
import gleam/dict.{type Dict}
import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/order.{type Order, Eq, Gt, Lt}
import gleam/pair
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
  // buffer top left and bottom right corners by 1 so that we know these points always start outside the polygon
  let top_left_corner =
    Point(
      { points |> list.map(fn(p) { p.col }) |> list.fold(100_000, int.min) } - 1,
      { points |> list.map(fn(p) { p.row }) |> list.fold(100_000, int.min) } - 1,
    )
  let bottom_right_corner =
    Point(
      { points |> list.map(fn(p) { p.col }) |> list.fold(0, int.max) } + 1,
      { points |> list.map(fn(p) { p.row }) |> list.fold(0, int.max) } + 1,
    )

  print_grid(top_left_corner, bottom_right_corner, set.from_list(points))

  let #(horizontal_edges, vertical_edges) =
    edges
    |> list.partition(fn(e) { edge_orientation(e) == Horizontal })

  let points_in_polygon =
    identify_points_in_polygon(
      top_left_corner,
      bottom_right_corner,
      horizontal_edges,
      vertical_edges,
    )
    |> echo

  print_grid_with_bst(top_left_corner, bottom_right_corner, points_in_polygon)

  let candidate_rectangle_corners = points |> list.combination_pairs()

  let rectangle_corners_in_polygon =
    candidate_rectangle_corners
    |> list.filter(fn(corners) {
      rectangle_map(corners.0, corners.1, fn(p) {
        points_in_polygon |> inside_polygon_dict(p)
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

// dict of row num to binary search tree of number ranges
// method to convert list of ranges to binary search tree
// 

pub fn identify_points_in_polygon(
  p1: Point,
  p2: Point,
  horizontal_edges: List(Edge),
  vertical_edges: List(Edge),
) -> Dict(Int, BSTNode) {
  // horizontal edges by row
  // vertical edges by column

  let horizontal_edges_by_row =
    list.fold(horizontal_edges, dict.new(), fn(acc, edge) {
      acc
      |> dict.upsert({ edge.0 }.row, fn(val) {
        case val {
          None -> [edge]
          Some(edges) -> [edge, ..edges]
        }
      })
    })

  let vertical_edges_by_col =
    list.fold(vertical_edges, dict.new(), fn(acc, edge) {
      acc
      |> dict.upsert({ edge.0 }.col, fn(val) {
        case val {
          None -> [edge]
          Some(edges) -> [edge, ..edges]
        }
      })
    })

  list.range(p1.row, p2.row)
  |> list.fold(dict.new(), fn(row_to_bst_nodes, row) {
    // we start with a point guaranteed to be outside the polygon
    // if currently not in polygon and we cross a vertical edge, then we are in polygon
    // we are in polygon until we cross the next vertical edge
    // Because horizontal edges are a special case, we will cast the ray at 0.5 
    // above the current point and account for horizontal edges separately
    case row % 1000 == 0 {
      True -> echo row as "scanning row"
      _ -> 1
    }

    let row_bst =
      list.range(p1.col + 1, p2.col)
      |> list.fold(#([], False), fn(acc, col) {
        let point = Point(col:, row:)
        let current_point_on_horizontal_edge =
          horizontal_edges_by_row
          |> dict.get(row)
          |> result.unwrap([])
          |> list.any({ is_point_on_edge(point, _) })

        let in_polygon = acc.1
        let intersect_vertical =
          vertical_edges_by_col
          |> dict.get(col)
          |> result.unwrap([])
          |> list.any({
            is_offset_point_on_edge(
              OffsetPoint(col:, row: { int.to_float(row) -. 0.5 }),
              _,
            )
          })

        let add_current_point_to_polygon =
          in_polygon
          || current_point_on_horizontal_edge
          || { !in_polygon && intersect_vertical }
        let next_ranges = case add_current_point_to_polygon {
          True ->
            case acc.0 {
              // a range will never be a single value, but start with that as a placeholder
              [] -> [#(col, col)]
              [head, ..rest] -> {
                let current_range: #(Int, Int) = head
                case current_range.1 + 1 == col {
                  // extend current range
                  True -> [#(current_range.0, col), ..rest]
                  // start new range
                  False -> [#(col, -9), current_range, ..rest]
                }
              }
            }
          False -> acc.0
        }

        let next_in_polygon = bool.exclusive_or(in_polygon, intersect_vertical)

        #(next_ranges, next_in_polygon)
      })
      |> pair.first()
      |> reversed_list_to_binary_search_tree()

    row_to_bst_nodes |> dict.insert(row, row_bst)
  })
}

pub type BSTNode {
  BSTNode(value: #(Int, Int), less_than: BSTNode, greater_than: BSTNode)
  Empty
}

// data is a list of mutually exclusive ranges in reverse order.
// The ranges themselves are tuples in #(min, max) shape
pub fn reversed_list_to_binary_search_tree(data: List(#(Int, Int))) -> BSTNode {
  case data {
    [] -> Empty
    [single] -> BSTNode(single, Empty, Empty)
    _ -> {
      let length = list.length(data)

      let #(greater_than, less_than) = list.split(data, length / 2)
      // Always take the current node value from the right (less_than)
      // if the length is odd, it'll be the bigger list
      // if it's even it doesn't matter which one we take
      let assert [value, ..rest_less_than] = less_than
      BSTNode(
        value:,
        greater_than: reversed_list_to_binary_search_tree(greater_than),
        less_than: reversed_list_to_binary_search_tree(rest_less_than),
      )
    }
  }
}

pub fn col_in_row(row: BSTNode, search: Int) -> Bool {
  case row {
    Empty -> False
    BSTNode(value:, less_than:, greater_than:) -> {
      case in_range(value, search) {
        Lt -> col_in_row(less_than, search)
        Eq -> True
        Gt -> col_in_row(greater_than, search)
      }
    }
  }
}

fn in_range(range: #(Int, Int), x: Int) -> Order {
  let #(min, max) = range
  case x >= min {
    False -> Lt
    True ->
      case x <= max {
        True -> Eq
        False -> Gt
      }
  }
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
  let potential_intersections =
    vertical_edges
    |> list.filter({ is_intersecting_horizontal_ray(p, _) })

  // we need to count the number of times 2 vertical edges were connected on the same row as
  // the point, because we need to reduce that from the final count
  // but we only reduce if the horizontal ray
  let omitted_intersections =
    potential_intersections
    |> list.window_by_2()
    |> list.filter(fn(edges) {
      // by definition this is true, so we only need to compare one
      // edges.0.1.row == edges.1.0.row 
      { edges.0.1 }.row == p.row
    })
    |> echo as "omitted"

  potential_intersections
  |> list.length()
  |> int.subtract(list.length(omitted_intersections))
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

pub fn is_offset_point_on_edge(p: OffsetPoint, e: Edge) -> Bool {
  case edge_orientation(e) {
    Vertical ->
      p.col == { e.0 }.col
      && p.row |> is_between_float({ e.0 }.row, { e.1 }.row)
    _ -> panic as "wrong edge orientation for checking offset point"
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

fn is_between_float(x: Float, bound1: Int, bound2: Int) -> Bool {
  case bound1 < bound2 {
    True -> x <=. int.to_float(bound2) && x >=. int.to_float(bound1)
    False -> x <=. int.to_float(bound1) && x >=. int.to_float(bound2)
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

// hack for raycasting at 0.5 above current point
pub type OffsetPoint {
  OffsetPoint(col: Int, row: Float)
}

pub fn rectangle_area(p1: Point, p2: Point) -> Int {
  { int.absolute_value(p1.col - p2.col) + 1 }
  * { int.absolute_value(p1.row - p2.row) + 1 }
}

// prints grid with red tiles, but normalized for smallest rectangle that contains all red tiles
pub fn print_grid(
  top_left_corner: Point,
  bottom_right_corner: Point,
  inside_polygon: Set(Point),
) {
  list.range(top_left_corner.row, bottom_right_corner.row)
  |> list.each(fn(row) {
    list.range(top_left_corner.col, bottom_right_corner.col)
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

pub fn inside_polygon_dict(
  inside_polygon: Dict(Int, BSTNode),
  point: Point,
) -> Bool {
  let Point(col:, row:) = point

  inside_polygon
  |> dict.get(row)
  |> result.unwrap(Empty)
  |> col_in_row(col)
}

pub fn print_grid_with_bst(
  top_left_corner: Point,
  bottom_right_corner: Point,
  inside_polygon: Dict(Int, BSTNode),
) {
  list.range(top_left_corner.row, bottom_right_corner.row)
  |> list.each(fn(row) {
    list.range(top_left_corner.col, bottom_right_corner.col)
    |> list.each(fn(col) {
      let point_in_polygon =
        inside_polygon_dict(inside_polygon, Point(col:, row:))
      case point_in_polygon {
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
