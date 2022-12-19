export PhenoIngredient, PairRecipe, PairMix
export AllvsAllOrder, SamplerOrder
export ParallelJob, CoevConfig
export ParallelJobsConfig, SerialJobConfig

function(o::PairOrder)(pops::Set{GenoPop})
    popdict = Dict{String, Population}(pops)
    subjects = popdict[o.subjects_cfg.popkey]
    tests = popdict[o.tests_cfg.popkey]
    (o)(subjects, tests)
end

struct AllvsAllOrder{D <: Domain, S <: PhenoConfig, T <: PhenoConfig} <: PairOrder
    domain::D
    outcome::Type{<:Outcome}
    subjects_cfg::S
    tests_cfg::T
end

function(o::AllvsAllOrder)(subjects::GenoPop, tests::GenoPop)
    pairs = unique(Set,
                   Iterators.filter(allunique,
                   Iterators.product(subjects.genos, tests.genos)))
    Set([PairRecipe(o, subject, test) for (subject, test) in pairs])
end

Base.@kwdef struct SamplerOrder{D <: Domain, S <: PhenoConfig, T <: PhenoConfig} <: PairOrder
    domain::D
    outcome::Type{<:Outcome}
    subjects_cfg::S
    tests_cfg::T
    rng::AbstractRNG
    n_samples::Int
end

function(o::SamplerOrder)(subjects::GenoPop, tests::GenoPop)
    recipes = Set{Recipe}()
    for subject in subjects.genos
        for test in sample(o.rng, collect(tests.genos), o.n_samples, replace=false)
            recipe = PairRecipe(o, subject, test)
            push!(recipes, recipe)
        end
    end
    recipes
end

struct PairRecipe{D <: Domain, S <: PhenoConfig, T <: PhenoConfig} <: Recipe
    domain::D
    outcome::Type{<:Outcome}
    subject_key::String
    subject_cfg::S
    test_key::String
    test_cfg::T
end

function(r::PairRecipe)(phenodict::Dict{String, Phenotype})
    subject_pheno = phenodict[r.subject_key]
    test_pheno = phenodict[r.test_key]
    PairMix(r.domain, r.outcome, subject_pheno, test_pheno)
end

function Set{String}(recipe::PairRecipe)
    Set([recipe.subject_key, recipe.test_key])
end

function PairRecipe(order::PairOrder,
                    subject_geno::Genotype,
                    test_geno::Genotype)
    PairRecipe(order.domain,
               order.outcome,
               subject_geno.key, order.subjects_cfg,
               test_geno.key, order.tests_cfg)
end


function Set{Recipe}(orders::Set{<:Order}, pops::Set{GenoPop})
    union([(order)(pops) for order in orders]...)
end

function Set{Set{Recipe}}(recipes::Set{<:Recipe}, n_subsets::Int)
    n_mix = div(length(recipes), n_subsets)
    recipe_vecs = collect(Iterators.partition(collect(recipes), n_mix))
    # If there are leftovers, divide the excess among the other subsets
    if length(recipe_vecs) > n_subsets
        excess = pop!(recipe_vecs)
        for i in eachindex(excess)
            push!(recipe_vecs[i], excess[i])
        end
    end
    Set([Set{Recipe}(rvec) for rvec in recipe_vecs])
end

function Set{Set{Recipe}}(order::Order, pops::Set{GenoPop}, n_processes::Int)
    recipes = (order)(pops)
    Set{Set{Recipe}}(recipes, n_processes)
end

function Set{Set{Recipe}}(orders::Set{<:Order}, pops::Set{GenoPop}, n_processes::Int)
    recipes = Set{Recipe}(orders, pops)
    Set{Set{Recipe}}(recipes, n_processes)
end

struct ParallelJob <: Job
    recipes::Set{Recipe}
    genodict::Dict{String, Genotype}
    function ParallelJob(recipes::Set{Recipe}, genodict::Dict{String, Genotype})
        pairs = [key => genodict[key] for recipe in recipes for key in Set{String}(recipe)]
        job_genodict = Dict(pairs)
        # for recipe in recipes
        #     keys = Set{String}(recipe)
        #     for key in keys
        #         job_genodict[key] = genodict[key]
        #     end
        # end
        new(recipes, job_genodict)
    end
