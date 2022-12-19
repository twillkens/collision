export PairOutcome

function PairOutcome(::NGGradient, subject::NGIntPheno, test::NGIntPheno)
    PairOutcome(subject.key, test.key, subject.traits > test.traits, nothing)
end

function PairOutcome(::NGGradient, subject::NGVectorPheno, test::NGVectorPheno)
    PairOutcome(subject.key, test.key, sum(subject.traits) > sum(test.traits), nothing)
end

function PairOutcome(::NGFocusing, subject::NGVectorPheno, test::NGVectorPheno)
    v1, v2 = subject.traits, test.traits
    maxdiff, idx = findmax([abs(x1 - x2) for (x1, x2) in zip(v1, v2)])
    PairOutcome(subject.key, test.key, v1[idx] > v2[idx], nothing)
end

function PairOutcome(::NGRelativism, subject::NGVectorPheno, test::NGVectorPheno)
    v1, v2 = subject.traits, test.traits
    mindiff, idx = findmin([abs(x1 - x2) for (x1, x2) in zip(v1, v2)])
    PairOutcome(subject.key, test.key, v1[idx] > v2[idx], nothing)
end
