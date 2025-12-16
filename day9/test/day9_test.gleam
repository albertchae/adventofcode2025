import day9.{Point}
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}


pub fn rectangle_area_test() {

  assert day9.rectangle_area(Point(2, 5), Point(9, 7)) == 24
  assert day9.rectangle_area(Point(7, 1), Point(11, 7)) == 35
  assert day9.rectangle_area(Point(7, 3), Point(2, 3)) == 6
  assert day9.rectangle_area(Point(2, 5), Point(11, 1)) == 50

}