end

Base.@kwdef struct ParallelJobsConfig <: Config
    n_jobs::Int
end

function(cfg::ParallelJobsConfig)(orders::Set{<:Order}, pops::Set{GenoPop})
    recipe_sets = Set{Set{Recipe}}(orders, pops, cfg.n_jobs)
    genodict = Dict{String, Genotype}(pops)
    Set([ParallelJob(recipes, genodict) for recipes in recipe_sets])
end

struct SerialJob <: Job
    recipes::Set{Recipe}
    phenodict::Dict{String, Phenotype}
end

Base.@kwdef struct SerialJobConfig <: Config
end

function(cfg::SerialJobConfig)(orders::Set{<:Order}, pops::Set{GenoPop})
    recipes = Set{Recipe}(orders, pops)
    genodict = Dict{String, Genotype}(pops)
    phenodict = Dict{String, Phenotype}(recipes, genodict)
    SerialJob(recipes, phenodict)
end
# function Set{ParallelJob}(recipe_sets::Set{Set{Recipe}}, genodict::Dict{String, Genotype})
#     Set([ParallelJob(recipes, genodict) for recipes in recipe_sets])
# end

# function Set{ParallelJob}(orders::Set{<:Order}, pops::Set{GenoPop}, cfg::CoevConfig)
#     recipe_sets = Set{Set{Recipe}}(orders, pops, cfg.n_processes)
#     genodict = Dict{String, Genotype}(pops)
#     Set([ParallelJob(recipes, genodict) for recipes in recipe_sets])
# end

function add_pheno!(key::String,
                    pheno_cfg::PhenoConfig,
                    genodict::Dict{String, Genotype},
                    phenodict::Dict{String, Phenotype},)
    if key ∉ keys(phenodict)
        geno = genodict[key]
        pheno = (pheno_cfg)(geno)
        phenodict[key] = pheno
    end
end

function add_pheno!(recipe::PairRecipe,
                    genodict::Dict{String, Genotype},
                    phenodict::Dict{String, Phenotype},)
    add_pheno!(recipe.subject_key, recipe.subject_cfg, genodict, phenodict)
    add_pheno!(recipe.test_key, recipe.test_cfg, genodict, phenodict)
end

struct PairMix{D <: Domain, S <: Phenotype, T <: Phenotype}
    domain::D
    outcome::Type{<:Outcome}
    subject::S
    test::T
end

function(p::PairMix)()
    p.outcome(p.domain, p.subject, p.test)
end

function Dict{String, Phenotype}(recipes::Set{<:Recipe}, genodict::Dict{String, Genotype},)
    phenodict = Dict{String, Phenotype}()
    [add_pheno!(recipe, genodict, phenodict) for recipe in recipes]
    phenodict
end

function Set{Mix}(recipes::Set{<:Recipe},
                  phenodict::Dict{String, Phenotype},)
    Set([(recipe)(phenodict) for recipe in recipes])
end

function Set{Mix}(recipes::Set{<:Recipe},
                  genodict::Dict{String, Genotype},)
    phenodict = Dict{String, Phenotype}(recipes, genodict)
    Set{Mix}(recipes, phenodict)
end

function Set{Mix}(job::SerialJob)
    Set{Mix}(job.recipes, job.phenodict)
end

function Set{Mix}(job::ParallelJob)
    Set{Mix}(job.recipes, job.genodict)
end

function Set{Outcome}(job::SerialJob)
    mixes = Set{Mix}(job.recipes, job.phenodict)
    Set([(mix)() for mix in mixes])
end

function Set{Outcome}(job::ParallelJob)
    mixes = Set{Mix}(job.recipes, job.genodict)
    Set([(mix)() for mix in mixes])
end

function Set{Outcome}(jobs::Set{ParallelJob})
    futures = [remotecall(Set{Outcome}, i, job) for (i, job) in enumerate(jobs)]
    outcomes = [fetch(f) for f in futures]
    union(outcomes...)
end