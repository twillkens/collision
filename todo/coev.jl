abstract type Coevolution end
abstract type Population{S, R} end
abstract type AbstractReproducer end
abstract type AbstractIndividual end
abstract type AbstractInteractiveDomain end
abstract type AbstractConfig end
abstract type AbstractArchiver end


mutable struct BasicCoevolution <: Coevolution
    cfg::AbstractConfig
    gen::Int
    pops::Dict{String, Population}
    rng::StableRNG
end

mutable struct BasicPopulation{T} <: Population
    key::String
    cfg::NamedTuple
    indivs::Vector{T}
end

function BasicPopulation(cfg::String)
    cfg = get_config(cfg)
    itype = getfield(Main, Symbol(cfg.itype))
    indivs = [itype(cfg, i) for i in 1:cfg.n_indiv]
    BasicPopulation{itype}(cfg.key, cfg, indivs)
end

function BasicCoevolution{T, U}(cfg::String) where {T, U}
    BasicCoevolution{T, U}(get_config(cfg))
end

function parse_cfg()

end