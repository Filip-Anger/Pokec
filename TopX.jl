nodes = 1632803
eig = Float64[]
sizehint!(eig, nodes)

open("datasets/eigenvector.txt", "r") do io
    for line in eachline(io)
        push!(eig, parse(Float64, line))
    end
end

k = 10
idx = partialsortperm(eig, 1:k; rev=true)
top = [(i, eig[i]) for i in idx]

profiles = Vector{SubString{String}}[]
open("datasets/soc-pokec-profiles.txt", "r") do io
    i = 1
    for line in eachline(io)
        if i in idx
            l = split(line, '\t')
            push!(profiles, l)
        end
        i += 1
    end
end

for i in 1:1:2
    p = profiles[i][2]
    print(p)
    # if p[4]
    #     gender = "Man"
    # else
    #     gender = "Woman"
    # end
    # println("Rank: ", i)
    # println("Gender: ", gender)
end