# setup internal paths -
_PATH_TO_SRC = dirname(pathof(@__MODULE__))

# load external packages -
using DataStructures
using DataFrames
using Distributions
using UUIDs
using LinearAlgebra
using Statistics

# load my codes -
include(joinpath(_PATH_TO_SRC, "Types.jl"))
include(joinpath(_PATH_TO_SRC, "Factory.jl"))
include(joinpath(_PATH_TO_SRC, "Compute.jl"))
include(joinpath(_PATH_TO_SRC, "Utility.jl"))
include(joinpath(_PATH_TO_SRC, "Simple.jl"))
