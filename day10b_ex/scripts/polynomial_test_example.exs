# this worked after downloading the right version of highs
require Dantzig.Problem, as: Problem
require Dantzig.Constraint, as: Constraint

require Dantzig.Polynomial, as: Polynomial

Polynomial.algebra do
  problem = Problem.new(direction: :maximize)
  {problem, x} = Problem.new_variable(problem, "x", min: -2.0, max: 2.0)
  IO.inspect x
  problem = Problem.increment_objective(problem, x - x * x)
end

solution = Dantzig.solve!(problem)

IO.inspect solution
