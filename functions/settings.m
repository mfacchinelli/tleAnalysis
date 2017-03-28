%  MATLAB Function < settings >
% 
%  Purpose:	define settings globally
%  Input:
%   - N/A
%  Output:
%   - N/A

function options = settings()

%	Select thrust setting:
%   	false (0):  for sure satellite has no thrust
%    	true  (1):  no available information/do not know

filename = input('Please enter a valid NORAD identifier: ','s'); % ask for NORAD ID

options = struct('file',    ['files/',filename,'.txt'],... % adapt name
                 'thrust',  true,... % (see above)
                 'showfig', true,... % show figures
                 'ignore',  0.05,... % ignore first XX percent of data
                 'factor',  1.05,... % safety factor for thrust detection
                 'limit',   50,... % limit for days of separations between maneuvers
                 'offset',  7,... % number of steps to take between observations
                 'outlier', true); % apply Chauvenet's criterion

%...Make sure selection is intentional
if options.thrust == false
    warning('You selected no thrust!')
    input([newline,'Press enter to confirm that this spacecraft has no thrust.'])
end

%...Force outlier detection if satellite has no thrust
if options.thrust == false
    options.outlier = true;
end

%...Load data on satellites
load('files/satData.mat');

%...Check if satellite is in file
try 
    satellites(filename);
catch
    %...Ask for data
    mass = input('Insert satellite mass (kg): ');
    units = input('Insert satellite number of units (U): ');
    panels = input('Insert solar panel logical (T/F): ');
    satellites(filename) = [mass,units,panels];
    
    %...Save with new data
    save('files/satData.mat','satellites');
end