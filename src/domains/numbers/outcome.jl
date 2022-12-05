export PairOutcome

IntPheno = BasicPheno{Int}
VecPheno = BasicPheno{Vector{Int}}

function PairOutcome(subject::IntPheno, test::IntPheno, domain::NGGradient)
    PairOutcome(subject.key, test.key, subject.traits > test.traits)
end

function PairOutcome(subject::VecPheno, test::VecPheno, domain::NGGradient)
    PairOutcome(subject.key, test.key, sum(subject.traits) > sum(test.traits))
end

function PairOutcome(subject::VecPheno, test::VecPheno, domain::NGFocusing)
    v1, v2 = subject.traits, test.traits
    maxdiff, idx = findmax([abs(x1 - x2) for (x1, x2) in zip(v1, v2)])
    PairOutcome(subject.key, test.key, v1[idx] > v2[idx])
end

function PairOutcome(subject::VecPheno, test::VecPheno, domain::NGRelativism)
    v1, v2 = subject.traits, test.traits
    mindiff, idx = findmin([abs(x1 - x2) for (x1, x2) in zip(v1, v2)])
    PairOutcome(subject.key, test.key, v1[idx] > v2[idx])
end
