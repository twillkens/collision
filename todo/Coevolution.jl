module Coevolution

using StableRNGs
using Logging
using Statistics
using YAML
using JSON
import Formatting
import Dates
using PyCall
using Random: AbstractRNG, default_rng, randperm, shuffle, randn!

import Base: show, copy, minimum, summary, getproperty, rand, getindex, length,
             copyto!, setindex!, replace

const center_initializer = PyNULL()
const kmeans = PyNULL()
const xmeans = PyNULL()

function __init__()
    mod = "pyclustering.cluster.center_initializer"
    copy!(center_initializer, pyimport_conda(mod, "pyclustering", "conda-forge"))
    mod = "pyclustering.cluster.kmeans"
    copy!(kmeans, pyimport_conda(mod, "pyclustering", "conda-forge"))
    mod = "pyclustering.cluster.xmeans"
    copy!(xmeans, pyimport_conda(mod, "pyclustering", "conda-forge"))
end

include("coev.jl")

end