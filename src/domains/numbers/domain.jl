export NumbersGame, NGGradient, NGFocusing, NGRelativism

abstract type NumbersGame <: Domain end
    
struct NGGradient <: NumbersGame end

function NGGradient(cfg::NamedTuple)
    NGGradient()
end

struct NGFocusing <: NumbersGame end

function NGFocusing(cfg::NamedTuple)
    NGFocusing()
end

struct NGRelativism <: NumbersGame end

function NGRelativism(cfg::NamedTuple)
    NGRelativism()
end