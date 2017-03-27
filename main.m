clear; close all; clc; format long g;
addpath functions/ propagation/

%...Global constants
constants()

%% Input file 

%{  
    Choose NORAD ID from:
        Amateur Radio   '14129'     no thrust
        CryoSat-2       '36508'
        COSMOS Debris   '34393'     no thrust
        Delfi C3        '32789'     no thrust
        ENVISAT         '27386'
        GOCE            '34602'
        GOES-4          '11964'
        BIIR-2          '24876'
        GRACE-2         '27392'
        Iridium 73      '25346'
        LAGEOS-1        '08820'     no thrust
        METEOR 2-06     '11962'
        NOAA 06         '11416'
        DOVE-2          '39132'     no thrust
        ISS             '25544'
    Or insert a custom one.
%}

file = input('Please enter a valid NORAD identifier: ','s'); % ask for NORAD ID

%% Settings

%{
    Select thrust setting:
        false (0):  for sure satellite has no thrust
        true (1):   no available information/do not know
%}

options = struct('file',    ['files/',file,'.txt'],...  % convert file name
                 'thrust',  1,...                       % (see above)
                 'showfig', 1,...                       % show figures
                 'ignore',  0.05,...                    % ignore first XX percent of data
                 'factor',  1.5,...                     % safety factor for thrust detection
                 'limit',   50,...                      % limit for days of separations between maneuvers
                 'offset',  5);                         % number of steps to take between observations

%...Make sure selection is intentional
if options.thrust == false
    warning('You selected no thrust!')
    input([newline,'Press enter to confirm that this spacecraft has no thrust.'])
end

%...Clean up
clear norID file

%% Decode TLE

%...Extract TLE data
data = readTLE(options);
options.ID = data.ID;

%% Thrust detection

%...Detect periods of thrust usage
thrustPeriods = thrustTLE(data,options);

%% End

%...Inform user of completion
disp([newline,'Terminated'])