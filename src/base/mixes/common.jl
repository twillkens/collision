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
function Set{Set{Recipe}}(recipes::Set{<:Recipe}, n_subsets::Int)
    n_mix = div(length(recipes), n_subsets)
    recipe_vecs = collect(Iterators.partition(collect(recipes), n_mix))
    # If there are leftovers, divide the excess among the other subsets
    if length(recipe_vecs) > n_subsets
        excess = pop!(recipe_vecs)
        for i in eachindex(excess)
            push!(recipe_vecs[i], excess[i])
        end
    end
    Set([Set{Recipe}(rvec) for rvec in recipe_vecs])
end
