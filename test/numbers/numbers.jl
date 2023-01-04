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

@testset "SamplerOrder/Recipes1" begin
    rng = StableRNG(123)
    popA = GenoPopConfig(key="A", n_genos=10,
                         geno_cfg=DefaultBitstringConfig(width=10, default_val=true))()
    popB = GenoPopConfig(key="B", n_genos=10,
                         geno_cfg=DefaultBitstringConfig(width=10, default_val=false))()
    pops = Set([popA, popB])
    pheno_cfg = IntPhenoConfig()
    order = SamplerOrder(domain=NGGradient(),
                         outcome=TestPairOutcome,
                         subjects_key="A", subjects_cfg=pheno_cfg,
                         tests_key="B", tests_cfg=pheno_cfg,
                         n_samples=5, rng=rng)
    recipes = (order)(popA, popB)
    @test length(recipes) == 50
    recipe_set = Set{Set{Recipe}}(order, pops, 5)
    @test all([length(recipes) == 10 for recipes in recipe_set])
end

@testset "SamplerOrder/Recipes2" begin
    rng = StableRNG(123)
    popA = GenoPopConfig(key="A", n_genos=10,
                         geno_cfg=DefaultBitstringConfig(width=10, default_val=true))()
    popB = GenoPopConfig(key="B", n_genos=10,
                         geno_cfg=DefaultBitstringConfig(width=10, default_val=false))()
    pops = Set([popA, popB])
    pheno_cfg = IntPhenoConfig()
    order = SamplerOrder(domain=NGGradient(),
                         outcome=TestPairOutcome,
                         subjects_key="A", subjects_cfg=pheno_cfg,
                         tests_key="B", tests_cfg=pheno_cfg,
                         n_samples=1, rng=rng)
    recipes = (order)(popA, popB)
    @test length(recipes) == 10
    recipe_set = Set{Set{Recipe}}(order, pops, 5)
    @test all([length(recipes) == 2 for recipes in recipe_set])
end

@testset "AllvsAllOrder" begin
    rng = StableRNG(123)
    popA = GenoPopConfig(key="A", n_genos=10,
                            geno_cfg=DefaultBitstringConfig(width=10, default_val=true))()
    popB = GenoPopConfig(key="B", n_genos=10,
                            geno_cfg=DefaultBitstringConfig(width=10, default_val=false))()
    pops = Set([popA, popB])
    pheno_cfg = IntPhenoConfig()
    order = AllvsAllOrder(domain=NGGradient(),
                          outcome=TestPairOutcome,
                          subjects_key="A", subjects_cfg=pheno_cfg,
                          tests_key="B", tests_cfg=pheno_cfg,)
    recipes = (order)(popA, popB)
    @test length(recipes) == 100
end



@testset "ParallelJob" begin
    rng = StableRNG(123)
    geno_cfg = DefaultBitstringConfig(width=100, default_val=true)
    popA = GenoPopConfig(key="A", n_genos=10, geno_cfg=geno_cfg)()
    geno_cfg = DefaultBitstringConfig(width=100, default_val=false)
    popB = GenoPopConfig(key="B", n_genos=10, geno_cfg=geno_cfg)()
    pops = Set([popA, popB])
    pheno_cfg = IntPhenoConfig()
    orderA = SamplerOrder(domain=NGGradient(),
                          outcome=TestPairOutcome,
                          subjects_key="A", subjects_cfg=pheno_cfg,
                          tests_key="B", tests_cfg=pheno_cfg,
                          n_samples=5, rng=rng)
    orderB = SamplerOrder(domain=NGGradient(),
                          outcome=TestPairOutcome,
                          subjects_key="B", subjects_cfg=pheno_cfg,
                          tests_key="A", tests_cfg=pheno_cfg,
                          n_samples=5, rng=rng)
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
    geno = DefaultBitstringConfig(width=100, default_val=true)("test")

    pheno_cfg = IntPhenoConfig()
    pheno = pheno_cfg(geno)
    @test typeof(pheno) == IntPheno
    @test pheno.traits == 100

    pheno_cfg = VectorPhenoConfig(subvector_width=10)
    pheno = pheno_cfg(geno)
    @test length(pheno.traits) == 10
    @test sum([sum(subv) for subv in pheno.traits]) == 100
end

@testset "Mixes" begin
    rng = StableRNG(123)
    geno_cfg = DefaultBitstringConfig(width=10, default_val=true)
    popA = GenoPopConfig(key="A", n_genos=10, geno_cfg=geno_cfg)()
    geno_cfg = DefaultBitstringConfig(width=10, default_val=false)
    popB = GenoPopConfig(key="B", n_genos=10, geno_cfg=geno_cfg)()
    pops = Set([popA, popB])
    orderA = SamplerOrder(domain=NGGradient(),
                          outcome=TestPairOutcome,
                          subjects_key="A", subjects_cfg=IntPhenoConfig(),
                          tests_key="B", tests_cfg=IntPhenoConfig(),
                          n_samples=5, rng=rng)
    cfg = SerialJobConfig()
    job = cfg(Set([orderA]), pops)
    mixes = Set{Mix}(job)
    @test length(job.recipes) == length(mixes)
