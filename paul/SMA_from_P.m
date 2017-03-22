function [SMA] = SMA_from_P(P,mu)
%SMA_FROM_P Summary of this function goes here
%   Detailed explanation goes here
    if nargin < 2
        mu = 398600.4415; % Astronomical Almanac '17 (TT)
    end
    P = 86400./P;
    SMA = power((mu.*P.*P)/(4*pi*pi),1/3);
end