%  MATLAB Function < constants >
% 
%  Purpose:     define constants globally
%  Input:
%   - N/A
%  Output:
%   - N/A

function constants()

global mu Re Ts Tm Th

%...Define constants
mu = 398600.441e9;  % [m3/s2]   Earth gravitational parameter
Re = 6378.136e3;    % [m]       Earth radius
Ts = 86164.1004;    % [s]       Earth sidereal day (second)
Tm = Ts/60;         % [min]     Earth sidereal day (minute)
Th = Tm/60;         % [hr]      Earth sidereal day (hour)