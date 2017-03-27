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

function thrustPeriods = thrustTLE(extract,options)

%...Extract data
keplerTLE = extract.orbit;

%...Extract options
showfig = options.showfig;
ignore = options.ignore;
factor = options.factor;
limit = options.limit;
k = options.offset;

%...Propagate orbit
keplerProp = propagateTLE(extract,options);

%...Ignore intial part of TLE (avoid injection maneuver)
lower = ceil(ignore*size(keplerTLE,1));
lower(lower==0) = 1;

%...Find residuals in propagation and correct for constant offset
daProp = keplerTLE(lower+k:k:end,2)-keplerProp(:,2);
a_offset = median(daProp); daProp = daProp-a_offset;
keplerProp(:,2) = keplerProp(:,2)+a_offset;

deProp = keplerTLE(lower+k:k:end,3)-keplerProp(:,3);
e_offset = median(deProp); deProp = deProp-e_offset;
keplerProp(:,3) = keplerProp(:,3)+e_offset;

diProp = keplerTLE(lower+k:k:end,4)-keplerProp(:,4);
i_offset = median(diProp); diProp = diProp-i_offset;
keplerProp(:,4) = keplerProp(:,4)+i_offset;

dOProp = keplerTLE(lower+k:k:end,5)-keplerProp(:,5);
O_offset = median(dOProp); dOProp = dOProp-O_offset;
keplerProp(:,5) = keplerProp(:,5)+O_offset;

%...Change in orbital elements
lower = ceil(ignore*size(keplerTLE,1));
lower(lower==0) = 1;
daTLE = diff(keplerTLE(lower:end,2));
deTLE = diff(keplerTLE(lower:end,3));
diTLE = diff(keplerTLE(lower:end,4));
dOTLE = diff(keplerTLE(lower:end,5));
doTLE = diff(keplerTLE(lower:end,6));

%...Remove changes of 2pi degrees from O and o
dOProp(dOProp>pi) = dOProp(dOProp>pi)-2*pi;
dOProp(dOProp<-pi) = dOProp(dOProp<-pi)+2*pi;
dOTLE(dOTLE>pi) = dOTLE(dOTLE>pi)-2*pi;
dOTLE(dOTLE<-pi) = dOTLE(dOTLE<-pi)+2*pi;

%...Show plots
if showfig == true
    plotAll('residuals',{keplerTLE,keplerProp,[daProp,deProp,diProp,dOProp]},options);
end

%...Get statistics
dataProp = statTLE('Prop',[daProp,deProp,diProp,dOProp],options);
dataTLE = statTLE('TLE',[daTLE,deTLE,diTLE,dOTLE,doTLE],options);

%...Detect thrust peaks
warning('off')
[~,locs_a_1] = findpeaks(daProp,'MinPeakHeight',factor*dataProp.a(1)); % positive change
[~,locs_a_2] = findpeaks(-daProp,'MinPeakHeight',factor*dataProp.a(2)); % negative change
[~,locs_e_1] = findpeaks(deProp,'MinPeakHeight',factor*dataProp.e(1)); % positive change
[~,locs_e_2] = findpeaks(-deProp,'MinPeakHeight',factor*dataProp.e(2)); % negative change
[~,locs_i_1] = findpeaks(diProp,'MinPeakHeight',factor*dataProp.i(1)); % positive change
[~,locs_i_2] = findpeaks(-diProp,'MinPeakHeight',factor*dataProp.i(2)); % negative change
[~,locs_O_1] = findpeaks(dOProp,'MinPeakHeight',factor*dataProp.O(1)); % positive change
[~,locs_O_2] = findpeaks(-dOProp,'MinPeakHeight',factor*dataProp.O(2)); % negative change
warning('on')

%...Merge positive and negative values
locs_a = lower+sort(vertcat(locs_a_1,locs_a_2))*k;
locs_e = lower+sort(vertcat(locs_e_1,locs_e_2))*k;
locs_i = lower+sort(vertcat(locs_i_1,locs_i_2))*k;
locs_O = lower+sort(vertcat(locs_O_1,locs_O_2))*k;
locsProp = {locs_a,locs_e,locs_i,locs_O};
 