end

@testset "Outcomes: Int Pheno" begin
    rng = StableRNG(123)
    geno_cfg = DefaultBitstringConfig(width=10, default_val=true)
    popA = GenoPopConfig(key="A", n_genos=10, geno_cfg=geno_cfg)()
    geno_cfg = DefaultBitstringConfig(width=10, default_val=false)
    popB = GenoPopConfig(key="B", n_genos=10, geno_cfg=geno_cfg)()
    pops = Set([popA, popB])
    domain = NGGradient()
    pheno_cfg = IntPhenoConfig()
    orderA = SamplerOrder(domain=domain, outcome=TestPairOutcome,
                          subjects_key="A", subjects_cfg=pheno_cfg,
                          tests_key="B", tests_cfg=pheno_cfg,
                          n_samples=5, rng=rng)
    orderB = SamplerOrder(domain=domain, outcome=TestPairOutcome,
                          subjects_key="B", subjects_cfg=pheno_cfg,
                          tests_key="A", tests_cfg=pheno_cfg,
                          n_samples=5, rng=rng)
    orders = Set([orderA, orderB])
    cfg = SerialJobConfig()
    job = cfg(orders, pops)
    outcomes = Set{Outcome}(job)
    @test length(outcomes) == 100
    flag = true
    for outcome in outcomes
        if occursin("A", outcome.subject_key) && outcome.score == 0
            flag = false
        end
        if occursin("B", outcome.subject_key) && outcome.score == 1
            flag = false
        end
    end
    @test flag
end

@testset "Outcomes: Vector Pheno" begin
    rng = StableRNG(123)
    geno_cfg = DefaultBitstringConfig(width=10, default_val=true)
    popA = GenoPopConfig(key="A", n_genos=10, geno_cfg=geno_cfg)()
    geno_cfg = DefaultBitstringConfig(width=10, default_val=false)
    popB = GenoPopConfig(key="B", n_genos=10, geno_cfg=geno_cfg)()
    pops = Set([popA, popB])
    domain = NGGradient()
    pheno_cfg = VectorPhenoConfig(subvector_width=10)
    orderA = SamplerOrder(domain=domain, outcome=TestPairOutcome,
                          subjects_key="A", subjects_cfg=pheno_cfg,
                          tests_key="B", tests_cfg=pheno_cfg,
                          n_samples=5, rng=rng)
    orderB = SamplerOrder(domain=domain, outcome=TestPairOutcome,
                          subjects_key="B", subjects_cfg=pheno_cfg,
                          tests_key="A", tests_cfg=pheno_cfg,
                          n_samples=5, rng=rng)
    orders = Set([orderA, orderB])
    cfg = SerialJobConfig()
    job = cfg(orders, pops)
    outcomes = Set{Outcome}(job)
    @test length(outcomes) == 100
    flag = true
    for outcome in outcomes
        if occursin("A", outcome.subject_key) && outcome.score == 0
            flag = false
        end
        if occursin("B", outcome.subject_key) && outcome.score == 1
            flag = false
        end
    end
    @test flag
end

@testset "NGGradient" begin
    domain = NGGradient()
    a = IntPheno("a", 4)
    b = IntPheno("b", 5)
    mix = PairMix(1, domain, TestPairOutcome, a, b)
    o = (mix)()
    @test o.subject_key == "a"
    @test o.test_key == "b"
    @test o.score == false

    Sₐ = Set([IntPheno(string(x), x) for x in 1:3])
    Sᵦ = Set([IntPheno(string(x), x) for x in 6:8])
    
    fitness_a = 0
    for other ∈ Sₐ
        mix = PairMix(1, domain, TestPairOutcome, a, other)
        o = (mix)()
        fitness_a += o.score
    end

    @test fitness_a == 3

    fitness_b = 0
    for other ∈ Sᵦ
        mix = PairMix(1, domain, TestPairOutcome, b, other)
        o = (mix)()
        fitness_b += o.score
    end

    @test fitness_b == 0
end

@testset "NGFocusing" begin
    domain = NGFocusing()

    a = VectorPheno("a", [4, 16])
    b = VectorPheno("b", [5, 14])

    mix = PairMix(1, domain, TestPairOutcome, a, b)
    o = (mix)()
    @test o.score == true

    a = VectorPheno("a", [4, 16])
    b = VectorPheno("b", [5, 16])

    mix = PairMix(1, domain, TestPairOutcome, a, b)
    o = (mix)()
    @test o.score == false

    a = VectorPheno("a", [5, 16, 8])
    b = VectorPheno("b", [4, 16, 6])

    mix = PairMix(1, domain, TestPairOutcome, a, b)
    o = (mix)()
    @test o.score == true
