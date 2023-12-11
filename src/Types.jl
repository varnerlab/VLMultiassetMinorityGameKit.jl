abstract type AbstractAgentType end
abstract type AbstractGameType end

mutable struct MySimpleAgentModel <: AbstractAgentType
    
    # data members -
    wealth::Union{Nothing,Array{Float64,2}}
    shares::Union{Nothing,Array{Float64,2}}
    memory::Union{Nothing, Dict{Int64, CircularBuffer{Int}}}
    Q::Union{Nothing, Array{Dict{CircularBuffer{Int}, Array{Float64,1}},1}}
    policy::Union{Nothing,Array{Dict{Vector{Int64}, Int64},1}}
    actions::Union{Nothing,Array{Dict{Int64, Float64}, 1}}
       
    # Constructor -
    MySimpleAgentModel() = new();
end

mutable struct MySimpleGameModel <: AbstractGameType
    
    # data members -
    agents::Dict{Int64, MySimpleAgentModel}
       
    # Constructor -
    MySimpleGameModel() = new();
end