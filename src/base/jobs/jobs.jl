export PairMix

struct PairMix{D <: Domain, S <: Phenotype, T <: Phenotype} <: Mix
    n::Int
    domain::D
    outcome::Type{<:PairOutcome}
    subject::S
    test::T
end

function(p::PairMix)()
    p.outcome(p.n, p.domain, p.subject, p.test)
end

function add_pheno!(key::String,
                    pheno_cfg::PhenoConfig,
                    genodict::Dict{String, Genotype},
                    phenodict::Dict{String, Phenotype},)
    if key ∉ keys(phenodict)
        geno = genodict[key]
        pheno = (pheno_cfg)(geno)
        phenodict[key] = pheno
    end
end

function add_pheno!(recipe::PairRecipe,
                    genodict::Dict{String, Genotype},
                    phenodict::Dict{String, Phenotype},)
    add_pheno!(recipe.subject_key, recipe.subject_cfg, genodict, phenodict)
    add_pheno!(recipe.test_key, recipe.test_cfg, genodict, phenodict)
end

function Dict{String, Phenotype}(recipes::Set{<:Recipe}, genodict::Dict{String, Genotype},)
    phenodict = Dict{String, Phenotype}()
    [add_pheno!(recipe, genodict, phenodict) for recipe in recipes]
    phenodict
end

function Set{Mix}(recipes::Set{<:Recipe}, phenodict::Dict{String, Phenotype},)
    Set([(recipe)(phenodict) for recipe in recipes])
end

function Set{Mix}(recipes::Set{<:Recipe},
                  genodict::Dict{String, Genotype},)
    phenodict = Dict{String, Phenotype}(recipes, genodict)
    Set{Mix}(recipes, phenodict)
end

include("serial.jl")
include("parallel.jl")