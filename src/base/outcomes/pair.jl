export TestPairOutcome

struct TestPairOutcome{S <: Real} <: PairOutcome
    n::Int
    subject_key::String
    test_key::String
    score::S
end
