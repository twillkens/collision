export DelphiOutcome

struct DelphiOutcome <: PairOutcome
    n::Int
    subject_key::String
    test_key::String
    subject_score::Int
    test_score::Int
end

function DelphiOutcome(n::Int, ::COADomain, subject::DelphiPheno, test::DelphiPheno)
    vec1, vec2 = subject.traits, test.traits
    subject_score = all([v1 >= v2 for (v1, v2) in zip(vec1, vec2)]) ? 1.0 : -1.0
    DelphiOutcome(n, subject.key, test.key, subject_score, -subject_score)
end

function DelphiOutcome(n::Int, ::COODomain, subject::DelphiPheno, test::DelphiPheno)
    vec1, vec2 = subject.traits, test.traits
    m = argmax(vec2)
    subject_score = vec1[m] >= vec2[m] ? 1.0 : -1.0
    DelphiOutcome(n, subject.key, test.key, subject_score, -subject_score)
end