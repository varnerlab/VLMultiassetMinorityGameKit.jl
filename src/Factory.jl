function _build(modeltype::Type{T}, data::NamedTuple) where T <: Union{AbstractAgentType, AbstractGameType, AbstractMarketType}
    
    # build an empty model
    model = modeltype();

    # if we have options, add them to the contract model -
    if (isempty(data) == false)
        for key ∈ fieldnames(modeltype)
            
            # check the for the key - if we have it, then grab this value
            value = nothing
            if (haskey(data, key) == true)
                # get the value -
                value = data[key]
            end

            # set -
            setproperty!(model, key, value)
        end
    end
 
    # return -
    return model
end

# build functions -
build(modeltype::Type{MySimpleAgentModel}, data::NamedTuple)::MySimpleAgentModel = _build(modeltype, data)
build(modeltype::Type{MySimpleGameModel}, data::NamedTuple)::MySimpleGameModel = _build(modeltype, data)
