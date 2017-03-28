%  MATLAB Function < constants >
% 
%  Purpose:	define constants globally
%  Input:
%   - N/A
%  Output:
%   - N/A

function constants()

global mu Re Ts Tm Th J2 J4 H rho0

%...Earth physical constants
mu = 398600.441e9;  % [m3/s2]   Earth gravitational parameter
Re = 6378.136e3;    % [m]       Earth radius
J2 = 1082.63e-6;    % [-]       J2 effect
J4 = -1.65597e-6;   % [-]       J4 effect

%...Time constants
Ts = 86164.100352;  % [s]       Earth sidereal day (second)
Tm = Ts/60;         % [min]     Earth sidereal day (minute)
Th = Tm/60;         % [hr]      Earth sidereal day (hour)

%...Earth atmosphere
g0 = 9.80665;       % [m/s^2]   Surface gravitational constant
R = 287;            % [J/kg/K]  Air gas constant
T = 240;            % [K]       Tempterture for exponential model
H = R*T/g0;         % []        Scale height
rho0 = 1.225;       % [kg/m^3]  Surface density