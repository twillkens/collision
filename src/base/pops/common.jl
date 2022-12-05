"""
Extracts a dictionary of String keys and Phenotype values from a Population
"""
function Dict{String, P}(pop::Population) where {P <: Phenotype}
    Dict([org.key => org.pheno for org in pop.orgs])
end


"""
Extracts a dictionary of String keys and Genotype values from a Population
"""
function Dict{String, G}(pop::Population) where {G <: Genotype}
    Dict([org.key => org.geno for org in pop.orgs])
end


"""
Extracts a dictionary of String keys and Genotype values from a Population
"""
function Dict{String, Tuple{G, T}}(pop::Population) where {G <: Genotype, T <: Type}
    Dict([org.key => (org.geno, typeof(org.pheno)) for org in pop.orgs])
end