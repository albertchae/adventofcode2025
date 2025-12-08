import gleam/list
import day5.{Range}
import gleam/string
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn hello_world_test() {
  let name = "Joe"
  let greeting = "Hello, " <> name <> "!"

  assert greeting == "Hello, Joe!"
}



// [, "1\n5\n8\n11\n17\n32"]

pub fn parse_ranges_test() {
  let ranges = "3-5\n10-14\n16-20\n12-18"
               |> string.split("\n")

  assert day5.parse_ranges(ranges) == [Range(3, 5), Range(10, 14), Range(16, 20), Range(12, 18)] |> list.reverse()

}
