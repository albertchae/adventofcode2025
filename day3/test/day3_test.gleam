import gleeunit

import day3

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn find_largest_digit_test() {
  assert day3.find_largest_digit("987654321111111") == 9
  assert day3.find_largest_digit("811111111111119") == 9
  assert day3.find_largest_digit("81111111111111") == 8
}

pub fn find_largest_2digit_joltage_test() {
  assert day3.find_largest_2digit_joltage("987654321111111") == 98
  assert day3.find_largest_2digit_joltage("811111111111119") == 89
  assert day3.find_largest_2digit_joltage("234234234234278") == 78
  assert day3.find_largest_2digit_joltage("818181911112111") == 92
}


pub fn find_largest_n_digit_joltage_test() {
  assert day3.find_largest_n_digit_joltage("987654321111111", 12, 0) == 987654321111
  assert day3.find_largest_n_digit_joltage("811111111111119", 12, 0) == 811111111119
  assert day3.find_largest_n_digit_joltage("234234234234278", 12, 0) == 434234234278
  assert day3.find_largest_n_digit_joltage("818181911112111", 12, 0) == 888911112111
}
