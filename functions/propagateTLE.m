%  MATLAB Function < propagateTLE >
% 
%  Purpose:     propagation with SGP4 of all TLE observations to next
%               observation
%  Input:
%   - extract:  structure array containing: 
%                   1) orbit:       time of TLE measurements and corresponding 
%                                   Keplerian elements (t,a,e,i,O,o,TA)
%                   2) propagator:  data for propagation for each
%                                   observation time (nd,ndd,Bstar)
%   - options:  structure array containing: 
%                   1) offset:      number of steps to take between observations
%  Output:
%   - kepler:   array containing Keplerian elements in SI units with order:
%               [t,a,e,i,O,o,TA,MA]

function kepler = propagateTLE(extract,options)

%...Global constants
global Re Tm

%...Extract options
ignore = options.ignore;
k = options.offset;

%...Ignore intial part of TLE (avoid injection maneuver)
lower = ceil(ignore*size(extract.orbit,1));
lower(lower==0) = 1;

%...Extract data and convert to fuc*ed up units
t = extract.orbit(lower:end,1)*Tm;          % [min]     time
a = extract.orbit(lower:end,2)/Re;          % [Re]      semi-major axis
MA = extract.orbit(lower:end,8);            % [rad]     mean anomaly
O = extract.orbit(lower:end,5);             % [rad]     right ascension of ascending node
o = extract.orbit(lower:end,6);             % [rad]     argument of perigee
e = extract.orbit(lower:end,3);             % [-]       eccentricity
i = extract.orbit(lower:end,4);             % [rad]     inclination
n = extract.propagator(lower:end,1);        % [rad/min] mean motion
Bstar = extract.propagator(lower:end,4);	% [1/Re]    drag term

%...Propagate
for j = (k+1):k:size(t,1)-1
    cartesian((j-1)/k,:) = horzcat(t(j)/Tm,SGP4(t(j)-t(j-k),a(j),MA(j),O(j),o(j),e(j),i(j),n(j),Bstar(j)));
end

%...Covert to Keplerian elements
kepler = cart2kepl(cartesian);

%...Add first observation
kepler = vertcat([t(1)/Tm,a(1)*Re,e(1),i(1),O(1),o(1),extract.orbit(lower,7),MA(1)],kepler);