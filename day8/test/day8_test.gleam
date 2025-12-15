import day8.{Point}
import gleam/dict
import gleam/float
import gleam/order
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn euclidean_distance_test() {
  assert float.loosely_equals(
    day8.euclidean_distance(Point(162, 817, 812), Point(425, 690, 689)),
    316.902,
    0.001,
  )
}

pub fn compare_test() {
  assert day8.compare(Point(1, 1, 1), Point(1, 1, 1)) == order.Eq
  assert day8.compare(Point(1, 1, 1), Point(1, 1, 2)) == order.Lt
  assert day8.compare(Point(1, 1, 2), Point(1, 1, 1)) == order.Gt
  assert day8.compare(Point(1, 5, 1), Point(1, 1, 15)) == order.Gt
  assert day8.compare(Point(1, 5, 1), Point(1, 6, 15)) == order.Lt
}

pub fn build_distance_dict_test() {
  assert day8.build_distance_dict([
      Point(162, 817, 812),
      Point(57, 618, 57),
      Point(906, 360, 560),
    ])
    == dict.from_list([
      #(#(Point(57, 618, 57), Point(162, 817, 812)), 787.814064357828),
      #(#(Point(57, 618, 57), Point(906, 360, 560)), 1019.9872548223335),
      #(#(Point(162, 817, 812), Point(906, 360, 560)), 908.7843528582565),
    ])
}

pub fn shortest_distance_test() {
  assert day8.shortest_distances(
      dict.from_list([
        #(#(Point(57, 618, 57), Point(162, 817, 812)), 787.814064357828),
        #(#(Point(57, 618, 57), Point(906, 360, 560)), 1019.9872548223335),
        #(#(Point(162, 817, 812), Point(906, 360, 560)), 908.7843528582565),
      ]),
    )
    == [
      #(Point(57, 618, 57), Point(162, 817, 812)),
      #(Point(162, 817, 812), Point(906, 360, 560)),
      #(Point(57, 618, 57), Point(906, 360, 560)),
    ]
}

pub fn parse_point_string_test() {
  assert day8.parse_point_string("941,993,340") == Point(941, 993, 340)
}

pub fn initialize_circuit_dict_test() {
  assert day8.initialize_point_to_circuit_dict([
      Point(162, 817, 812),
      Point(57, 618, 57),
      Point(906, 360, 560),
    ])
    == dict.from_list([
      #(Point(162, 817, 812), "1"),
      #(Point(57, 618, 57), "2"),
      #(Point(906, 360, 560), "3"),
    ])
}
