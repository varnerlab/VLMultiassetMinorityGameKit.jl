function _update_current_agent_memory(model::MySimpleAgentModel, data::Array{Int64,1})

    # ok, so we have the "class" of each of the tickers, add this data to the agent's memory -
    for i ∈ eachindex(data)
        
        # get the class -
        class = data[i];
        
        # get the memory -
        memory = model.currentmemory[i];

        # add the data -
        push!(memory, class);
    end
end

function _update_next_agent_memory(model::MySimpleAgentModel, data::Array{Int64,1})

    # ok, so we have the "class" of each of the tickers, add this data to the agent's memory -
    for i ∈ eachindex(data)
        
        # get the class -
        class = data[i];
        
        # get the memory -
        memory = model.nextmemory[i];

        # add the data -
        push!(memory, class);
    end
end

function _memory_swap(model::MySimpleAgentModel)

    # swap the memory buffers -
    model.currentmemory = deepcopy(model.nextmemory);
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


function trade(model::MySimpleAgentModel, price::Array{Float64,1}, step::Int64; ϵ::Float64=0.1)

    # initialize -
    memory = model.currentmemory;
    nextmemory = model.nextmemory; # this is the memory buffer we will use to store the next state
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
            model.balance[step] = model.balance[step-1]; # no change
            
            # update the wealth array (same shares)
            _update_agent_wealth(model, price, step);

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
            dn = 0.0;
            for j ∈ eachindex(old_shares)
                old_shares[step+1,i] = old_shares[step,i]*Δ;
                dn = (Δ - 1)*old_shares[step,i];

                @show (j, dn)
            end
            model.shares = old_shares;

            # compute the new balance -
            new_balance = model.balance[step] - sum(price.*dn);

            # update the wealth array (with new shares)
            _update_agent_wealth(model, price, step);

            # update the Q table -
            s = coordinates[statekey];
            budget = model.budget;
            r = (1/budget)*(model.wealth[step+1,i] - max(0, new_balance));

            # generate a random next state?
            next_memory_buffer_for_asset = nextmemory[i];
            nextstatekey = convert(Vector{Int64}, next_memory_buffer_for_asset);
            s′ = coordinates[nextstatekey];

            # update the Q table -
            Q[s,aᵢ] = Q[s,aᵢ] + α*(r + γ*maximum(Q[s′,:]) - Q[s,aᵢ]);
            model.Q = Q;

            # finally update the balance -
            model.balance[step+1] = new_balance;
        end
    end
end

(model::MySimpleAgentModel)(step::Int64, price::Array{Float64,1}) = _update_agent_wealth(model, price, step)