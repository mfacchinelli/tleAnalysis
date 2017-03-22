function [ret_val] = FMod2p(x)
%FMod2p Returns mod 2PI of argument
    twopi = 2*pi;
    ret_val = x;
    i = Trunc(x/twopi);
    ret_val = ret_val-i*twopi;
    if (ret_val < 0)
        ret_val = ret_val + twopi;
    end
end