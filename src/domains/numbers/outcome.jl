
function TestPairOutcome(n::Int, ::NGControl, subject::Phenotype, test::Phenotype)
    TestPairOutcome(n, subject.key, test.key, true)
end

function TestPairOutcome(n::Int, ::NGGradient, subject::IntPheno, test::IntPheno)
    TestPairOutcome(n, subject.key, test.key, subject.traits > test.traits)
end

function TestPairOutcome(n::Int, ::NGGradient, subject::VectorPheno, test::VectorPheno)
    result = sum(subject.traits) > sum(test.traits) 
    TestPairOutcome(n, subject.key, test.key, result)
end

function TestPairOutcome(n::Int, ::NGFocusing, subject::VectorPheno, test::VectorPheno)
    v1, v2 = subject.traits, test.traits
    maxdiff, idx = findmax([abs(x1 - x2) for (x1, x2) in zip(v1, v2)])
    TestPairOutcome(n, subject.key, test.key, v1[idx] > v2[idx])
end

function TestPairOutcome(n::Int, ::NGRelativism, subject::VectorPheno, test::VectorPheno)
    v1, v2 = subject.traits, test.traits
    mindiff, idx = findmin([abs(x1 - x2) for (x1, x2) in zip(v1, v2)])
    TestPairOutcome(n, subject.key, test.key, v1[idx] > v2[idx])
end

function TestPairOutcome(n::Int, ::NGSum, subject::VectorPheno, test::VectorPheno)
    TestPairOutcome(n, subject.key, test.key, sum(subject.traits))
end