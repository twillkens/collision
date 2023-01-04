export SamplerOrder

Base.@kwdef struct SamplerOrder{D <: Domain, S <: PhenoConfig, T <: PhenoConfig} <: PairOrder
    domain::D
    outcome::Type{<:Outcome}
    subjects_key::String
    subjects_cfg::S
    tests_key::String
    tests_cfg::T
    n_samples::Int
    rng::AbstractRNG
end

function(o::SamplerOrder)(subjects::GenoPop, tests::GenoPop)
    recipes = Set{Recipe}()
    i = 1
    for subject in subjects.genos
        for test in sample(o.rng, collect(tests.genos), o.n_samples, replace=true)
            recipe = PairRecipe(i, o, subject, test)
            push!(recipes, recipe)
            i += 1
        end
    end
    recipes
end