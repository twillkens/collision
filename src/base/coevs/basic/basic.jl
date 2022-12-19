export BasicCoev

struct BasicCoev <: Coevolution
    gen::Int
    pops::Set{Population}
    orders::Set{Order}
    selectors::Set{Selector}
    reproducers::Set{Reproducer}
end


function step(coev::BasicCoev)
    

end