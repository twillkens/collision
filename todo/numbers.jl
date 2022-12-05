using StatsBase

abstract type Entity end
abstract type Genotype end
abstract type Phenotype end
abstract type Atom <: Entity end
abstract type Statistics end
abstract type Mix end
abstract type Outcome end
abstract type Population{E <: Entity} <: Entity end
abstract type Coevolution <: Entity end

String = String

struct ScalarOutcome{T <: Real} <: Outcome
    solution::String
    test::String
    score::T
end

struct NGOrgStats <: Statistics
    subjective_fitness::Int
    objective_fitness::Int
end

struct BasicGeno{G} <: Genotype
    key::String
    genes::G
end

struct BasicPheno{T} <: Phenotype
    key::String
    traits::T
end

abstract type TestMix <: Mix end
abstract type NGMix <: TestMix end

struct NG1Mix <: NGMix
    solution::String
    test::String
end

struct NG2Mix <: NGMix
    solution::String
    test::String
end

struct NG3Mix <: NGMix
    solution::String
    test::String
end

struct Org{G <: Genotype,
           P <: Phenotype} <: Atom
    key::String
    geno::BasicGeno{G}
    pheno::BasicPheno{P}
    outcomes::Set{Outcome}
    stats::Set{Statistics}
    Org(key, geno, pheno) = new(key, geno, pheno, Set(), Set())
end

function NG1Org(key::EntityString)
    bits = rand(Bool, 10)
    geno = BasicGeno(key, bits)
    pheno = BasicPheno(key, sum(bits))
    Org(key, geno, pheno)
end


function stir(::NG1Mix, body1::BasicPheno{Int}, body2::BasicPheno{Int})
    body1 > body2 ? 1 : 0
end


function stir(mix::TestMix, phenos::Dict{EntityString, Phenotype})
    solution = phenos[mix.solution]
    test = phenos[mix.test]
    score = stir(mix, solution, test)
    ScalarOutcome(solution.key, test.key, score)
end

function stir(mixes::Set{Mix}, phenos::Dict{EntityString, Phenotype})
    outcomes = Set{ScalarOutcome}()
    for mix in mixes
        o = stir(mix, phenos)
        push!(outcomes, o)
    end
    outcomes
end


struct StatFeatures
    mean::Float64
    quartiles::Vector{Float64}
    var::Float64
    std::Float64
end

struct NGPopStats <: Statistics
    obj_fitness::StatFeatures
    subj_fitness::StatFeatures
end

struct BasicPop{E} <: Population{E}
    key::String
    entities::Set{E}
    stats::Set{Statistics}
    NGPop{E}(key, entities) = new(key, entities, nothing)
end


mutable struct NGCoev{E <:NGEntity, M <: NGMix, S <: Statistics} <: Coevolution
    gen::Int
    pops::Set{NGPop{E, S}}
    mixes::Set{M}
end



function make_entities(n::Int, type::T, popkey::String) where T <: Entity
    entities = Set{type}()
    for i in 1:n
        key = EntityString(popkey, i)
        e = T(key, i)
        push!(entities, e)
    end
    entities
end

function crosswise_mix(pop1::Population, pop2::Population)
    nothing
end

function sample_mix(n::Int, MixType::Type,
                    subpop::Population,
                    testpop::Population)
    mixes = Set{MixType}()
    for s in subpop.entities
        tests = sample(collect(testpop.entities), n, replace=false)
        for t in tests
            push!(mixes, MixType(s, t))
        end
    end
    mixes
end


function NG1Coev()
    entitiesA = make_entities(25, NG1Entity, "A")
    entitiesB = make_entities(25, NG1Entity, "B")
    entities = union(entitiesA, entitiesB)

    popA = NGPop("A", entitiesA)
    popB = NGPop("B", entitiesB)
    pops = union(popA, popB)

    mixesA = sample_mix(15, NGMix, popA, popB)
    mixesB = sample_mix(15, NGMix, popB, popA)
    mixes = union(mixesA, mixesB)

    NGCoev(1, entities, pops, mixes)
end


# function evolve(pop::NGPopulation)

# end

# function evolve(c::NGCoev)
#     pops = [evolve(pop) for pop in c.pops]

#     NGCoev
# end