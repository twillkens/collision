export PairMix

"""
A basic interaction either of two named Aspects or their respective String keys
This is used to determine interactions between members of populations.
The convention is to produce a set of String PairMixes from the keys of Entities
within a Coevolution according to a given Recipe.
"""
struct PairMix{T <: Union{String, Aspect}, D <: Domain} <: Mix{T, D}
    subject::T
    test::T
end

function PairMix{String, D}(subject::Organism, test::Organism) where {D <: Domain}
    PairMix{String, D}(subject.key, test.key)
end

function PairMix{P, D}(subject::Organism, test::Organism) where {P <: Phenotype, D <: Domain}
    PairMix{P, D}(subject.pheno, test.pheno)
end

