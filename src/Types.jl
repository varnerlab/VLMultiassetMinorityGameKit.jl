abstract type AbstractAgentType end
abstract type AbstractGameType end
abstract type AbstracMarketType end

mutable struct MySimpleAgentModel <: AbstractAgentType
    
    # data members -
    id::UUID.uuid4
    wealth::Array{Float64,2}
    shares::Array{Int64,2}
    memory::Array{Int64,2}
    policy::Array{Dict{Array{Int64,1}, Int64},1}
       
    # Constructor -
    MySimpleAgentModel() = new();
end

mutable struct MySimpleGameModel <: AbstractGameType
    
    # data members -
    players::Dict{Int64, UUID.uuid4}
    tape::Array{Int64,2}
    market::Array{CircularBuffer{Int},1}
       

    # Constructor -
    MySimpleGameModel() = new();
end