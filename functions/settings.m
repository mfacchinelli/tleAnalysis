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

options = struct('file',    ['files/',input('Please enter a valid NORAD identifier: ','s'),'.txt'],... % ask for NORAD ID
                 'thrust',  0,... % (see above)
                 'showfig', 1,... % show figures
                 'ignore',  0.05,... % ignore first XX percent of data
                 'factor',  1.05,... % safety factor for thrust detection
                 'limit',   50,... % limit for days of separations between maneuvers
                 'offset',  7); % number of steps to take between observations

%...Make sure selection is intentional
if options.thrust == false
    warning('You selected no thrust!')
    input([newline,'Press enter to confirm that this spacecraft has no thrust.'])
end