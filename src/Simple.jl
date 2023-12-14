function evaluate(model::MySimpleGameModel, data::Dict{String, DataFrame}, 
    tickers::Array{String,1}; number_of_steps::Int64 = 10, startindex::Int64 = 3, Δt::Float64 = (1/252),
    threshold::Float64 = 0.05)

    # initialize -
    agents = model.agents;
    ϵ = model.ϵ;
    number_of_assets = length(data);

    # compute the start state -
    s = Array{Int64,1}(undef, number_of_assets);
    for k ∈ eachindex(tickers)
        
        # get the ticker -
        ticker = tickers[k];

        # get the price -
        p₁ = data[ticker][startindex-2, :close];
        p₂ = data[ticker][startindex-1, :close];

        # compute the return -
        log_return = (1/Δt)*log(p₂ / p₁);

        # encode -
        s[k] = _encode(log_return, threshold = threshold);
    end
    foreach(a -> _update_current_agent_memory(a,s), values(agents));

    # main loop -
    for i ∈ 1:number_of_steps
        
        # compute the index -
        j  = startindex + (i - 1);

        # build the price array (vwap of the current day) -
        vwap_price_array = zeros(number_of_assets);
        for k ∈ eachindex(tickers)
            
            # get the ticker -
            ticker = tickers[k];

            # get the price -
            price = data[ticker][j, :volume_weighted_average_price];

            # set the price -
            vwap_price_array[k] = price;
        end

         # what class are we in?  compute the returns, hard code above or below a threshold -
        s′ = Array{Int64,1}(undef, number_of_assets);
        for k ∈ eachindex(tickers)

            # get the ticker -
            ticker = tickers[k];
        
            # get the price -
            start_price = data[ticker][j-1, :close];
            next_price = data[ticker][j, :volume_weighted_average_price];

            # compute the return -
            log_return = (1/Δt)*log(next_price / start_price);
            
            # encode -
            s′[k] = _encode(log_return, threshold = threshold);
        end
        foreach(a -> _update_next_agent_memory(a,s′), values(agents));

        # make the agents trade -
        [trade(a, vwap_price_array, i, ϵ = ϵ) for (_,a) ∈ agents]

        # memory swap -
        foreach(a -> _memory_swap(a), values(agents));
    end
end