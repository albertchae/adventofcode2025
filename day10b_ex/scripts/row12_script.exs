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
    {problem, c7} = Problem.new_variable(problem, :c7, min: 0.0,  type: :integer)
    {problem, c8} = Problem.new_variable(problem, :c8, min: 0.0,  type: :integer)
    {problem, c9} = Problem.new_variable(problem, :c9, min: 0.0,  type: :integer)
    {problem, c10} = Problem.new_variable(problem, :c10, min: 0.0,  type: :integer)
    {problem, c11} = Problem.new_variable(problem, :c11, min: 0.0,  type: :integer)
    {problem, c12} = Problem.new_variable(problem, :c12, min: 0.0,  type: :integer)

    # Add constraints based on the vector equations
    problem =
      problem
      |> Problem.add_constraint(
        Constraint.new(c2 + c3 + c4 + c5+ c6 + c8 + c9 + c12 == 80)
      )
      |> Problem.add_constraint(
        Constraint.new(c1 + c3 + c4 + c5 + c6 + c7 + c8 + c9 + c10 == 84)
      )
      |> Problem.add_constraint(
        Constraint.new(c1+c4+c5+c7+c8+c9+c11==170)
      )
      |> Problem.add_constraint(
        Constraint.new(c1+c3+c5+c7+c8+c12 == 58)
      )

      |> Problem.add_constraint(
        Constraint.new(c1+c3+c4+c6+c8+c9+c11+c12 == 195)
      )
      |> Problem.add_constraint(
        Constraint.new(c1+c5+c7+c9+c10+c11 == 162)
      )

      |> Problem.add_constraint(
        Constraint.new(c1+c4+c5+c7+c11+c12 == 158)
      )
      |> Problem.add_constraint(
        Constraint.new(c3+c4+c5+c7+c8+c9+c10+c11+c12 == 197)
      )
      |> Problem.add_constraint(
        Constraint.new(c1+c3+c6+c8+c11 == 169)
      )
      |> Problem.add_constraint(
        Constraint.new(c1+c3+c5+c7+c8+c9+c10+c11 == 185)
      )
      |> Problem.increment_objective(c1 + c2 + c3 + c4 + c5 + c6 + c7 + c8 + c9 + c10 + c11 + c12)


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