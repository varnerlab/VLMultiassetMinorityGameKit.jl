function _update_agent_memory(model::MySimpleAgentModel, data::Array{Int64,1})

    # ok, so we have the "class" of each of the tickers, add this data to the agent's memory -
    for i ∈ eachindex(data)
        
        # get the class -
        class = data[i];
        
        # get the memory -
        memory = model.memory[i];
        
        # add the data -
        push!(memory, class);
    end

end

function _trade(model::MySimpleAgentModel)

    # initialize -
    memory = model.memory;
    policy = model.policy;
    
    for i ∈ eachindex(memory)
        
        # get the memory for this asset -
        memory_buffer_for_asset = memory[i];
        if (isfull(memory_buffer_for_asset) == false)

            # we don't have enough data to make a decision, so skip -
            continue;
        else
           
            # ok, so we have enough data to make a decision, so let's do it -
            # do we have this state in out policy? -
            asset_policy = policy[i];
            if (haskey(asset_policy, memory_buffer_for_asset) == false)
                
                # we don't have this state in our policy, so let's add it -
                asset_policy[memory_buffer_for_asset] = rand(-1:1) # select a random action
            else
                    
                # we have this state in our policy, so let's get the action -
                action = asset_policy[memory_buffer_for_asset];
                
                # update the shares -
                model.shares[i] *= action;
            end
        end
    end
end

(model::MySimpleAgentModel)(data::Array{Int64,1}) = _update_agent_memory(model,data)