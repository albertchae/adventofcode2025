import day9b.{Horizontal, Point, Vertical, BSTNode, Empty}
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

pub fn reversed_list_to_binary_search_tree_test() {
  assert day9b.reversed_list_to_binary_search_tree([]) == Empty
  assert day9b.reversed_list_to_binary_search_tree([#(5, 6)]) == BSTNode(#(5, 6), Empty, Empty)
  assert day9b.reversed_list_to_binary_search_tree([#(10, 12), #(5, 6)]) == BSTNode(#(5, 6), Empty, BSTNode(#(10, 12), Empty, Empty))


  day9b.reversed_list_to_binary_search_tree([#(10, 12), #(5, 6), #(0, 2)]) |> echo

  day9b.reversed_list_to_binary_search_tree([#(40, 50), #(20, 30), #(10, 12), #(5, 6), #(0, 2)]) |> echo
}

pub fn col_in_row_test() {
  let bst = day9b.reversed_list_to_binary_search_tree([#(40, 50), #(20, 30), #(10, 12), #(5, 6), #(0, 2)])

  assert day9b.col_in_row(bst, 44)
  assert !day9b.col_in_row(bst, 54)
  assert day9b.col_in_row(bst, 20)
  assert day9b.col_in_row(bst, 30)
  assert day9b.col_in_row(bst, 11)
  assert !day9b.col_in_row(bst, 3)
}
