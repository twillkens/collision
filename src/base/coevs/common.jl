"""
Extracts a combined dictionary of String keys and given Aspect values from all populations.
An aspect in the Basic framework is either a genotype or a phenotype
"""
function Dict{String, A}(coev::Coevolution) where {A <: Aspect}
    reduce(merge, [Dict{String, A}(pop) for pop in coev.pops])
end
