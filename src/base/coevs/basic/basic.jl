export BasicCoev

struct BasicCoev{P <: Population, R <: Recipe,
                 M <: Mix} <: Coevolution
    gen::Int
    pops::Set{P}
    mixes::Set{M}
    stats::Set{Statistics}
    BasicCoev{P, R, M}(gen, pops, mixes) where {P <: Population,
                                                R <: Recipe,
                                                M <: Mix} = new{P, R, M}(gen, pops, mixes, Set())
end

function BasicCoev{P, R, M}(popkeys::Set{String}, cfg::NamedTuple) where {P <: Population, M <: Mix, R <: Recipe}
    pops = Set([P(popkey, cfg) for popkey in popkeys])
    mixes = Set{M}(pops, R(cfg))
    BasicCoev{P, R, M}(1, pops, mixes)
end
function BasicCoev{P, R, M}(cfg::NamedTuple) where {P <: Population, M <: Mix, R <: Recipe}
    BasicCoev{P, R, M}(cfg.popkeys, cfg)
end

function Set{O}(coev::BasicCoev{P, R, M}, cfg::NamedTuple) where {O <: Outcome,
                                                                  P <: Population,
                                                                  R <: Recipe,
                                                                  M <: Mix} 
    mixes = Set{M}(coev.pops, R(cfg))
    mixsets = Set{Set{M}}(mixes, cfg.n_processes)
    phenos = Dict{String, Phenotype}(coev.pops)
    
    Set([O(mixset, cfg) for mixset in mixsets])
end

