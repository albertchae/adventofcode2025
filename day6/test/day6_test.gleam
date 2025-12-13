import gleeunit

import gleam/list
import day6.{Add, Multiply, Number, OperatorElement}

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn transpose_test() {
  assert list.transpose([[1, 2], [3, 4]]) == [[1, 3], [2, 4]]
}

pub fn solve_problem_test() {
  assert day6.solve_problem([
      OperatorElement(day6.Add),
      Number(4),
      Number(2),
      Number(3),
    ])
    == 9

  assert day6.solve_problem([
      OperatorElement(day6.Multiply),
      Number(4),
      Number(2),
      Number(3),
    ])
    == 24
}

pub fn parse_input_test() {
  assert day6.parse_input("123 328  51 64 \n 45 64  387 23 \n*   +   *   +  ")
    == [
      [
        OperatorElement(Multiply),
        OperatorElement(Add),
        OperatorElement(Multiply),
        OperatorElement(Add),
      ],
      [Number(45), Number(64), Number(387), Number(23)],
      [Number(123), Number(328), Number(51), Number(64)],
    ]
}
