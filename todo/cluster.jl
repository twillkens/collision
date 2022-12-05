using Clustering
using Distances


function sparseness(X, D)
    V = []
    n = size(X, 2)
    for i in 1:n
        for j in 1:n 
            d_ij = D[i, j]
            denom = 0
            for l in 1:n
                denom += D[j, l]
            end
            push!(V, d_ij / denom)
        end
    end
    V
end


function minf(X, V, D, M)
    n = size(X, 2)
    F = []
    for i in 1:n
        v = V[i]
        d = 0
        for j in eachindex(M)
            d += euclidean(X[:, i], M[j])
        end
        push!(F, v / d)
    end
    minindex = findmin(F)[2]
    newm = X[:, minindex]
    newm
end


function global_kmeans(X)
    D = pairwise(Euclidean(), X, dims=2)
    V = sparseness(X, D)
    M = [X[:, findmin(V)[2]]]
    for k in 2:size(X, 2)
        

    end

end