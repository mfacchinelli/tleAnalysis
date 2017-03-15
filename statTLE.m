%  Purpose:     correct the TLE information from element overlap
%  Input:
%   - file:     file name to be corrected, containing TLE information
%  Output:
%   - N/A

function statTLE(kepler)

%...Change in orbital elements
da = diff(kepler(:,2));
de = diff(kepler(:,3));
di = diff(kepler(:,4));
dO = diff(kepler(:,5));
do = diff(kepler(:,6));