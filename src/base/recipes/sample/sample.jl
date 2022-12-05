export SampleRecipe

struct SampleRecipe <: Recipe
    rng::AbstractRNG
    n_samples::Int
    n_processes::Int
end

function SampleRecipe(cfg::NamedTuple)
    SampleRecipe(cfg.rng, cfg.n_samples, cfg.n_processes)
end

function Set{M}(subjects::Population, tests::Population, recipe::SampleRecipe) where {M <: Mix}
    mixes = Set{M}()
    for o1 in subjects.orgs
        for o2 in sample(recipe.rng, collect(tests.orgs), recipe.n_samples, replace=false)
            mix = M(o1, o2)
            push!(mixes, mix)
        end
    end
    mixes
end

function Set{PairMix{String, D}}(pops::Set{<:Population}, recipe::Recipe) where {D <: Domain}
    if length(pops) != 2
        error("Invalid number of populations for PairMix type.")
    end
    pop1, pop2 = pops
    mixes1 = Set{PairMix{String, D}}(pop1, pop2, recipe)
    mixes2 = Set{PairMix{String, D}}(pop2, pop1, recipe)
    union(mixes1, mixes2)
end