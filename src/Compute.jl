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

function _update_agent_wealth(model::MySimpleAgentModel, price::Array{Float64,1}, step::Int64)

    # update the wealth of the agent -
    for i ∈ eachindex(price)
        
        # get the price -
        p = price[i];
        
        # get the shares -
        n = model.shares[step+1,i];
        
        # update the wealth -
        model.wealth[step+1,i] = n*p;
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
            # we are going to look for this state in our policy
            statekey = convert(Vector{Int64}, memory_buffer_for_asset);

            
            # do we have this state in out policy? -
            asset_policy = policy[i];
            Δ = nothing;
            if (haskey(asset_policy, statekey) == false) # we don't have this state in our policy, so let's add it, to the policy, and take a random action -
                
                # take a random action -
                action_class = rand(-1:1);
                asset_policy[statekey] = action_class; # add this state,action to our policy
                Δ = actions[i][action_class]; # get the change in shares associated with this (state,action)

                # Finally, update our list of states (we add them )
            else
                    
                # we have this state in our policy, so let's get the action -
                action_class = asset_policy[statekey];
                Δ = actions[i][action_class];
            end

            old_shares = model.shares;
            for j ∈ eachindex(old_shares)
                old_shares[step+1,i] = old_shares[step,i]*Δ;
            end
            model.shares = old_shares;
        end
    end
end

function trade(model::MySimpleAgentModel, price::Array{Float64,1}, step::Int64; ϵ::Float64=0.1)

    # initialize -
    memory = model.memory;
    actions = model.actions;
    coordinates = model.coordinates;
    Q = model.Q; # get our Q table, this is the agent's brain
    γ = model.γ; # discount factor
    α = model.α; # learning rate
    
    # process *each* asset -
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
            # we are going to look for this state in our policy
            statekey = convert(Vector{Int64}, memory_buffer_for_asset);

            # compute an action to take -
            aᵢ = nothing; # this is the action we will take
            if (rand() < ϵ)

                # select an index at random -
                aᵢ = rand(1:3); # 1 = buy 2 = hold, 3 = sell
            else

                # ok, so if we get here, then we are going to use our brain to make a decision -
                state_index = coordinates[statekey];
                aᵢ = argmax(Q[state_index,:]);
            end

            # ok, so we have an action, let's take it -
            Δ = actions[i][aᵢ];
            
            # we make the trade, and then see what happens -
            old_shares = model.shares;
            for j ∈ eachindex(old_shares)
                old_shares[step+1,i] = old_shares[step,i]*Δ;
            end
            model.shares = old_shares;

            # update the wealth array -
            _update_agent_wealth(model, price, step);

            # update the Q table -
            s = coordinates[statekey];
            r = model.wealth[step+1,i];
            Q[s,aᵢ] = Q[s,aᵢ] + α*(r + γ*maximum(Q[s,:]) - Q[s,aᵢ]);
            model.Q = Q;
        end
    end
end


(model::MySimpleAgentModel)(data::Array{Int64,1}) = _update_agent_memory(model, data)
(model::MySimpleAgentModel)(step::Int64, price::Array{Float64,1}) = _update_agent_wealth(model, price, step)