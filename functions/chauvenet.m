%  MATLAB Function < chauvenet >
%
%  Purpose:     apply Chauvenet's criterion on data set
%  Input:
%   - data:
% Output:
%   - data:

function data = chauvenet(data,reference)

time = zeros(length(data(:,1)),1);

for i = 2:size(data(:,1),1)
    time(i) = (data(i,1)-data(i-1,1));
end

%...Standard deviation
stdTime = std(time);
stdRef = std(reference);

%...Expected value
expTime = mean(time);
expRef = mean(reference);

%...P test
prob = 1/(2*size(data(:,1),1));
pTest = 1-prob/2;

%...Z
zc = norminv(pTest,0,1);

% tsince_zscore = (time-expTime)/stdTime;
% dist_zscore = (reference(:,3)-expRef)/stdRef;

%...Maximum value allowed
maxTime = expTime+zc*stdTime;
maxRef = expRef+zc*stdRef;

%...Array of outlier position
outlier = false(size(data(:,1)));

%...Loop over data
for i = 1:size(data(:,1),1)
    if ((time(i) > maxTime) || (reference(i) > maxRef))
        outlier(i) = true;
    end
end

data(outlier,:) = [];