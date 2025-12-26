import numpy as np
from scipy.optimize import milp, LinearConstraint, Bounds

a = np.array([[0, 0, 0, 0, 1, 1], 
              [0, 1, 0, 0, 0, 1], 
              [0, 0, 1, 1, 1, 0], 
              [1, 1, 0, 1, 0, 0]])
b = np.array([3, 5, 4, 7])


a = np.array([[1, 0, 1, 1, 0], 
              [0, 0, 0, 1, 1], 
              [1, 1, 0, 1, 1], 
              [1, 1, 0, 0, 1],
              [1, 0, 1, 0, 1]])
b = np.array([7, 5, 12, 7, 2])

# Objective: minimize sum of coefficients
c = np.ones(5)  # minimize x1 + x2 + x3 + x4 + x5 + x6
integrality = np.ones(5)  # 1 means integer

# Constraints: A @ x = b
constraints = LinearConstraint(a, lb=b, ub=b)

# Bounds: x >= 0
bounds = Bounds(lb=0, ub=np.inf)

# Integrality: all variables must be integers

# Solve
result = milp(c=c, constraints=constraints, bounds=bounds, integrality=integrality)

print("Status:", result.message)
print("Optimal solution:", result.x)
print("Minimum sum:", result.fun)
print("Verification:", a @ result.x)