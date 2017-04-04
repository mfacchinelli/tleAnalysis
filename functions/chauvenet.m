%  MATLAB Function < chauvenet >
%
%  Purpose:     apply Chauvenet's criterion on data set
%  Input:
%   - data:
% Output:
%   - data:

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