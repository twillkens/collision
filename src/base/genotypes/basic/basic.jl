export BasicGeno

"""
A general purpose genotype. This applies in cases where the genotype
can be expressed with a single data structure. The Domain type can be 
used to determine constructor behavior and translation to a phenotype
"""
struct BasicGeno{G, D <: Domain} <: Genotype
    key::String
    genes::G
    stats::Set{Statistics}
    BasicGeno{G, D}(key, genes) where {G, D <: Domain} = new(key, genes, Set())
end