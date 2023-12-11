function evaluate(model::MySimpleGameModel, data::Dict{String, DataFrame}, 
    tickers::Array{String,1}; number_of_steps::Int64 = 10, startindex::Int64 = 1, Δt::Float64 = (1/252),
    threshold::Float64 = 0.05)

    # initialize -
    agents = model.agents;
    number_of_assets = length(data);

    # what is the starting price -
    start_price_array = zeros(number_of_assets);
    for k ∈ eachindex(tickers)
        
        # get the ticker -
        ticker = tickers[k];

        # get the price -
        price = data[ticker][startindex, :close];

        # set the price -
        start_price_array[k] = price;
    end

    # main loop -
    for i ∈ 1:number_of_steps
        
        # compute the index -
        j  = startindex + (i - 1);

        # build the price array -
        next_price_array = zeros(number_of_assets);
        for k ∈ eachindex(tickers)
            
            # get the ticker -
            ticker = tickers[k];

            # get the price -
            price = data[ticker][j, :close];

            # set the price -
            next_price_array[k] = price;
        end

        # what class are we in?  compute the returns, hard code above or below a threshold -
        class_array = Array{Int64,1}(undef, number_of_assets);
        for k ∈ eachindex(tickers)
            
            # get the price -
            price = next_price_array[k];
            start_price = start_price_array[k];

            # compute the return -
            log_return = (1/Δt)*log(price / start_price);

            # what class are we in? -
            if (log_return > threshold)
                class_array[k] = 1;
            elseif (log_return < -threshold)
                class_array[k] = -1;
            else
                class_array[k] = 0;
            end
        end

        # update the data on the agents -
        [a(class_array) for (_,a) ∈ agents]

        # make the agents trade -
        [_trade(a) for (_,a) ∈ agents]
    end

end