end

@testset "NGRelativism" begin
    domain = NGRelativism()

    a = VectorPheno("a", [1, 6])
    b = VectorPheno("b", [4, 5])
    c = VectorPheno("c", [2, 4])

    mix = PairMix(1, domain, TestPairOutcome, a, b)
    o = (mix)()
    @test o.score == true

    mix = PairMix(1, domain, TestPairOutcome, b, c)
    o = (mix)()
    @test o.score == true

    mix = PairMix(1, domain, TestPairOutcome, c, a)
    o = (mix)()
    @test o.score == true
end

@testset "Roulette/Reproduce/Elitism" begin
    rng = StableRNG(123)
    winners = Set([BitstringGeno(string("A-", x), ones(Bool, 10), Set{String}()) for x in 1:5])
    losers = Set([BitstringGeno(string("A-", x), zeros(Bool, 10), Set{String}()) for x in 6:10])
    popA = GenoPop("A", 11, union(winners, losers))
    geno_cfg = DefaultBitstringConfig(width=10, default_val=false)
    popB = GenoPopConfig(key="B", n_genos=10, geno_cfg=geno_cfg)()
    pops = Set([popA, popB])
    domain = NGGradient()
    pheno_cfg = IntPhenoConfig()
    orderA = SamplerOrder(domain=domain, outcome=TestPairOutcome, subjects_key="A", subjects_cfg=pheno_cfg,
                          tests_key="B", tests_cfg=pheno_cfg, n_samples=5, rng=rng)
    orders = Set([orderA])
    cfg = SerialJobConfig()
    job = cfg(orders, pops)
    outcomes = Set{Outcome}(job)
    selector = RouletteSelector(rng=rng, n_elite=5, n_singles=5, n_couples=0)
    selections = (selector)(popA, outcomes)
    @test Set(selections.elites) == winners
    reproducer = BitstringReproducer(rng, 0.05)
    newpop = (reproducer)("A", 11, selections)
    @test length(newpop.genos) == 10
    flag = true
    genokeys = keys(Dict{String, Genotype}(newpop))
    for s in [string("A-", x) for x in 1:5]
        if s ∉ genokeys
            flag = false
        end
    end
    for s in [string("A-", x) for x in 11:15]
        if s ∉ genokeys
            flag = false
        end
    end
    @test flag
end

@testset "Coev" begin
    # RNG #
    coev_key = "NG: Control"
    trial = 1
    rng = StableRNG(123)

    ## Populations ##
    width = 100
    n_genos = 25
    popA = GenoPopConfig(
        key="A", n_genos=n_genos,
        geno_cfg=DefaultBitstringConfig(width=width, default_val=true))()
    popB = GenoPopConfig(
        key="B", n_genos=n_genos,
        geno_cfg=DefaultBitstringConfig(width=width, default_val=false))()
    pops = Set([popA, popB])

    ## Job ##
    job_cfg = SerialJobConfig()

    ## Orders ##
    domain = NGGradient()
    pheno_cfg = IntPhenoConfig()
    orderA = SamplerOrder(
        domain=domain, outcome=TestPairOutcome,
        subjects_key="A", subjects_cfg=pheno_cfg,
        tests_key="B", tests_cfg=pheno_cfg,
        n_samples=15, rng=rng)
    orderB = SamplerOrder(
        domain=domain, outcome=TestPairOutcome,
        subjects_key="B", subjects_cfg=pheno_cfg,
        tests_key="A", tests_cfg=pheno_cfg,
        n_samples=15, rng=rng)
    orders = Set([orderA, orderB])

    ## Spawners ##
    mutrate = 0.05
    selectorA = RouletteSelector(rng=rng, n_elite=0, n_singles=n_genos, n_couples=0)
    reproducerA = BitstringReproducer(rng=rng, mutrate=mutrate)
    spawnerA = Spawner("A", selectorA, reproducerA)
    selectorB = RouletteSelector(rng=rng, n_elite=0, n_singles=n_genos, n_couples=0)
    reproducerB = BitstringReproducer(rng=rng, mutrate=mutrate)
    spawnerB = Spawner("B", selectorB, reproducerB)
    spawners = Set([spawnerA, spawnerB])

    ## Loggers ##
    loggers = Set([BasicGeneLogger("A"), FitnessLogger("A"),
                   BasicGeneLogger("B"), FitnessLogger("B")])
    coev_cfg = CoevConfig(;
        key=coev_key,
        trial=trial,
        job_cfg=job_cfg,
        orders=orders, 
        spawners=spawners,
        loggers=loggers,)
    gen = 1
    while gen < 200
        gen += 1
        pops = coev_cfg(gen, pops)
    end
end



end