export AllvsAllOrder

Base.@kwdef struct AllvsAllOrder{D <: Domain, S <: PhenoConfig, T <: PhenoConfig} <: PairOrder
    domain::D
    outcome::Type{<:Outcome}
    subjects_key::String
    subjects_cfg::S
    tests_key::String
    tests_cfg::T
end

function(o::AllvsAllOrder)(subjects::GenoPop, tests::GenoPop)
    pairs = unique(Set,
                   Iterators.filter(allunique,
                   Iterators.product(subjects.genos, tests.genos)))
    Set([PairRecipe(i, o, subject, test) for (i, (subject, test)) in enumerate(pairs)])
end
