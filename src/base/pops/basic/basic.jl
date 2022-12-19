export GenoPop, KEY_SPLIT_TOKEN, GenoPopConfig

const KEY_SPLIT_TOKEN = "-"

struct GenoPop <: Population
    key::String
    curr_id::Int
    genos::Set{Genotype}
end

Base.@kwdef struct GenoPopConfig{C <: GenoConfig} <: PopConfig
    key::String
    n_genos::Int
    geno_cfg::C
end

function(g::GenoPopConfig)()
    genos = Set([g.geno_cfg(join([g.key, i], KEY_SPLIT_TOKEN)) for i in 1:g.n_genos])
    GenoPop(g.key, g.n_genos + 1, genos)
end


# function GenoPop(popkey::String, n_genos::Int, geno_cfg::GenoConfig)
#     genos = Set{Genotype}()
#     for i in 1:n_genos
#         genokey = join([popkey, i], KEY_SPLIT_TOKEN)  
#         geno = geno_cfg(genokey)
#         push!(genos, geno)
#     end
#     GenoPop(popkey, n_genos + 1, genos)
# end

# function GenoPop(cfg::GenoPopConfig)
#     GenoPop(cfg.key, cfg.n_genos, cfg.geno_cfg)
# end

# function GenoPop{G}(key::String, n_orgs::Int, cfg::NamedTuple) where {G <: Genotype}
#     genos = Set{G}()
#     for i in 1:n_orgs
#         genokey = join([key, i], KEY_SPLIT_TOKEN)  
#         geno = G(genokey, cfg)
#         push!(genos, geno)
#     end
#     GenoPop(key, genos)
# end

# function GenoPop(key::String, cfg::NamedTuple)
#     GenoPop(key, cfg.n_orgs, cfg)
# end

"""
Extracts a dictionary of String keys and Genotype values from a Population
"""
function Dict{String, Genotype}(pop::GenoPop)
    Dict{String, Genotype}([geno.key => geno for geno in pop.genos])
end

function Dict{String, Genotype}(pops::Set{GenoPop})
    merge([Dict{String, Genotype}(pop) for pop in pops]...)
end

function Dict{String, Population}(pops::Set{<:Population})
    Dict{String, Population}([pop.key => pop for pop in pops])
end