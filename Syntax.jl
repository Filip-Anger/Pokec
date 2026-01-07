using SparseArrays
using LinearAlgebra

A = Matrix([1.0 2; 3 4])
n = 2
display(ones(2,1) * (1/2))
A[:,2] = ones(n, 1) * (1/n)
display(A)
