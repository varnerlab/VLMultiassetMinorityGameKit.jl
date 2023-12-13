function evaluate(model::MySimpleGameModel, data::Dict{String, DataFrame}, 
    tickers::Array{String,1}; number_of_steps::Int64 = 10, startindex::Int64 = 2, Δt::Float64 = (1/252),
    threshold::Float64 = 0.05)

    # initialize -
    agents = model.agents;
    ϵ = model.ϵ;
    number_of_assets = length(data);

    # initialize: what is the starting price? (use the close price from the previous day)
    start_price_array = zeros(number_of_assets);
    for k ∈ eachindex(tickers)
        
        # get the ticker -
        ticker = tickers[k];

        # get the price -
        price = data[ticker][startindex-1, :close];

        # set the price -
        start_price_array[k] = price;
    end

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
        s = Array{Int64,1}(undef, number_of_assets);
        for k ∈ eachindex(tickers)
        
            # get the price -
            start_price = start_price_array[k];
            next_price = vwap_price_array[k];

            # compute the return -
            log_return = (1/Δt)*log(next_price / start_price);

            # what class are we in? -
            if (log_return > threshold) # up => class 1
                s[k] = 1; 
            elseif (log_return < -threshold) # down => class 2
                s[k] = 2;
            else
                s[k] = 3; # flat => class 3
            end
        end

        # update the data on the agents -
        [a(s) for (_,a) ∈ agents] # this will update the memory for the current state -

        # make the agents trade -
        [trade(a, vwap_price_array, i, ϵ = ϵ) for (_,a) ∈ agents]

        # update the start price (use the close price of the curreent day)
        for k ∈ eachindex(tickers)
        
            # get the ticker -
            ticker = tickers[k];
    
            # get the price -
            price = data[ticker][j, :close];
    
            # set the price -
            start_price_array[k] = price;
        end
    end
end