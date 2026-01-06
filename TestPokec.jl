using SparseArrays

# from to
edges_data = [
    1 2
    1 3
    1 5
    2 3
    2 5
    3 1
    3 4
    3 5
    4 1
    4 2
    4 5
]
#        from 
#    |        1 |
# to |1         |
#    |1         |
# 3 1; 1 2; 1 3

from = edges_data[:, 1]
to = edges_data[:, 2]
vals = ones(Float32, size(edges_data, 1))

n = max(maximum(from), maximum(to))
A = sparse(to, from, vals, n, n)
# sparse (rows, cols, what is there when they have edge, size)

println("Matrix A:")
println(display(A))  # show as dense for small matrix
println("\nColumn sums:")
println(sum(A, dims=1))

