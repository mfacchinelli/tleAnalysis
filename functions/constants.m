%  MATLAB Function < constants >
% 
%  Purpose:     define constants globally
%  Input:
%   - N/A
%  Output:
%   - N/A

function constants()

global mu Re Te

%...Define constants
mu = 398600.441e9;          % [m3/s2]   Earth gravitational parameter
Re = 6378.136e3;            % [m]       Earth radius
Te = 23*3600+56*60+4.1004;  % [s]       Earth sidereal day