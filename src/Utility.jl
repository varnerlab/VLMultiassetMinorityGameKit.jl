function _encode(growth::Float64; threshold::Float64 = 0.05)::Int64

    # initialize -
    s = 0;

    # encode -
    if (growth > threshold) # up => class 1
        s = 1; 
    elseif (growth < -threshold) # down => class 2
        s = 2;
    else
        s = 3; # flat => class 3
    end

    return s;
end