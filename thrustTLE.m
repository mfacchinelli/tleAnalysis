%  MATLAB Function < thrustTLE >
%
%  Purpose:     detect thrust usage, by analyzing changes in TLE data
%  Input:
%   - kepler:   Keplerian elements of satellite to be analyzed 
%   - options:  structure array containing:
%                   1) ignore:      percent of data to ignore at beginning
%                                   of observations
%                   2) factor:      safety factor for thrust detection
%                   3) limit:       minimum separation in days between two
%                                   distinct thrusting maneuvers
% Output:
%   - N/A

function thrustTLE(kepler,options)

%...Extract options
ignore = options.ignore;
factor = options.factor;
limit = options.limit;

%...Change in orbital elements
lower = floor(ignore*size(kepler,1));
da = diff(kepler(lower:end,2));
de = diff(kepler(lower:end,3));
di = diff(kepler(lower:end,4));
dO = diff(kepler(lower:end,5));
do = diff(kepler(lower:end,6));

%...Get statistics
data = statTLE([da,de,di,dO,do],options);

%...Detect thrust peaks
warning('off')
[~,locs_a_1] = findpeaks(da,'MinPeakHeight',factor*data.a(1)); % positive change
[~,locs_a_2] = findpeaks(-da,'MinPeakHeight',factor*data.a(2)); % negative change
[~,locs_e_1] = findpeaks(de,'MinPeakHeight',factor*data.e(1)); % positive change
[~,locs_e_2] = findpeaks(-de,'MinPeakHeight',factor*data.e(2)); % negative change
[~,locs_i_1] = findpeaks(di,'MinPeakHeight',factor*data.i(1)); % positive change
[~,locs_i_2] = findpeaks(-di,'MinPeakHeight',factor*data.i(2)); % negative change
warning('on')

%...Merge positive and negative values
locs_a = lower+sort(vertcat(locs_a_1,locs_a_2));
locs_e = lower+sort(vertcat(locs_e_1,locs_e_2));
locs_i = lower+sort(vertcat(locs_i_1,locs_i_2));

%...Check for repetitions
thrustDays = [];
thrustDays = vertcat(thrustDays,intersect(kepler(locs_a,1),kepler(locs_e,1)));
thrustDays = vertcat(thrustDays,intersect(kepler(locs_e,1),kepler(locs_i,1)));
thrustDays = vertcat(thrustDays,intersect(kepler(locs_a,1),kepler(locs_i,1)));
thrustDays = unique(thrustDays);

%...Find thurst periods
if ~isempty(thrustDays)
    separation = diff(thrustDays);
    where = [0;find(separation>limit);size(separation,1)+1]+1;
    disp([newline,'Periods where trhust was detected:'])
    for i = 1:size(where,1)-1
        disp([num2str(i),char(9),num2str(floor(thrustDays(where(i)))),' - ',num2str(ceil(thrustDays(where(i+1)-1)))])
    end
else
    disp([newline,'No thrust was detected.'])
end