%  MATLAB Function < settings >
% 
%  Purpose:	define settings globally using a GUI
%  Input:
%   - N/A
%  Output:
%   - N/A

function options = settings()

%...Display message
disp('Welcome! Please fill in the data in the pop-up window.')

%	Select thrust setting:
%   	false (0):  for sure satellite has no thrust
%    	true  (1):  no available information/do not know

%...Ask for inputs
answer = inputdlg({'NORAD identifier:',...
                   'Usage of thrust (T/F):',...
                   'Show figures (T/F):',...
                   'Initial data to ignore (%):',...
                   'Safety factor for detection (-):',...
                   'Separation between thrust periods (day):',...
                   'Number of steps for propagation (-):',...
                   "Apply Chauvenet's criterion (T/F):"},...
                  'TLE Analysis',...
                  1,...
                  {'32789','true','true','5','1.05','50','1','true'},'on');

%...Save inputs in options structure array
options = struct('file',    ['files/',answer{1},'.txt'],... % adapt name
                 'thrust',  strcmpi(answer{2},'true'),...   % (see above)
                 'showfig', strcmpi(answer{3},'true'),...   % show figures
                 'ignore',  str2double(answer{4})/100,...	% ignore first XX percent of data
                 'factor',  str2double(answer{5}),...       % safety factor for thrust detection
                 'limit',   str2double(answer{6}),...       % limit for days of separations between maneuvers
                 'offset',  str2double(answer{7}),...       % number of steps to take between observations
                 'outlier', strcmpi(answer{8},'true'));     % apply Chauvenet's criterion

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
    satellites(answer{1});
catch
    %...Ask for data
    mass = input([newline,'Insert satellite mass (kg): ']);
    units = input('Insert satellite number of units (U): ');
    panels = input('Insert solar panel logical (T/F): ');
    satellites(answer{1}) = [mass,units,panels];
    
    %...Save with new data
    save('files/satData.mat','satellites');
end