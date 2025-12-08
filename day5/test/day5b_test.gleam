import gleam/list
import gleam/set
import day5b.{Range}
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn range_to_set_test() {
  assert day5b.range_to_set(Range(3, 5), set.new()) == set.from_list([3, 4, 5])
}

pub fn coalesce_ranges_test() {
  assert day5b.coalesce_ranges([Range(1, 3), Range(4, 5)]) == [Range(1, 3), Range(4, 5)] |> list.reverse()
  assert day5b.coalesce_ranges([Range(1, 3), Range(3, 5)]) == [Range(1, 5)]

}
