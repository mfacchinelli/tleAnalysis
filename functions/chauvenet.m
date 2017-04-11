%  MATLAB Function < chauvenet >
%
%  Purpose:         apply Chauvenet's criterion on data set, to remove
%                   outliers; originally created by Paul Schattenberg and 
%                   adapted by the tleAnalysis team
%  Input:
%   - data:         data to which the Chauvenet's criterion needs to be
%                   applied
%   - reference:    reference for application of Chauvenet's criterion
% Output:
%   - data:         data where outliers have been removed

function data = chauvenet(data,reference)

%...Find time step
time = vertcat(0,diff(data(:,1)));

%...Standard deviation
stdTime = std(time);
stdRef = std(reference);

%...Expected value
expTime = mean(time);
expRef = mean(reference);

%...P test
prob = 1/(2*size(data(:,1),1));
pTest = 1-prob/2;

%...Z factor
zc = norminv(pTest,0,1);

%...Maximum value allowed
maxTime = expTime+zc*stdTime;
maxRef = expRef+zc*stdRef;

%...Array of outlier position
outlier = false(size(data(:,1)));

%...Loop over data to find where outliers are
for i = 1:size(data(:,1),1)
    if ((time(i) > maxTime) || (abs(reference(i)) > maxRef))
        outlier(i) = true;
    end
end

%...Remove outliers
data(outlier,:) = [];

%...Message user if too many data points were removed
initial = size(outlier,1); % initial number of elements
removed = size(find(outlier==true),1); % number of points removed
if removed/initial >= 0.05
    waitfor(warndlg({'More than 5% of data has been removed.';...
                     'There might be errors in the TLE observations.'},...
                    'Outlier Warning'))
end