import gleam/set
import day5b.{Range}
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn range_to_set_test() {
  assert day5b.range_to_set(Range(3, 5), set.new()) == set.from_list([3, 4, 5])
}
