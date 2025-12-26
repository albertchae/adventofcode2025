require Dantzig.Problem, as: Problem
require Dantzig.Constraint, as: Constraint
require Dantzig.Polynomial, as: Polynomial
use Dantzig.Polynomial.Operators

defmodule VectorCombinationSolver do
  @moduledoc """
  Solves the minimal positive integer linear combination problem using Dantzig.

  Find coefficients c1, c2, c3, c4, c5, c6 such that:
  c1*[0,0,0,1] + c2*[0,1,0,1] + c3*[0,0,1,0] + c4*[0,0,1,1] + c5*[1,0,1,0] + c6*[1,1,0,0] = [3,5,4,7]

  Minimizing: sum of all coefficients
  """

  def solve do

    IO.puts("\n" <> String.duplicate("=", 60))
    IO.puts("Vector Linear Combination Solver")
    IO.puts(String.duplicate("=", 60))
    IO.puts("\nProblem:")
    IO.puts("Find c1, c2, c3, c4, c5, c6 such that:")
    IO.puts("  c1*[0,0,0,1] + c2*[0,1,0,1] + c3*[0,0,1,0] +")
    IO.puts("  c4*[0,0,1,1] + c5*[1,0,1,0] + c6*[1,1,0,0] = [3,5,4,7]")
    IO.puts("\nMinimizing: c1 + c2 + c3 + c4 + c5 + c6")
    IO.puts("\nConstraints:")
    IO.puts("  c5 + c6 = 3")
    IO.puts("  c2 + c6 = 5")
    IO.puts("  c3 + c4 + c5 = 4")
    IO.puts("  c1 + c2 + c4 = 7")
    IO.puts("  All ci >= 0, ci integer")

    # Create problem - minimize the sum
    problem = Problem.new(direction: :minimize)

    # Define variables - all non-negative integers
    {problem, c1} = Problem.new_variable(problem, :c1, min: 0.0,  type: :integer)
    {problem, c2} = Problem.new_variable(problem, :c2, min: 0.0,  type: :integer)
    {problem, c3} = Problem.new_variable(problem, :c3, min: 0.0,  type: :integer)
    {problem, c4} = Problem.new_variable(problem, :c4, min: 0.0,  type: :integer)
    {problem, c5} = Problem.new_variable(problem, :c5, min: 0.0,  type: :integer)
    {problem, c6} = Problem.new_variable(problem, :c6, min: 0.0,  type: :integer)

    IO.inspect c1
    IO.inspect c2
    IO.inspect c3
    IO.inspect c3
    IO.inspect c5
    IO.inspect c5

    # Add constraints based on the vector equations
    # Row 1: 0*c1 + 0*c2 + 0*c3 + 0*c4 + 1*c5 + 1*c6 = 3
    problem =
      problem
      |> Problem.add_constraint(
        Constraint.new(c5 + c6 == 3)
      )
    # Row 2: 0*c1 + 1*c2 + 0*c3 + 0*c4 + 0*c5 + 1*c6 = 5
      |> Problem.add_constraint(Constraint.new(c2 + c6 == 5))

    # Row 3: 0*c1 + 0*c2 + 1*c3 + 1*c4 + 1*c5 + 0*c6 = 4
      |> Problem.add_constraint(Constraint.new(c3 + c4 + c5 == 4))

    # Row 4: 1*c1 + 1*c2 + 0*c3 + 1*c4 + 0*c5 + 0*c6 = 7
      |> Problem.add_constraint(Constraint.new(c1 + c2 + c4 == 7))

    # Objective: minimize sum of all coefficients
      |> Problem.increment_objective(c1 + c2 + c3 + c4 + c5 + c6)


    IO.puts("\n" <> String.duplicate("-", 60))
    IO.puts("Solving MILP...")
    IO.puts(String.duplicate("-", 60))

    # Solve the problem
    solution = Dantzig.solve(problem)

    solution
    |> IO.inspect()
  end
end


# Run the solver
VectorCombinationSolver.solve()