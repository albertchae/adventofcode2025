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

  def solve(basis_vectors, target) do
    # Create problem - minimize the sum
    problem = Problem.new(direction: :minimize)

    num_vectors = length(basis_vectors)

    # Define variables - all non-negative integers
    {coefficients, problem} = 1..num_vectors
    |> Enum.map_reduce(problem, fn index, acc -> 
      {problem, coefficient} = Problem.new_variable(acc, "coefficient#{index}", min: 0.0,  type: :kInteger)
      {coefficient, problem}
    end)

    coefficients_by_index = coefficients
    |> Enum.with_index()
    |> Map.new(fn {value, index} -> {index, value} end)
    #|> IO.inspect()


    # Add constraints based on the vector equations
    problem = target
    |> Enum.with_index()
    |> Enum.reduce(problem, fn {value, target_index}, acc ->
      relevant_coefficients = basis_vectors
      |> Enum.with_index()
      |> Enum.map(fn {basis_vector, coefficient_index} -> 
        if Enum.at(basis_vector, target_index) == 1 do
          coefficient_index
        else
          -1
        end
      end)
      |> Enum.filter(fn (coefficient_index) ->
        coefficient_index != -1
      end)

      lhs = relevant_coefficients
      |> Enum.reduce(%Polynomial{}, fn coefficient_index, acc ->
        acc + Map.fetch!(coefficients_by_index, coefficient_index)
      end)

      acc 
      |> Problem.add_constraint(
        Constraint.new(lhs == value)
      )
    end)

    objective = coefficients
                |> Enum.reduce(%Polynomial{}, fn coefficient, acc -> 
                  acc + coefficient
                end)

    problem = problem
    |> Problem.increment_objective(objective)


    # Solve the problem
    {:ok, solution} = Dantzig.solve(problem)

    solution |> IO.inspect()

    solution.objective
  end

  def two() do
    2
  end
end