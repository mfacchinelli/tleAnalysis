%  MATLAB Function < constants >
% 
%  Purpose:     define constants globally
%  Input:
%   - N/A
%  Output:
%   - N/A

function constants()

global mu Re Ts Tm Th J2 J4

%...Earth physical constants
mu = 398600.441e9;  % [m3/s2]   Earth gravitational parameter
Re = 6378.136e3;    % [m]       Earth radius
J2 = 1082.63e-6;    % [-]       J2 effect
J4 = -1.65597e-6;   % [-]       J4 effect

%...Time constants
Ts = 86164.1004;    % [s]       Earth sidereal day (second)
Tm = Ts/60;         % [min]     Earth sidereal day (minute)
Th = Tm/60;         % [hr]      Earth sidereal day (hour)