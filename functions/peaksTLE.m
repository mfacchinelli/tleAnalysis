%  MATLAB Function < peaksTLE >
%
%  Purpose:     detect changes in Keplerian elements
%  Input:
%   - kepler:   Keplerian elements of satellite to be analyzed 
%   - options:  structure array containing:
%                   1) ignore:      percent of data to ignore at beginning
%                                   of observations
% Output:
%   - locs:                         location of peaks in Keplerian elements
%   - continuousThrustParameter:    parameter for continuous thrust
%                                   detection
%   - maxCTP:                       maximum CTP for no thrust (with factor)

function [locs,continuousThrustParameter,maxCTP] = peaksTLE(kepler,options)

%...Extract options
ignore = options.ignore;

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

%...Continuous thrust parameter
continuousThrustParameter = median(da)/median(abs(da));

%...Get statistics
data = statTLE({da,de,di,dO,continuousThrustParameter},options);

%...Continuous thrust threshold
maxCTP = data.CTP;

%...Detect thrust peaks
warning('off')
[~,locs_a_1] = findpeaks(da,'MinPeakHeight',data.a(1)); % positive change
[~,locs_a_2] = findpeaks(-da,'MinPeakHeight',data.a(2)); % negative change
[~,locs_e_1] = findpeaks(de,'MinPeakHeight',data.e(1)); % positive change
[~,locs_e_2] = findpeaks(-de,'MinPeakHeight',data.e(2)); % negative change
[~,locs_i_1] = findpeaks(di,'MinPeakHeight',data.i(1)); % positive change
[~,locs_i_2] = findpeaks(-di,'MinPeakHeight',data.i(2)); % negative change
[~,locs_O_1] = findpeaks(dO,'MinPeakHeight',data.O(1)); % positive change
[~,locs_O_2] = findpeaks(-dO,'MinPeakHeight',data.O(2)); % negative change
warning('on')

%...Merge positive and negative values
locs_a = lower+sort(vertcat(locs_a_1,locs_a_2));
locs_e = lower+sort(vertcat(locs_e_1,locs_e_2));
locs_i = lower+sort(vertcat(locs_i_1,locs_i_2));
locs_O = lower+sort(vertcat(locs_O_1,locs_O_2));

%...Combine in cell array
locs = {locs_a,locs_e,locs_i,locs_O};