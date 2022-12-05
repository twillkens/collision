
"""
Initializes a vector genotype using the provided default value and width
"""
function BasicGeno{Vector{T}, D}(key::String, val::Real, width::Int) where {T <: Real,
                                                                            D <: Domain}
    v = fill(val, width)
    BasicGeno{Vector{T}, D}(key, v)
end

"""
Initializes a vector genotype using the provided random object and width
"""
function BasicGeno{Vector{T}, D}(key::String, rng::AbstractRNG, width::Int) where {T <: Real,
                                                                                   D <: Domain}
    v = rand(rng, T, width)
    BasicGeno{Vector{T}, D}(key, v)
end

"""
Uses the cfg to initialize either a random or filled vector
"""
function BasicGeno{Vector{T}, D}(key::String, cfg::NamedTuple) where {T <: Real, D <: Domain}
    if haskey(cfg, :genome_default_val)
        BasicGeno{Vector{T}, D}(key, cfg.genome_default_val, cfg.genome_width)
    elseif haskey(cfg, :rng)
        BasicGeno{Vector{T}, D}(key, cfg.rng, cfg.genome_width)
    else
        error("Invalid config for genome")
    end
end
