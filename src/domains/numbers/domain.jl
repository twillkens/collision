export NumbersGame, NGGradient, NGFocusing, NGRelativism

abstract type NumbersGame <: Domain end
    
struct NGGradient <: NumbersGame end

struct NGFocusing <: NumbersGame end

struct NGRelativism <: NumbersGame end