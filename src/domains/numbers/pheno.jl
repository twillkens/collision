export NGIntPhenoConfig, NGIntPheno
export NGVectorPhenoConfig, NGVectorPheno

Base.@kwdef struct NGIntPhenoConfig <: PhenoConfig
    popkey::String
end

Base.@kwdef struct NGVectorPhenoConfig <: PhenoConfig
    popkey::String
    subvector_width::Int
end

struct NGIntPheno <: Phenotype
    key::String
    traits::Int
end

function(::NGIntPhenoConfig)(geno::BitstringGeno)
    traits = sum(geno.genes)
    NGIntPheno(geno.key, traits)
end

struct NGVectorPheno <: Phenotype
    key::String
    traits::Vector{Int}
end

function(cfg::NGVectorPhenoConfig)(geno::BitstringGeno)
    if mod(length(geno.genes), cfg.subvector_width) != 0
        error("Invalid subvector width for given genome width")
    end
    traits = [sum(part) for part in Iterators.partition(geno.genes, cfg.subvector_width)]
    NGVectorPheno(geno.key, traits)
end