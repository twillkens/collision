export BasicOrg

"""
An entity with genotypic and phenotypic aspects, to which we can assign outcomes.
Comprises the populations of BasicCoevs.
"""
struct BasicOrg{G, P} <: Organism{G, P}
    key::String
    geno::G
    pheno::P
    outcomes::Set{Outcome}
    stats::Set{Statistics}
    BasicOrg{G, P}(key, geno, pheno) where {G, P} = new(key, geno, pheno, Set(), Set())
end

"""
Constructs an organism from a cfg using the parametric types.
"""
function BasicOrg{G, P}(key::String, cfg::NamedTuple) where {G <: Genotype, P <: Phenotype}
    geno = G(key, cfg)
    pheno = P(key, geno, cfg)
    BasicOrg{G, P}(key, geno, pheno)
end