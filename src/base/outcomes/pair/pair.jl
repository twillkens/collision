export PairOutcome
export RouletteSelector, FitnessRecord, PopRecord
export SelectionResults, BitstringReproducer
export TruncationSelector

"""
Returns a score representing the outcome of an interaction between two entities.
These are the results from evaluation over a process.
They may be collected and processed on the main process to perform selection.
"""
struct PairOutcome{S <: Union{Real, Nothing}, T <: Union{Real, Nothing}} <: Outcome
    subject_key::String
    test_key::String
    subject_score::S
    test_score::T
end

"""
Extracts the 
"""
function PairOutcome(mix::PairMix)
    PairOutcome(mix.domain, mix.subject, mix.test)
end

"""

"""
function Set{PairOutcome}(mixset::Set{<:PairMix})
    Set([PairOutcome(mix) for mix in mixset])
end



struct GenoSelections <: Selections
    key::String
    curr_id::Int
    elites::Vector{Genotype}
    singles::Vector{Genotype}
    couples::Vector{Tuple{Genotype, Genotype}}
end

function update_scorevec_dict!(key::String, score::Union{Real, Nothing},
                               scoredict::Dict{String, Vector{Float64}})
    if score !== nothing
        if key ∉ keys(scoredict)
            scoredict[key] = Float64[score] 
        else
            push!(scoredict[key], score)
        end
    end
end

function update_scorevec_dict!(outcome::PairOutcome, scoredict::Dict{String, Vector{Float64}})
    update_scorevec_dict!(outcome.subject_key, outcome.subject_score, scoredict)
    update_scorevec_dict!(outcome.test_key, outcome.test_score, scoredict)
end

function Dict{String, Vector{Float64}}(outcomes::Set{<:Outcome})
    scorevec_dict = Dict{String, Vector{Float64}}()
    [update_scorevec_dict!(outcome, scorevec_dict) for outcome in outcomes]
    scorevec_dict
end

function pselection(rng::AbstractRNG, prob::Vector{<:Real}, N::Int)
    cp = cumsum(prob)
    selected = Array{Int}(undef, N)
    for i in 1:N
        j = 1
        r = rand(rng)
        while cp[j] < r
            j += 1
        end
        selected[i] = j
    end
    return selected
end

function roulette(fitness::Vector{<:Real}, N::Int;
                  rng::AbstractRNG)
    absf = abs.(fitness)
    prob = absf./sum(absf)
    return pselection(rng, prob, N)
end

function get_scores(pop::GenoPop, outcomes::Set{<:Outcome})
    scorevec_dict = Dict{String, Vector{Float64}}(outcomes)
    genodict = Dict{String, Genotype}(pop)
    scores = [(genodict[key], sum(vec)) for (key, vec) in scorevec_dict]
    sort!(scores, by = r -> r[2], rev=true)
    genos = map(s -> s[1], scores)
    fitness = map(s -> s[2], scores)
    fitness = sum(fitness) == 0 ? map(s -> 1.0, fitness) : fitness
    genos, fitness
end

Base.@kwdef struct RouletteSelector <: Selector
    key::String
    rng::AbstractRNG
    n_elite::Int
    n_singles::Int
    n_couples::Int
end

function(r::RouletteSelector)(pop::Population, outcomes::Set{<:Outcome})
    rng, n_elite, n_singles, n_couples = r.rng, r.n_elite, r.n_singles, r.n_couples
    genos, fitness = get_scores(pop, outcomes)
    elites = [genos[i] for i in 1:n_elite]
    singles = [genos[i] for i in roulette(fitness, n_singles; rng = rng)]
    idxs = roulette(fitness, n_couples * 2; rng = rng)
    couples = [(genos[idxs[i]], genos[idxs[i + 1]]) for i in 1:2:length(idxs)]
    GenoSelections(pop.key, pop.curr_id, elites, singles, couples)
end


Base.@kwdef struct TruncationSelector <: Selector
    key::String
    rng::AbstractRNG
    n_keep::Int
    n_elite::Int
    n_singles::Int
    n_couples::Int
end

function(r::TruncationSelector)(pop::Population, outcomes::Set{<:Outcome})
    rng, n_elite, n_singles, n_couples = r.rng, r.n_elite, r.n_singles, r.n_couples
    genos, _ = get_scores(pop, outcomes)
    elites = [genos[i] for i in 1:n_elite]
    genos = genos[1:r.n_keep]
    singles = [rand(rng, genos) for i in 1:n_singles]
    couples = [(rand(genos), rand(genos)) for i in 1:n_couples]
    GenoSelections(pop.key, pop.curr_id, elites, singles, couples)
end

function(s::Selector)(pops::Set{<:Population}, outcomes::Set{<:Outcome})
    Set([(s)(pop, outcomes) for pop in pops])
end

function(r::Reproducer)(popkey::String, curr_id::Int, singles::Vector{Genotype})
    children = Set{Genotype}()
    for parent in singles
        childkey = join([popkey, curr_id], KEY_SPLIT_TOKEN)  
        child = (r)(childkey, parent)
        push!(children, child)
        curr_id += 1
    end
    children, curr_id
end

function(r::Reproducer)(popkey::String, curr_id::Int,
                                 couples::Vector{Tuple{Genotype, Genotype}})
    children = Set{Genotype}()
    for (mother, father) in couples
        childkey = join([popkey, curr_id], KEY_SPLIT_TOKEN)  
        child = (r)(childkey, mother, father)
        push!(children, child)
        curr_id += 1
    end
    children, curr_id
end

function(r::Reproducer)(selections::GenoSelections)
    key, curr_id = selections.key, selections.curr_id
    elites = selections.elites
    children1, curr_id = (r)(key, curr_id, selections.singles)
    children2, curr_id = (r)(key, curr_id, selections.couples)
    nextgen = Set(union(elites, children1, children2))
    GenoPop(key, curr_id, nextgen)
end

function(r::Reproducer)(selections::Set{<:Selections})
    Set([(r)(selection) for selection in selections])
end