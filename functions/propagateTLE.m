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
%                   1) offset:      TLEs to skip
%  Output:
%   - kepler:   array containing Keplerian elements in SI units with order:
%               [t,a,e,i,O,o,TA,MA]

function kepler = propagateTLE(extract,options)

%...Global constants
global Re Tm

%...Extract options
k = options.offset;

%...Extract data
t = extract.orbit(:,1)*Tm;          % [min]     time
a = extract.orbit(:,2)/Re;          % [Re]      semi-major axis
MA = extract.orbit(:,8);            % [rad]     mean anomaly
O = extract.orbit(:,5);             % [rad]     right ascension of ascending node
o = extract.orbit(:,6);             % [rad]     argument of perigee
e = extract.orbit(:,3);             % [-]       eccentricity
i = extract.orbit(:,4);             % [rad]     inclination
n = extract.propagator(:,1);        % [rad/min] mean motion
Bstar = extract.propagator(:,4);	% [1/Re]    drag term

%...Propagate
for j = (k+1):k:size(t,1)
    cartesian((j-1)/k,:) = horzcat(t(j)/Tm,SGP4(t(j)-t(j-k),a(j),MA(j),O(j),o(j),e(j),i(j),n(j),Bstar(j)));
end

%...Covert to Keplerian elements
kepler = cart2kepl(cartesian);



