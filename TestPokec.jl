using SparseArrays

# from to
# edges_data = [
#     1 2
#     1 3
#     1 5
#     1 6
#     2 3
#     3 1
#     3 5
#     4 1
#     4 2
#     4 5
#     3 7
#     6 4
#     7 2
#     3 8
#     4 9
#     8 5
#     9 1
# ]
#        from 
#    |        1 |
# to |1         |
#    |1         |
# 3 1; 1 2; 1 3

# from = edges_data[:, 1]
# to = edges_data[:, 2]
# vals = ones(Float32, size(edges_data, 1))

# n = max(maximum(from), maximum(to))
# A = sparse(to, from, vals, n, n)

function setup(n)
    num_edges = 2 * n
    rows = rand(1:n, num_edges)
    cols = rand(1:n, num_edges)
    vals = ones(num_edges)  # All 1s
    A = sparse(rows, cols, vals, n, n)
    return A
end

n = 5
@time begin
    A = setup(n)  
end
# print(ones(1,n) * (A * ones(n, 1)))
# sparse (rows, cols, what is there when they have edge, size)



# Make the matrix sparse but column sochastic

# INEFFICIENT WAY
# Make column sochastic and add teleportation to 0 cols
colSums = sum(A, dims=1)
@time begin
    for i in 1:1:n
        if colSums[i] == 0
            A[:, i] = ones(n, 1) * (1/n)
        else
            A[:, i] /= colSums[i]
        end
    end
end

# Teleportation to all
damping_factor = 0.85

G = A * damping_factor + ones(n,n) * ((1-damping_factor) / n)
# This is not sparse any more!

# println("Matrix A:")
# display(A)
# println("Matrix G:")
# display(G)

# Start in arbitrary node, multiply till Ax = x - eigenvector for lambda = 1

function do_rank(it)
    xwalk = zeros(n, 1)
    xwalk[1] = 1

    for i in 1:1:it
        # xwalk = G * xwalk
        # Not sparse -> matrix * vector O(n) = (2n - 1) * n = 2n^2 = n^2

        # Since (A + Z)x = Ax + Zx
        xwalk = (A * xwalk) * damping_factor + ones(n, 1) * ((1-damping_factor) / n)
                # (ones(n,n) * xwalk) * ((1-damping_factor) / n)
                
        # matrix * vector, vector * scalar, vector + vector
        # A is sparse: say average degree is 10 -> A * x O(n) = 10n, vector * scalar O(n) = n
        # Vector addition O(n) = n
        # Ones are not sparse but ones(n, n) * xwalk gives vector of ones since xwalk is column sochastic
        # O(n) = kn, k based on how sparse A is
        # with 10000x10000 it was 50 times faster already
    end
    return xwalk
end

# 10 walks seem to be enought
@time begin
    display(do_rank(10))
end

