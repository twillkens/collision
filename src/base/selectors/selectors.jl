export GenoSelections

struct GenoSelections <: Selections
    elites::Vector{Genotype}
    singles::Vector{Genotype}
    couples::Vector{Tuple{Genotype, Genotype}}
end

function update_scorevec_dict!(key::String, score::Real,
        scoredict::Dict{String, Vector{Float64}})
    if key ∉ keys(scoredict)
        scoredict[key] = Float64[score] 
    else
        push!(scoredict[key], score)
    end
end

function update_scorevec_dict!(outcome::TestPairOutcome,
        scoredict::Dict{String, Vector{Float64}})
    update_scorevec_dict!(outcome.subject_key, outcome.score, scoredict)
end

function Dict{String, Vector{Float64}}(outcomes::Set{<:Outcome})
    scorevec_dict = Dict{String, Vector{Float64}}()
    [update_scorevec_dict!(outcome, scorevec_dict) for outcome in outcomes]
    scorevec_dict
end

function(s::Selector)(pops::Set{<:Population}, outcomes::Set{<:Outcome})
    Set([(s)(pop, outcomes) for pop in pops])
end

function get_scores(pop::GenoPop, outcomes::Set{<:Outcome})
    scorevec_dict = Dict{String, Vector{Float64}}(outcomes)
    genodict = Dict{String, Genotype}(pop)
    scores = [(genodict[key], sum(vec)) for (key, vec) in scorevec_dict if key in keys(genodict)]
    sort!(scores, by = r -> r[2], rev=true)
    genos = map(s -> s[1], scores)
    fitness = map(s -> s[2], scores)
    fitness = sum(fitness) == 0 ? map(s -> 1.0, fitness) : fitness
    genos, fitness
end

include("truncation.jl")
include("roulette.jl")