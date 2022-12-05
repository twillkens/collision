

function Set{O}(mixset::Set{Mix{P, D}},
                          cfg::NamedTuple) where {P <: Phenotype,
                                                  D <: Domain, O <: Outcome}
    reduce(union, [O(mix, cfg) for mix in mixset])
end

function Set{O}(mixset::Set{Mix{ORG, D}},
                          cfg::NamedTuple) where {ORG <: Organism,
                                                  D <: Domain, O <: Outcome}
    reduce(union, [O(mix, cfg) for mix in mixset])
end