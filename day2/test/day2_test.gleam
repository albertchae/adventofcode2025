import gleeunit

import day2

pub fn main() -> Nil {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn halve_string_test() {
  assert day2.halve_string("Joe") == #("J", "oe")

  assert day2.halve_string("abcd") == #("ab", "cd")
}

pub fn is_repeated_num_test() {
  assert day2.is_repeated_num(11) == True
  assert day2.is_repeated_num(12) == False
  assert day2.is_repeated_num(111) == False
  assert day2.is_repeated_num(1212) == True
}

pub fn find_repeated_in_range_test() {
  assert day2.find_repeated_in_range(11, 22) == [11, 22]
  assert day2.find_repeated_in_range(95, 115) == [99]
  assert day2.find_repeated_in_range(1188511880, 1188511890) == [1188511885]
}

pub fn find_repeated_multiple_ranges_test() {
  assert day2.find_repeated_multiple_ranges([#(11, 22), #(95, 115)]) == [[11, 22], [99]]
}

pub fn sum_nested_test() {
  assert day2.sum_nested([[11, 22], [99]]) == 132
}

pub fn parse_range_string_test() {
  assert day2.parse_range_string("11-99") == #(11, 99)
}

pub fn parse_comma_separated_ranges_test() {
  assert day2.parse_comma_separated_ranges("11-22,95-115") == [#(11, 22), #(95, 115)]

}
