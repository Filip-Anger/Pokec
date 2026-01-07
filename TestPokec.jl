using SparseArrays

# from to
edges_data = [
    1 2
    1 3
    1 5
    1 6
    2 3
    3 1
    3 5
    4 1
    4 2
    4 5
    3 7
    6 4
    7 2
    3 8
    4 9
    8 5
    9 1
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

println(display(A))  # show as dense for small matrix
colSums = sum(A, dims=1)


# Make the matrix sparse but column sochastic

# INEFFICIENT WAY
# Make column sochastic and add teleportation to 0 cols
for i in 1:1:n
    if colSums[i] == 0
        A[:, i] = ones(n, 1) * (1/n)
    else
        A[:, i] /= colSums[i]
    end
end

# Teleportation to all
damping_factor = 0.85

G = A * damping_factor + ones(n,n) * ((1-damping_factor) / n)

# println("Matrix A:")
# display(A)
# println("Matrix G:")
# display(G)
# Do the random walk
# Start in arbitrary node, multiply till Ax = x - eigenvector for lambda = 1

function do_rank(it)
    xwalk = zeros(n, 1)
    xwalk[1] = 1

    for i in 1:1:it
        xwalk = G * xwalk
    end
    return xwalk
end

# 10 walks seem to be enought
@time begin
    display(do_rank(10^6))
end

