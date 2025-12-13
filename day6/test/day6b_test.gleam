import gleeunit

import day6b.{Add, Multiply}
import gleam/list

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn transpose_test() {
  assert list.transpose([[1, 2], [3, 4]]) == [[1, 3], [2, 4]]
}

pub fn solve_problem_test() {
  assert day6b.solve_problem(day6b.Add, [
      4,
      2,
      3,
    ])
    == 9

  assert day6b.solve_problem(Multiply, [
      4,
      2,
      3,
    ])
    == 24
}

pub fn parse_input_test() {
  assert day6b.parse_input("123 328  51 64 \n 45 64  387 23 \n*   +   *   +  ")
    == #(
      [
        [" 45", "64 ", "387", "23 "],
        ["123", "328", " 51", "64 "],
      ],
      [
        Multiply,
        Add,
        Multiply,
        Add,
      ],
    )
}

pub fn parse_operator_row_test() {
  let test_operator_row_1 = "*   * "
  let #(operators_1, digits_1) = day6b.parse_operator_row(test_operator_row_1)
  assert operators_1
    == [
      Multiply,
      Multiply,
    ]
  assert digits_1 == [3, 2]

  let test_operator_row_2 = "*   *  +  *  *   *   +  +    +   "
  let #(operators_2, digits_2) = day6b.parse_operator_row(test_operator_row_2)
  assert operators_2
    == [
      Multiply,
      Multiply,
      Add,
      Multiply,
      Multiply,
      Multiply,
      Add,
      Add,
      Add,
    ]
  assert digits_2 == [3, 2, 2, 2, 3, 3, 2, 4, 4]
}

pub fn split_before_operator_test() {
  assert day6b.split_before_operator("*   * ") == ["*  ", "* "]
  assert day6b.split_before_operator("*   *  +  *  *   *   +  +   +   ")
    == ["*  ", "* ", "+ ", "* ", "*  ", "*  ", "+ ", "+  ", "+   "]
}

pub fn split_row_by_digit_lengths_test() {
  assert day6b.split_row_by_digit_lengths(" 45 64  387 23 ", [3, 3, 3, 3])
    == [" 45", "64 ", "387", "23 "]
}

pub fn read_column_vertically_test() {
  assert day6b.read_column_vertically(["123", " 45", "  6"]) == [1, 24, 356]

}
