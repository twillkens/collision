export BasicPheno

struct BasicPheno{T, D <: Domain} <: Phenotype
    key::String
    traits::T
    stats::Set{Statistics}
    BasicPheno{T, D}(key, traits) where {T, D} = new(key, traits, Set())
end

# function Phenotype(org::Organism{G, P}) where {G <: Genotype, P <: Phenotype}
#     P(org.geno)
# end