%  MATLAB Function < peaksTLE >
%
%  Purpose:     detect changes in Keplerian elements
%  Input:
%   - kepler:   Keplerian elements of satellite to be analyzed 
%   - options:  structure array containing:
%                   1) ignore:      percent of data to ignore at beginning
%                                   of observations
%                   2) factor:      safety factor for thrust detection
% Output:
%   - locs:                         location of peaks in Keplerian elements
%   - continuousThrustParameter:    parameter for continuous thrust
%                                   detection

function [locs,continuousThrustParameter] = peaksTLE(kepler,options)

%...Extract options
ignore = options.ignore;
factor = options.factor;

%...Ignore intial part of TLE (avoid injection maneuver, etc.)
lower = ceil(ignore*size(kepler,1));
lower(lower==0) = 1;

%...Change in orbital elements
da = diff(kepler(lower:end,2));
de = diff(kepler(lower:end,3));
di = diff(kepler(lower:end,4));
dO = diff(kepler(lower:end,5));

%...Remove changes of 2pi degrees from O and o
dO(dO>pi) = dO(dO>pi)-2*pi;
dO(dO<-pi) = dO(dO<-pi)+2*pi;

%...Get statistics
data = statTLE('TLE',[da,de,di,dO],options);

%...Detect thrust peaks
warning('off')
[~,locs_a_1] = findpeaks(da,'MinPeakHeight',factor*data.a(1)); % positive change
[~,locs_a_2] = findpeaks(-da,'MinPeakHeight',factor*data.a(2)); % negative change
[~,locs_e_1] = findpeaks(de,'MinPeakHeight',factor*data.e(1)); % positive change
[~,locs_e_2] = findpeaks(-de,'MinPeakHeight',factor*data.e(2)); % negative change
[~,locs_i_1] = findpeaks(di,'MinPeakHeight',factor*data.i(1)); % positive change
[~,locs_i_2] = findpeaks(-di,'MinPeakHeight',factor*data.i(2)); % negative change
[~,locs_O_1] = findpeaks(dO,'MinPeakHeight',factor*data.O(1)); % positive change
[~,locs_O_2] = findpeaks(-dO,'MinPeakHeight',factor*data.O(2)); % negative change
warning('on')

%...Merge positive and negative values
locs_a = lower+sort(vertcat(locs_a_1,locs_a_2));
locs_e = lower+sort(vertcat(locs_e_1,locs_e_2));
locs_i = lower+sort(vertcat(locs_i_1,locs_i_2));
locs_O = lower+sort(vertcat(locs_O_1,locs_O_2));

%...Combine in cell array
locs = {locs_a,locs_e,locs_i,locs_O};

%...Continuous thrust parameter
continuousThrustParameter = median(da)/median(abs(da));