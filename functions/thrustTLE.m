%  MATLAB Function < thrustTLE >
%
%  Purpose:     detect thrust usage, by analyzing changes in TLE data
%  Input:
%   - kepler:   Keplerian elements of satellite to be analyzed 
%   - options:  structure array containing:
%                   1) showfig:     command whether to show plots
%                   2) ignore:      percent of data to ignore at beginning
%                                   of observations
%                   3) factor:      safety factor for thrust detection
%                   4) limit:       minimum separation in days between two
%                                   distinct thrusting maneuvers
%                   5) offset:      number of steps to take between observations
% Output:
%   - thrustPeriods:    array with lower and upper bounds for thrust
%                       periods, in days

function thrustTLE(kepler,options)

%...Extract options
showfig = options.showfig;
limit = options.limit;

%...Get locations of peaks
[locs,CTP] = peaksTLE(kepler,options); % CTP: continuous thrust parameter

%...Check for repetitions
thrustDays = [];
for i = 1:3
    for j = 1+i:4
        if i ~= j
            thrustDays = vertcat(thrustDays,intersect(kepler(locs{i},1),kepler(locs{j},1)));
        end
    end
end
thrustDays = unique(thrustDays);

%...Find thrust periods from change in orbital elements
thrustPeriods = [];
if ~isempty(thrustDays)
    impulsiveThrust = true;
    separation = diff(thrustDays);
    where = [0;find(separation>limit);size(separation,1)+1]+1;
    disp([newline,'Periods where thrust was detected:'])
    for i = 1:size(where,1)-1
        thrustPeriods(i,:) = [floor(thrustDays(where(i))),ceil(thrustDays(where(i+1)-1))];
        disp([num2str(i),char(9),num2str(floor(thrustDays(where(i)))),' - ',num2str(ceil(thrustDays(where(i+1)-1)))])
    end
else
    impulsiveThrust = false;
end

%...Find continuous thrust and/or satellite decay
if impulsiveThrust == false    
    %...Check if CTP is within constraints
    if CTP < -0.95 || abs(CTP) < 0.05
        continuousThrust = false;
    else 
        continuousThrust = true;
        disp([newline,'Continuous thrust detected.'])
    end
    
    %...Inform user on no thrust
    if continuousThrust == false
        disp([newline,'No thrust was detected.'])
    end
end

%...Plot periods of thrust overlaid to Keplerian elements
if showfig == true && impulsiveThrust == true
    plotAll('thrust',{kepler,thrustPeriods})
end