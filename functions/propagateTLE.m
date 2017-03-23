%  MATLAB Function < propagateTLE >
% 
%  Purpose:     propagation with SGP4 of all TLE observations to next
%               observation
%  Input:
%   - extract:  structure array containing: 
%                   1) ID:          satellite identifier
%                   2) orbit:       time of TLE measurements and corresponding 
%                                   Keplerian elements (t,a,e,i,O,o,TA)
%                   3) propagator:  data for propagation for each
%                                   observation time (nd,ndd,Bstar)
%  Output:
%   - kepler:   array containing Keplerian elements in SI units with order:
%               [t,a,e,i,O,o,TA,MA]

function kepler = propagateTLE(extract)

t = extract.orbit(:,1)*(24*60);     % [min]     time
MA = extract.orbit(:,8);            % [rad]     mean anomaly
O = extract.orbit(:,5);             % [rad]     right ascension of ascending node
o = extract.orbit(:,6);             % [rad]     argument of perigee
e = extract.orbit(:,3);             % [-]       eccentricity
i = extract.orbit(:,4);             % [rad]     inclination
n = extract.propagator(:,1);        % [rad/min] mean motion
Bstar = extract.propagator(:,4);    % [1/Re]    drag term

%...Propagate
for j = 2:size(t,1)
    cartesian(j-1,:) = horzcat(t(j)/(24*60),SGP4(t(j)-t(j-1),MA(j),O(j),o(j),e(j),i(j),n(j),Bstar(j)));
end

%...Covert to Keplerian elements
kepler = cart2kepl(cartesian);