"""
Extracts the set of fields from a Mix
"""
function Set(mix::M) where {M <: Mix}
    Set([getfield(mix, fieldname) for fieldname in fieldnames(M)])
end

"""
Extracts the set of all fields from a set of Mixes
"""
function Set(mixes::Set{Mix})
    union([Set(mix) for mix in mixes]...)
end

"""
Used for dispatching Mixes to processes for evaluation.
Given the set of all Mixes of a Coevolution, divide them into `n` subsets where
`n` is the number of processes.
"""
function Set{Set{M}}(mixes::Set{M}, n_subsets::Int) where {M <: Mix}
    n_mix = div(length(mixes), n_subsets)
    mixvecs = collect(Iterators.partition(collect(mixes), n_mix))
    # If there are leftovers, divide the excess among the other subsets
    if length(mixvecs) > n_subsets
        excess = pop!(mixvecs)
        for i in eachindex(excess)
            push!(mixvecs[i], excess[i])
        end
    end
    Set([Set{M}(mixvec) for mixvec in mixvecs])
end
