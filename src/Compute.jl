function _update_agent_memory(model::MySimpleAgentModel, data::Array{Int64,1})

    # ok, so we have the "class" of each of the tickers, add this data to the agent's memory -
    for i ∈ eachindex(data)
        
        # get the class -
        class = data[i];
        
        # get the memory -
        memory = model.memory[i];

        @show memory

        # add the data -
        push!(memory, class);
    end
end

function _update_agent_wealth(model::MySimpleAgentModel, price::Array{Float64,1}, step::Int64)

    # update the wealth of the agent -
    for i ∈ eachindex(price)
        
        # get the price -
        p = price[i];
        
        # get the shares -
        n = model.shares[step,i];
        
        # update the wealth -
        model.wealth[step,i] = n*p;
    end
end

function _trade(model::MySimpleAgentModel, step::Int64)

    # initialize -
    memory = model.memory;
    policy = model.policy;
    actions = model.actions;
    
    for i ∈ eachindex(memory)
        
        # get the memory for this asset -
        memory_buffer_for_asset = memory[i];
        if (isfull(memory_buffer_for_asset) == false)

            # buffer is not full, so skip (no trade, shares stay the same) -
            model.shares[step+1,i] = model.shares[step,i];

            # we don't have enough data to make a decision, so skip -
            continue;
        else
           
            # ok, so we have enough data to make a decision, so let's do it -
            # do we have this state in out policy? -
            asset_policy = policy[i];
            if (haskey(asset_policy, memory_buffer_for_asset) == false)
                
                # we don't have this state in our policy, so let's add it -
                action_class = rand(-1:1);
                asset_policy[memory_buffer_for_asset] = action_class;

                # update the shares -
                Δ = actions[i][action_class];
                old_shares = model.shares;
                for j ∈ eachindex(old_shares)
                    old_shares[step+1,i] = old_shares[step,i]*Δ;
                end
                model.shares = old_shares;
            else
                    
                # we have this state in our policy, so let's get the action -
                action_class = asset_policy[memory_buffer_for_asset];
                Δ = actions[i][action_class];
                old_shares = model.shares;
                for j ∈ eachindex(old_shares)
                    old_shares[step+1,i] = old_shares[step,i]*Δ;
                end
                model.shares = old_shares;
            end
        end
    end
end

(model::MySimpleAgentModel)(data::Array{Int64,1}) = _update_agent_memory(model, data)
(model::MySimpleAgentModel)(step::Int64, price::Array{Float64,1}) = _update_agent_wealth(model, price, step)