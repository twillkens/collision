export PairOutcome

"""
Returns a score representing the outcome of an interaction between two entities.
These are the results from evaluation over a process.
They may be collected and processed on the main process to perform selection.
"""
struct PairOutcome{T <: Real} <: Outcome
    subject::String
    test::String
    score::T
end

"""
Extracts the 
"""
function PairOutcome(mix::PairMix{P, D}, cfg::NamedTuple) where {P <: Phenotype,
                                                                 D <: Domain}
    PairOutcome(mix.subject, mix.test, D(cfg))
end

"""

"""
function Set{PairOutcome}(mixset::Set{PairMix{T, D}},
                          cfg::NamedTuple) where {T <: Phenotype,
                                                  D <: Domain}
    reduce(union, [PairOutcome(mix, cfg) for mix in mixset])
end

