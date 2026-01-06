using SparseArrays
using LinearAlgebra

nodes = 1632803
edges = 30622564

rows = Int[]
cols = Int[]
vals = Float32[]

sizehint!(rows, edges)
sizehint!(cols, edges)
sizehint!(vals, edges)

# Load into arrays
# 200M allocations: 8 Gib, 9 seconds
@time begin
    open("soc-pokec-relationships.txt", "r") do io
        for line in eachline(io)
            from,to = parse.(Int, split(line))
            push!(rows, from)
            push!(cols, to)
            push!(vals, 1.0f0)
        end
    end
end

# Make sparse array
# 700k allocations, 800 Mib, 2 seconds
@time begin
    n = max(maximum(rows), maximum(cols))

    A = sparse(rows, cols, vals, n, n)
end

display(A[1:10, 1:10])

outdeg = sum(A, dims=1)
outdeg = vec(outdeg)

n = size(A, 1)
x = fill(1.0f0 / n, n)
x_new = similar(x)


# function pagerank_step!(x_new, A, x, outdeg, p)
#     n = length(x)
#     fill!(x_new, 0.0f0)

#     sink_mass = 0.0f0

#     @inbounds for j in 1:n
#         if outdeg[j] == 0
#             sink_mass += x[j]
#         else
#             contrib = p * x[j] / outdeg[j]
#             for ptr in A.colptr[j]:(A.colptr[j+1]-1)
#                 i = A.rowval[ptr]
#                 x_new[i] += contrib
#             end
#         end
#     end

#     # distribute sink mass + teleportation
#     x_new .+= (p * sink_mass + (1 - p)) / n
# end

# p = 0.85f0
# tol = 1e-6
# maxiter = 100

# for iter in 1:maxiter
#     pagerank_step!(x_new, A, x, outdeg, p)

#     if norm(x_new - x, 1) < tol
#         println("Converged in ", iter, " iterations")
#         break
#     end
#     tmp = x
#     x = x_new
#     x_new = tmp
# end