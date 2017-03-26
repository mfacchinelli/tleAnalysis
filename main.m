clear; close all; clc; format long g;
addpath functions/ propagation/

%...Global constants
constants()

%% Input file 

%{  
    Choose NORAD ID and file name from:
        Amateur Radio   '14129'
        CryoSat-2       '36508'
        COSMOS Debris   '34393'
        Delfi C3        '32789'
        ENVISAT         '27386'
        GOCE            '34602'
        GOES-4          '11964'
        BIIR-2          '24876'
        GRACE-2         '27392'
        Iridium 73      '25346'
        LAGEOS-1        '08820'
        METEOR 2-06     '11962'
        NOAA 06         '11416'
        DOVE-2          '39132'
        ISS             '25544'
    Or insert a custom one.
%}

file = input('Please enter a valid NORAD identifier: ','s'); % ask for NORAD ID

%% Settings

%{
    Select thrust setting:
        false:  for sure satellite has no thrust
        true:   no available information/do not know
%}

options = struct('file',    ['files/',file,'.txt'],...  % convert file name
                 'thrust',  1,...                       % (see above)
                 'showfig', 1,...                       % show figures
                 'ignore',  0.01,...                    % ignore first XX percent of data
                 'factor',  1.5,...                     % safety factor for thrust detection
                 'limit',   50,...                      % limit for days of separations between maneuvers
                 'offset',  10);

%...Make sure selection is intentional
if options.thrust == false
    warning('You selected no thrust!')
    input(['Press enter to confirm that this spacecraft has no thrust.',newline])
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