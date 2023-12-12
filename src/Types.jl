abstract type AbstractAgentType end
abstract type AbstractGameType end

mutable struct MySimpleAgentModel <: AbstractAgentType
    
    # data members -
    wealth::Union{Nothing,Array{Float64,2}}
    shares::Union{Nothing,Array{Float64,2}}
    memory::Union{Nothing, Dict{Int64, CircularBuffer{Int}}}
    
    policy::Union{Nothing,Array{Dict{Vector{Int64}, Int64},1}}
    actions::Union{Nothing, Array{Dict{Int64, Float64}, 1}}
    
    Q::Union{Nothing, Array{Float64,2}}
    states::Union{Nothing, Dict{Int64, Vector{Int64}}} # this is a map from index to the state vector
    coordinates::Union{Nothing, Dict{Vector{Int64}, Int64}} # this is a map from the state vector to the index

       
    # Constructor -
    MySimpleAgentModel() = new();
end

mutable struct MySimpleGameModel <: AbstractGameType
    
    # data members -
    agents::Dict{Int64, MySimpleAgentModel}
       
    # Constructor -
    MySimpleGameModel() = new();
end