export BasicPop, KEY_SPLIT_TOKEN

KEY_SPLIT_TOKEN = "-"

struct BasicPop{O <: Organism} <: Population{O}
    key::String
    orgs::Set{O}
    stats::Set{Statistics}
    BasicPop{O}(key, orgs) where {O <: Organism} = new{O}(key, orgs, Set())
end

function BasicPop{O}(key::String, n_orgs::Int, cfg::NamedTuple) where {O <: Organism}
    orgs = Set{O}()
    for i in 1:n_orgs
        orgkey = join([key, i], KEY_SPLIT_TOKEN)  
        org = O(orgkey, cfg)
        push!(orgs, org)
    end
    BasicPop{O}(key, orgs)
end

function BasicPop{O}(key::String, cfg::NamedTuple) where {O <: Organism}
    BasicPop{O}(key, cfg.n_orgs, cfg)
end
