function [int] = Trunc(x)
%trunc removes fractional part of a real number
%   INPUT: X
%   OUTPUT: INT
    int = x-Frac(x);
end