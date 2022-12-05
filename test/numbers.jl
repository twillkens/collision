using Test
using StableRNGs
include("../src/Coevolutionary.jl")
using .Coevolutionary


function make_geno_ones()
    cfg = (genome_default_val = true, subvector_width = 10, genome_width = 100)
    T = Vector{Bool}
    D = NumbersGame
    G = BasicGeno{T, D}
    G("ones", cfg)
end

@testset "NumbersGame" begin
    @testset "Genotype" begin
        T = Vector{Bool}
        D = NumbersGame
        G = BasicGeno{T, D}

        # genome initialization with default value 0
        cfg = (genome_default_val = false, genome_width = 10)
        geno_zeros = G("AllZeros", cfg)
        @test geno_zeros.key == "AllZeros"
        @test geno_zeros.genes == fill(false, 10)

        # genome initialization with default value 1
        cfg = (genome_default_val = true, genome_width = 15)
        geno_ones = G("AllOnes", cfg)
        @test geno_ones.key == "AllOnes"
        @test geno_ones.genes == fill(true, 15)

        # genome initialization with random values
        cfg = (rng = StableRNG(123), genome_width = 20)
        geno_rand = G("Random", cfg)
    end

    @testset "Phenotype" begin
        cfg = (genome_default_val = true, subvector_width = 10, genome_width = 100)
        T = Vector{Bool}
        D = NumbersGame
        G = BasicGeno{T, D}
        geno_ones = G("ones", cfg)

        T = Int
        D = NumbersGame
        P = BasicPheno{T, D}
        pheno_int = P("int", geno_ones, cfg)

        @test pheno_int.key == "int"
        @test pheno_int.traits == 100

        T = Vector{Int}
        D = NumbersGame
        P = BasicPheno{T, D}
        pheno_vec = P("vec", geno_ones, cfg)
        @test pheno_vec.key == "vec"
        @test pheno_vec.traits == fill(10, 10)
    end

    @testset "Organism" begin
        cfg = (genome_default_val = true, subvector_width = 10, genome_width = 100)
        T = Vector{Bool}
        D = NumbersGame
        G = BasicGeno{T, D}

        T = Vector{Int}
        D = NumbersGame
        P = BasicPheno{T, D}

        O = BasicOrg{G, P}
        org = O("org", cfg)

        @test org.geno.genes == fill(true, 100)
        @test org.pheno.traits == fill(10, 10)
    end

    @testset "Population" begin
        cfg = (rng = StableRNG(123), subvector_width = 10, genome_width = 100, n_orgs = 10)
        T = Vector{Bool}
        D = NumbersGame
        G = BasicGeno{T, D}

        T = Vector{Int}
        D = NumbersGame
        P = BasicPheno{T, D}

        O = BasicOrg{G, P}
        pop = BasicPop{O}("test", cfg)

        @test length(pop.orgs) == 10
    end


    @testset "Mix" begin
        cfg = (rng = StableRNG(123), subvector_width = 10, genome_width = 100, n_orgs = 10)
        T = Vector{Bool}
        D = NumbersGame
        G = BasicGeno{T, D}

        T = Vector{Int}
        D = NumbersGame
        P = BasicPheno{T, D}

        O = BasicOrg{G, P}

        o1 = O("o1", cfg)
        o2 = O("o2", cfg)
        mix = PairMix{String, NGGradient}(o1, o2)
        @test mix.subject == "o1"
        @test mix.test == "o2"

        pop1 = BasicPop{O}("test1", cfg)
        d1 = Dict{String, Phenotype}(pop1)
        @test haskey(d1, "test1-1")

        pop2 = BasicPop{O}("test2", cfg)
        d2 = Dict{String, Phenotype}(pop2)
        @test haskey(d2, "test2-1")

        o1 = rand(cfg.rng, pop1.orgs)
        o2 = rand(cfg.rng, pop2.orgs)

        mix = PairMix{String, NGGradient}(o1, o2)
        @test haskey(d1, mix.subject)
        @test haskey(d2, mix.test)
    end


    @testset "Outcome" begin
        T = Vector{Bool}
        D = NumbersGame
        G = BasicGeno{T, D}

        T = Int
        D = NumbersGame
        P = BasicPheno{T, D}

        O = BasicOrg{G, P}
        cfg = (genome_default_val = true, subvector_width = 10, genome_width = 100)
        org1 = O("org1", cfg)
        cfg = (genome_default_val = false, subvector_width = 10, genome_width = 100)
        org2 = O("org2", cfg)

        phenomix = PairMix{BasicPheno, NGGradient}(org1, org2)
        o = PairOutcome(phenomix, cfg)

        @test o.subject == "org1"
        @test o.test == "org2"
        @test o.score == true

        phenomix = PairMix{BasicPheno, NGGradient}(org2, org1)
        o = PairOutcome(phenomix, cfg)

        @test o.subject == "org2"
        @test o.test == "org1"
        @test o.score == false
    end

    @testset "NGGradient" begin
        cfg = (x = "",)
        T = Int
        D = NumbersGame
        P = BasicPheno{T, D}

        a = P("a", 4)
        b = P("b", 5)

        D = NGGradient
        phenomix = PairMix{P, D}(a, b)
        o = PairOutcome(phenomix, cfg)
        @test o.subject == "a"
        @test o.test == "b"
        @test o.score == false

        Sₐ = Set([P(string(x), x) for x in 1:3])
        Sᵦ = Set([P(string(x), x) for x in 6:8])
        
        fitness_a = 0
        for other ∈ Sₐ
            phenomix = PairMix{P, D}(a, other)
            o = PairOutcome(phenomix, cfg)
            fitness_a += o.score
        end

        @test fitness_a == 3

        fitness_b = 0
        for other ∈ Sᵦ
            phenomix = PairMix{P, D}(b, other)
            o = PairOutcome(phenomix, cfg)
            fitness_b += o.score
        end

        @test fitness_b == 0
    end


    @testset "NGFocusing" begin
        cfg = (x = "",)
        T = Vector{Int}
        D = NumbersGame
        P = BasicPheno{T, D}

        a = P("a", [4, 16])
        b = P("b", [5, 14])
        D = NGFocusing
        phenomix = PairMix{P, D}(a, b)
        o = PairOutcome(phenomix, cfg)
        @test o.subject == "a"
        @test o.test == "b"
        @test o.score == true

        a = P("a", [4, 16])
        b = P("b", [5, 16])
        D = NGFocusing
        phenomix = PairMix{P, D}(a, b)
        o = PairOutcome(phenomix, cfg)
        @test o.subject == "a"
        @test o.test == "b"
        @test o.score == false

        a = P("a", [5, 16, 8])
        b = P("b", [4, 16, 6])
        D = NGFocusing
        phenomix = PairMix{P, D}(a, b)
        o = PairOutcome(phenomix, cfg)
        @test o.subject == "a"
        @test o.test == "b"
        @test o.score == true
    end

    @testset "NGRelativism" begin
        cfg = (x = "",)
        T = Vector{Int}
        D = NumbersGame
        P = BasicPheno{T, D}

        a = P("a", [1, 6])
        b = P("b", [4, 5])
        c = P("c", [2, 4])
        D = NGRelativism

        phenomix = PairMix{P, D}(a, b)
        o = PairOutcome(phenomix, cfg)
        @test o.subject == "a"
        @test o.test == "b"
        @test o.score == true

        phenomix = PairMix{P, D}(b, c)
        o = PairOutcome(phenomix, cfg)
        @test o.subject == "b"
        @test o.test == "c"
        @test o.score == true

        phenomix = PairMix{P, D}(c, a)
        o = PairOutcome(phenomix, cfg)
        @test o.subject == "c"
        @test o.test == "a"
        @test o.score == true
    end


    @testset "Dict{String, Tuple{G, Type}}" begin
        cfg = (popkeys = Set(["A", "B"]), genome_width = 10, n_samples = 5, n_orgs = 10, rng = StableRNG(123), n_processes = 1)

        T = Vector{Bool}
        D = NumbersGame
        G = BasicGeno{T, D}
        PH = BasicPheno{Int, D}
        O = BasicOrg{G, PH}
        P = BasicPop{O}
        pop = P("test", cfg)
        d = Dict{String, Tuple{Genotype, Type}}(pop)
        println(d)
    end

    @testset "Coev" begin
        cfg = (popkeys = Set(["A", "B"]), genome_width = 10, n_samples = 5, n_orgs = 10, rng = StableRNG(123), n_processes = 1)

        T = Vector{Bool}
        D = NumbersGame
        G = BasicGeno{T, D}
        PH = BasicPheno{Int, D}
        O = BasicOrg{G, PH}
        P = BasicPop{O}
        D = NGGradient
        M = PairMix{String, D}
        R = SampleRecipe

        coev = BasicCoev{P, R, M}(cfg)
        @test length(coev.pops) == 2
        pop1, pop2 = sort(collect(coev.pops), by = x -> x.key)
        @test "A-1" ∈ keys(Dict{String, G}(pop1))
        @test "A-1" ∉ keys(Dict{String, G}(pop2))
        @test "B-1" ∈ keys(Dict{String, G}(pop2))
        @test "B-1" ∉ keys(Dict{String, G}(pop1))

        @test length(coev.mixes) == 100

        print(Set{PairOutcome}(coev, cfg))
    end


end