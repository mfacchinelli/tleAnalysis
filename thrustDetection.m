%  Purpose:     detect thrust usage, by analyzing changes in TLE data
%  Input:
%   - kepler:   Keplerian elements of satellite to be analyzed 
%   - options:  
%  Output:
%   - N/A

function thrustDetection(kepler,options)

%...Change in orbital elements
da = diff(kepler(:,2));
de = diff(kepler(:,3));
di = diff(kepler(:,4));
dO = diff(kepler(:,5));
do = diff(kepler(:,6));

%...Remove changes of 360 degrees from O and o
% dO(diff(dO)>350) = dO(diff(dO)>350)+360;
% dO(diff(dO)<-350) = dO(diff(dO)<-350)-360;

%...Get statistics
statTLE([da,de,di,dO,do],options);

%...Detect thrust peaks
[peaks_a_1,locs_a_1] = findpeaks(da,'MinPeakHeight',std(da)); % positive change
[peaks_a_2,locs_a_2] = findpeaks(-da,'MinPeakHeight',std(da)); % negative change
[peaks_e_1,locs_e_1] = findpeaks(de,'MinPeakHeight',std(de)); % positive change
[peaks_e_2,locs_e_2] = findpeaks(-de,'MinPeakHeight',std(de)); % negative change
[peaks_i_1,locs_i_1] = findpeaks(di,'MinPeakHeight',std(di)); % positive change
[peaks_i_2,locs_i_2] = findpeaks(-di,'MinPeakHeight',std(di)); % negative change

%...Merge positive and negative values
peaks_a = sort(vertcat(peaks_a_1,peaks_a_2));
locs_a = sort(vertcat(locs_a_1,locs_a_2));
peaks_e = sort(vertcat(peaks_e_1,peaks_e_2));
locs_e = sort(vertcat(locs_e_1,locs_e_2));
peaks_i = sort(vertcat(peaks_i_1,peaks_i_2));
locs_i = sort(vertcat(locs_i_1,locs_i_2));

%...Check for repetitions
intersect(kepler(locs_a,1),kepler(locs_e,1))
intersect(kepler(locs_e,1),kepler(locs_i,1))
intersect(kepler(locs_a,1),kepler(locs_i,1))