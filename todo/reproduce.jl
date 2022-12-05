export reproduce!


function reproduce!(pop::Population)
    rfunc! = getfield(Main, Symbol(cfg.rfunc))
    rfunc!(pop)
end

function reproduce!(c::Coevolution)
    [reproduce!(pop) for pop in values(c.pops)]
end



function nsga_tourn(rng::StableRNG, parents::Array{T}, tourn_size::Int64) where {T <: AbstractCoevIndividual}
    contenders = rand(rng, parents, tourn_size)
    get_winner = get_winner_rng(rng)
    reduce(get_winner, contenders)
end

function disco!(pop::Population)
    n_children = pop.cfg.n_indiv - pop.cfg.n_elite
    children = []
    for _ in 1:n_children
        winner = nsga_tourn(pop.rng, pop.elites, pop.cfg.n_tourn)
        push!(children, chiled)


    end
end