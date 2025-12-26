# this worked after downloading the right version of highs
require Dantzig.Problem, as: Problem
require Dantzig.Constraint, as: Constraint

require Dantzig.Polynomial, as: Polynomial

Polynomial.algebra do
  total_width = 300.0

  problem = Problem.new(direction: :maximize)
  {problem, left_margin} = Problem.new_variable(problem, "left_margin", min: 0.0)
  {problem, center} = Problem.new_variable(problem, "center", min: 0.0)
  {problem, right_margin} = Problem.new_variable(problem, "right_margin", min: 0.0)
  IO.inspect left_margin
  IO.inspect center
  IO.inspect right_margin

  problem =
    problem
    |> Problem.add_constraint(
      Constraint.new(left_margin + center + right_margin == total_width)
    )
    |> Problem.increment_objective(center - left_margin - right_margin)
end

solution = Dantzig.solve!(problem)

IO.inspect solution