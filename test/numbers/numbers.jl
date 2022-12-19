include("util.jl")

@testset "NumbersGame" begin
    @testset "Genotype" begin
        # genome initialization with default value 0
        cfg = DefaultBitstringConfig(width=10, default_val=false)
        geno_zeros = cfg("AllZeros")
        @test typeof(geno_zeros) == BitstringGeno
        @test geno_zeros.key == "AllZeros"
        @test geno_zeros.genes == fill(false, 10)

        # genome initialization with default value 1
        cfg = DefaultBitstringConfig(width=15, default_val=true)
        geno_ones = cfg("AllOnes")
        @test typeof(geno_ones) == BitstringGeno
        @test geno_ones.key == "AllOnes"
        @test geno_ones.genes == fill(true, 15)

        # genome initialization with random values
        cfg = RandomBitstringConfig(width=100, rng = StableRNG(123))
        geno_rand = cfg("Random")
        @test typeof(geno_rand) == BitstringGeno
        @test sum(geno_rand.genes) != 100 
        @test sum(geno_rand.genes) != 0 
    end

    @testset "Population" begin
        geno_cfg = DefaultBitstringConfig(width=10, default_val=false)
        pop_cfg = GenoPopConfig(key = "A", n_genos = 10, geno_cfg = geno_cfg)
        popA = (pop_cfg)()
        genos = Dict{String, Genotype}(popA)
        @test length(genos) == 10
        @test all(["A-$(i)" in keys(genos) for i in 1:10])
        @test sum([sum(g.genes) for g in values(genos)]) == 0

        geno_cfg = DefaultBitstringConfig(width=10, default_val=true)
        pop_cfg = GenoPopConfig(key = "B", n_genos = 10, geno_cfg = geno_cfg)
        popB = (pop_cfg)()
        genos = Dict{String, Genotype}(popB)
        @test length(genos) == 10
        @test all(["B-$(i)" in keys(genos) for i in 1:10])
        @test sum([sum(g.genes) for g in values(genos)]) == 100

        pops = Set([popA, popB])
        popdict = Dict{String, Population}(pops)
        @test length(popdict) == 2
        @test popdict["A"] == popA
        @test popdict["B"] == popB
    end

    @testset "SamplerOrder/Recipes" begin
        popA = make_testpop(key="A")
        popB = make_testpop(key="B", default_val=true)
        pops = Set([popA, popB])
        order = make_sampler_order()
        recipes = (order)(popA, popB)
        @test length(recipes) == 50
        recipe_set = Set{Set{Recipe}}(order, pops, 5)
        @test all([length(recipes) == 10 for recipes in recipe_set])
    end

    @testset "AllvsAllOrder" begin
        popA = make_testpop(key="A")
        popB = make_testpop(key="B", default_val=true)
        pops = Set([popA, popB])
        order = make_allvsall_order()
        recipes = (order)(popA, popB)
        @test length(recipes) == 100
        recipe_set = Set{Set{Recipe}}(order, pops, 5)
        @test all([length(recipes) == 20 for recipes in recipe_set])
    end


    @testset "ParallelJob" begin
        rng = StableRNG(123)
        popA = make_testpop(key="A")
        popB = make_testpop(key="B", default_val=true)
        pops = Set([popA, popB])
        orderA = make_sampler_order()
        orderB = make_sampler_order(subjects_popkey="B", tests_popkey="A")
        orders = Set([orderA, orderB])
        cfg = ParallelJobsConfig(n_jobs=5)
        jobs = cfg(orders, pops)
        @test all([length(job.recipes) == 20 for job in jobs])
        flag = true
        for job in jobs
            for recipe in job.recipes
                for key in Set{String}(recipe)
                    if key ∉ keys(job.genodict)
                        flag = false
                    end
                end
            end
        end
        @test flag
    end

    @testset "Phenotypes" begin
        pheno_cfg = NGIntPhenoConfig(popkey="A")
        geno = default_geno(width=100, default_val=true)
        pheno = pheno_cfg(geno)
        @test typeof(pheno) == NGIntPheno
        @test pheno.traits == 100

        pheno_cfg = NGVectorPhenoConfig(popkey="A", subvector_width=10)
        geno = default_geno(width=100, default_val=true)
        pheno = pheno_cfg(geno)
        @test length(pheno.traits) == 10
        @test sum([sum(subv) for subv in pheno.traits]) == 100
    end

    @testset "Mixes" begin
        job = default_job()
        mixes = Set{Mix}(job)
        @test length(job.recipes) == length(mixes)
    end

    @testset "Outcomes: Int Pheno" begin
        jobs = default_jobs()
        outcomes = Set{Outcome}(jobs)
        @test length(outcomes) == 100
        flag = true
        for outcome in outcomes
            if occursin("A", outcome.subject_key) && outcome.subject_score == 1
                flag = false
            end
            if occursin("B", outcome.subject_key) && outcome.subject_score == 0
                flag = false
            end
        end
        @test flag
    end

    @testset "Outcomes: Vector Pheno" begin
        jobs = default_jobs(;subjects_phenocfg_T = NGVectorPhenoConfig,
                            tests_phenocfg_T = NGVectorPhenoConfig)
        outcomes = Set{Outcome}(jobs)
        @test length(outcomes) == 100
        flag = true
        for outcome in outcomes
            if occursin("A", outcome.subject_key) && outcome.subject_score == 1
                flag = false
            end
            if occursin("B", outcome.subject_key) && outcome.subject_score == 0
                flag = false
            end
        end
        @test flag
    end

    @testset "NGGradient" begin
        domain = NGGradient()
        a = NGIntPheno("a", 4)
        b = NGIntPheno("b", 5)
        mix = PairMix(domain, PairOutcome, a, b)
        o = (mix)()
        @test o.subject_key == "a"
        @test o.test_key == "b"
        @test o.subject_score == false
        @test o.test_score === nothing

        Sₐ = Set([NGIntPheno(string(x), x) for x in 1:3])
        Sᵦ = Set([NGIntPheno(string(x), x) for x in 6:8])
        
        fitness_a = 0
        for other ∈ Sₐ
            mix = PairMix(domain, PairOutcome, a, other)
            o = (mix)()
            fitness_a += o.subject_score
        end

        @test fitness_a == 3

        fitness_b = 0
        for other ∈ Sᵦ
            mix = PairMix(domain, PairOutcome, b, other)
            o = (mix)()
            fitness_b += o.subject_score
        end

        @test fitness_b == 0
    end

    @testset "NGFocusing" begin
        domain = NGFocusing()

        a = NGVectorPheno("a", [4, 16])
        b = NGVectorPheno("b", [5, 14])

        mix = PairMix(domain, PairOutcome, a, b)
        o = (mix)()
        @test o.subject_score == true

        a = NGVectorPheno("a", [4, 16])
        b = NGVectorPheno("b", [5, 16])

        mix = PairMix(domain, PairOutcome, a, b)
        o = (mix)()
        @test o.subject_score == false

        a = NGVectorPheno("a", [5, 16, 8])
        b = NGVectorPheno("b", [4, 16, 6])

        mix = PairMix(domain, PairOutcome, a, b)
        o = (mix)()
        @test o.subject_score == true
    end

    @testset "NGRelativism" begin
        domain = NGRelativism()

        a = NGVectorPheno("a", [1, 6])
        b = NGVectorPheno("b", [4, 5])
        c = NGVectorPheno("c", [2, 4])

        mix = PairMix(domain, PairOutcome, a, b)
        o = (mix)()
        @test o.subject_score == true

        mix = PairMix(domain, PairOutcome, b, c)
        o = (mix)()
        @test o.subject_score == true

        mix = PairMix(domain, PairOutcome, c, a)
        o = (mix)()
        @test o.subject_score == true
    end

    @testset "Roulette/Reproduce" begin
        rng = StableRNG(123)
        popA = make_testpop(;key = "A", width=100, rng=rng)
        popB = make_testpop(;key = "B", width=100, default_val = true, rng=rng)
        pops = Set([popA, popB])
        order = make_sampler_order(;subjects_popkey = "A", tests_popkey = "B")
        orders = Set([order])
        cfg = SerialJobConfig()
        job = cfg(orders, pops)
        outcomes = Set{Outcome}(job)
        selector = RouletteSelector(key="A", rng=rng, n_elite=5, n_singles=5, n_couples=0)
        results = (selector)(popA, outcomes)
        reproducer = BitstringReproducer(rng, 0.05)
        newpop = (reproducer)(results)
        @test length(newpop.genos) == 10
    end

    @testset "Truncation/Reproduce" begin
        cfg = DefaultBitstringConfig(width=10, default_val = true)
        winners = Set([cfg(string("A-", i)) for i in 1:5])
        cfg = DefaultBitstringConfig(width=10, default_val = false)
        losers = Set([cfg(string("B-", i)) for i in 6:10])
        genos = union(winners, losers)
        popA = GenoPop("A", 11, genos)
        popB = make_testpop(key="B", geno_cfg_T = DefaultBitstringConfig, default_val = false)
        order = make_allvsall_order()

    end
end