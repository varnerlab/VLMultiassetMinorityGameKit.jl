abstract type AbstractAgentType end
abstract type AbstractGameType end
abstract type AbstracMarketType end

mutable struct MySimpleAgentModel <: AbstractAgentType
    
    # data members -
    id::UUID.uuid4
    shares::Array{Int64,2}
    memory::Dict{Int64, CircularBuffer{Int}}
    Q::Array{Dict{CircularBuffer{Int}, Array{Float64,1}},1}
    policy::Array{Dict{CircularBuffer{Int}, Int64},1}
    actions::Array{Dict{Int64, Float64}, 1}
       
    # Constructor -
    MySimpleAgentModel() = new();
end

mutable struct MySimpleGameModel <: AbstractGameType
    
    # data members -
    agents::Dict{UUID.uuid4, MySimpleAgentModel}
       
    # Constructor -
    MySimpleGameModel() = new();
end