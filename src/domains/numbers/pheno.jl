export BasicPheno

BitsGeno = BasicGeno{Vector{Bool}}
NGIntPheno = BasicPheno{Int, NumbersGame}
NGVecPheno = BasicPheno{Vector{Int}, NumbersGame}

function BasicPheno{Int, NumbersGame}(key::String, geno::BitsGeno, cfg::NamedTuple)
    NGIntPheno(key, sum(geno.genes))
end

function BasicPheno{Vector{Int}, NumbersGame}(key::String, geno::BitsGeno, subvector_width::Int)
    if mod(length(geno.genes), subvector_width) != 0
        error("Invalid subvector width for given genome width")
    end
    traits = [sum(part) for part in Iterators.partition(geno.genes, subvector_width)]
    NGVecPheno(key, traits)
end

function BasicPheno{Vector{Int}, NumbersGame}(key::String, geno::BitsGeno, cfg::NamedTuple)
    NGVecPheno(key, geno, cfg.subvector_width)
end