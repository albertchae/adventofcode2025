import gleeunit

import day2b

pub fn main() -> Nil {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn halve_string_test() {
  assert day2b.halve_string("Joe") == #("J", "oe")

  assert day2b.halve_string("abcd") == #("ab", "cd")
}

pub fn is_invalid_with_repeated_test() {
  assert day2b.is_invalid_with_repeated(11) == True
  assert day2b.is_invalid_with_repeated(12) == False
  assert day2b.is_invalid_with_repeated(111) == True
  assert day2b.is_invalid_with_repeated(1212) == True
}

pub fn find_invalid_in_range_test() {
  assert day2b.find_invalid_in_range(11, 22) == [11, 22]
  assert day2b.find_invalid_in_range(95, 115) == [99, 111]
  assert day2b.find_invalid_in_range(1188511880, 1188511890) == [1188511885]
}

pub fn find_invalid_multiple_ranges_test() {
  assert day2b.find_invalid_multiple_ranges([#(11, 22), #(95, 115)]) == [[11, 22], [99, 111]]
}

pub fn sum_nested_test() {
  assert day2b.sum_nested([[11, 22], [99]]) == 132
}

pub fn parse_range_string_test() {
  assert day2b.parse_range_string("11-99") == #(11, 99)
}

pub fn parse_comma_separated_ranges_test() {
  assert day2b.parse_comma_separated_ranges("11-22,95-115") == [#(11, 22), #(95, 115)]

}

pub fn repeated_substring_test() {
  assert day2b.repeated_substring("111", 1) == True
  assert day2b.repeated_substring("1188511885", 1) == True
  assert day2b.repeated_substring("565656", 1) == True
  assert day2b.repeated_substring("5656567", 1) == False
}