%...Detect thrust peaks
warning('off')
[~,locs_a_1] = findpeaks(daTLE,'MinPeakHeight',factor*dataTLE.a(1)); % positive change
[~,locs_a_2] = findpeaks(-daTLE,'MinPeakHeight',factor*dataTLE.a(2)); % negative change
[~,locs_e_1] = findpeaks(deTLE,'MinPeakHeight',factor*dataTLE.e(1)); % positive change
[~,locs_e_2] = findpeaks(-deTLE,'MinPeakHeight',factor*dataTLE.e(2)); % negative change
[~,locs_i_1] = findpeaks(diTLE,'MinPeakHeight',factor*dataTLE.i(1)); % positive change
[~,locs_i_2] = findpeaks(-diTLE,'MinPeakHeight',factor*dataTLE.i(2)); % negative change
[~,locs_O_1] = findpeaks(dOTLE,'MinPeakHeight',factor*dataTLE.O(1)); % positive change
[~,locs_O_2] = findpeaks(-dOTLE,'MinPeakHeight',factor*dataTLE.O(2)); % negative change
warning('on')

%...Merge positive and negative values
locs_a = lower+sort(vertcat(locs_a_1,locs_a_2));
locs_e = lower+sort(vertcat(locs_e_1,locs_e_2));
locs_i = lower+sort(vertcat(locs_i_1,locs_i_2));
locs_O = lower+sort(vertcat(locs_O_1,locs_O_2));
locsTLE = {locs_a,locs_e,locs_i,locs_O};

%...Check for repetitions
thrustDaysProp = [];
for i = 1:3
    for j = 1+i:4
        if i ~= j
            thrustDaysProp = vertcat(thrustDaysProp,intersect(keplerTLE(locsProp{i},1),keplerTLE(locsProp{j},1)));
        end
    end
end
thrustDaysProp = unique(thrustDaysProp);

%...Check for repetitions
thrustDaysTLE = [];
for i = 1:3
    for j = 1+i:4
        if i ~= j
            thrustDaysTLE = vertcat(thrustDaysTLE,intersect(keplerTLE(locsTLE{i},1),keplerTLE(locsTLE{j},1)));
        end
    end
end
thrustDaysTLE = unique(thrustDaysTLE);

%...Find thrust periods from propagation
% thrustPeriodsProp = [];
% if ~isempty(thrustDaysProp)
%     thrustFoundProp = 1;
%     separation = diff(thrustDaysProp);
%     where = [0;find(separation>limit);size(separation,1)+1]+1;
%     disp([newline,'Periods where thrust was detected:'])
%     for i = 1:size(where,1)-1
%         thrustPeriodsProp(i,:) = [floor(thrustDaysProp(where(i))),ceil(thrustDaysProp(where(i+1)-1))];
%         disp([num2str(i),char(9),num2str(floor(thrustDaysProp(where(i)))),' - ',num2str(ceil(thrustDaysProp(where(i+1)-1)))])
%     end
% else
%     thrustFoundProp = 0;
% end

%...Find thrust periods from change in orbital elements
thrustPeriodsTLE = [];
if ~isempty(thrustDaysTLE)
    thrustFoundTLE = 1;
    separation = diff(thrustDaysTLE);
    where = [0;find(separation>limit);size(separation,1)+1]+1;
    disp([newline,'Periods where thrust was detected:'])
    for i = 1:size(where,1)-1
        thrustPeriodsTLE(i,:) = [floor(thrustDaysTLE(where(i))),ceil(thrustDaysTLE(where(i+1)-1))];
        disp([num2str(i),char(9),num2str(floor(thrustDaysTLE(where(i)))),' - ',num2str(ceil(thrustDaysTLE(where(i+1)-1)))])
    end
else
    thrustFoundTLE = 0;
end

%...Find continuous thrust and/or satellite decay
if thrustFoundTLE == false %&& thrustFoundProp == false
    %...Detection variable
    continuousThrustDetectionValue = median(daTLE)/median(abs(daTLE));
    
    %...Check if within constraints
    if continuousThrustDetectionValue < -0.95 || abs(continuousThrustDetectionValue) < 0.05
        continuousThrust = false;
        disp([newline,'No coninuous thrust detected.'])
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
% if showfig == true && thrustFoundProp == true
%     plotAll('thrust',{keplerTLE,thrustPeriodsProp})
% end
if showfig == true && thrustFoundTLE == true
    plotAll('thrust',{keplerTLE,thrustPeriodsTLE})
end