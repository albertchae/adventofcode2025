import day9b.{Horizontal, Point, Vertical}
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn rectangle_area_test() {
  assert day9b.rectangle_area(Point(2, 5), Point(9, 7)) == 24
  assert day9b.rectangle_area(Point(7, 1), Point(11, 7)) == 35
  assert day9b.rectangle_area(Point(7, 3), Point(2, 3)) == 6
  assert day9b.rectangle_area(Point(2, 5), Point(11, 1)) == 50
}

pub fn is_point_on_edge_test() {
  // horizontal
  assert day9b.is_point_on_edge(Point(7, 1), #(Point(7, 1), Point(11, 1)))
  assert day9b.is_point_on_edge(Point(11, 1), #(Point(7, 1), Point(11, 1)))
  assert !day9b.is_point_on_edge(Point(6, 1), #(Point(7, 1), Point(11, 1)))
  assert !day9b.is_point_on_edge(Point(12, 1), #(Point(7, 1), Point(11, 1)))
  assert day9b.is_point_on_edge(Point(9, 1), #(Point(7, 1), Point(11, 1)))
  assert !day9b.is_point_on_edge(Point(0, 0), #(Point(7, 1), Point(11, 1)))

// vertical
  assert day9b.is_point_on_edge(Point(2, 3), #(Point(2, 5), Point(2, 3)))
  assert day9b.is_point_on_edge(Point(2, 5), #(Point(2, 5), Point(2, 3)))
  assert !day9b.is_point_on_edge(Point(2, 2), #(Point(2, 5), Point(2, 3)))
  assert !day9b.is_point_on_edge(Point(2, 6), #(Point(2, 5), Point(2, 3)))
  assert day9b.is_point_on_edge(Point(2, 4), #(Point(2, 5), Point(2, 3)))
  assert !day9b.is_point_on_edge(Point(0, 0), #(Point(2, 5), Point(2, 3)))
}

pub fn edge_orientation_test() {
  assert day9b.edge_orientation(#(Point(7, 1), Point(11, 1))) == Horizontal
  assert day9b.edge_orientation(#(Point(11, 1), Point(11, 7))) == Vertical
}
