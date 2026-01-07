using SparseArrays
using LinearAlgebra

nodes = 1632803
edges = 30622564

@time begin
    outdegree = zeros(Int, nodes)
    open("datasets/soc-pokec-relationships.txt", "r") do io
        for line in eachline(io)
            from, to = parse.(Int, split(line))
            outdegree[from] += 1
        end
    end
end

# Second pass: build matrix with normalized values
rows = Int[]  
cols = Int[]
vals = Float32[]
sizehint!(rows, edges)
sizehint!(cols, edges)
sizehint!(vals, edges)

@time begin
    open("datasets/soc-pokec-relationships.txt", "r") do io
        for line in eachline(io)
            from, to = parse.(Int, split(line))
            push!(rows, to)      # destination is row
            push!(cols, from)    # source is column
            if outdegree[from] != 0
                push!(vals, 1.0f0 / outdegree[from])  # Normalized!
            end
        end
    end
end

# Make sparse array
# 700k allocations, 800 Mib, 2 seconds
@time begin
    A = sparse(rows, cols, vals, nodes, nodes)
end
damping_factor = 0.85
sink = Float64.(outdegree .== 0) 
function do_rank(epsilon)
    x = ones(nodes) / nodes
    last_x = ones(nodes)
    iterations = 0
    while (norm((last_x - x), 1) > epsilon)
        # xwalk = G * xwalk
        # Not sparse -> matrix * vector O(n) = (2n - 1) * n = 2n^2 = n^2
        last_x = x

        # Since (A + Z)x = Ax + Zx
        x = ((A * x) + sink .* x) * damping_factor + ones(nodes, 1) * ((1-damping_factor) / nodes)
                # (ones(n,n) * xwalk) * ((1-damping_factor) / n)
                
        # matrix * vector, vector * scalar, vector + vector
        # A is sparse: say average degree is 10 -> A * x O(n) = 10n, vector * scalar O(n) = n
        # Vector addition O(n) = n
        # Ones are not sparse but ones(n, n) * xwalk gives vector of ones since xwalk is column sochastic
        # O(n) = kn, k based on how sparse A is
        # with 10000x10000 it was 50 times faster already
        iterations += 1
    end
    println("Sum is: ")
    println(sum(x))
    println("Iterations: ")
    println(iterations)
    return x
end

# 10 walks seem to be enought
@time begin
    final_x = do_rank(10^(-6))
end

@time begin
        open("datasets/eigenvector.txt", "w") do io
        for v in final_x
            println(io, v)
        end
    end
end