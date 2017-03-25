clear; close all; clc; format long g;
addpath functions/ propagation/

%...Global constants
constants()

%% Input file 

%{  
    Choose NORAD ID and file name from:
        Amateur Radio   '14129'     'amateur'
        CryoSat-2       '36508'     'cryosat'       
        COSMOS Debris   '34393'     'debris'        
        Delfi C3        '32789'     'delfic3'       
        ENVISAT         '27386'     'envisat'       
        GOCE            '34602'     'goce'          
        GOES-4          '11964'     'goes'          
        BIIR-2          '24876'     'gps'           
        GRACE-2         '27392'     'grace'         
        Iridium 73      '25346'     'iridium'       
        LAGEOS-1        '08820'     'lageos'        
        METEOR 2-06     '11962'     'meteor'        
        NOAA 06         '11416'     'noaa'          
        DOVE-2          '39132'     'planet'        
        ISS             '25544'     'zarya'      
    Or insert a custom one.
%}

norID = ''; % NORAD ID
file = '23789'; % file name

%% Settings

%{
    Select thrust setting:
        false:  for sure satellite has no thrust
        true:   no available information/do not know
%}

options = struct('norID',   norID,...                   % NORAD ID
                 'file',    ['files/',file,'.txt'],...  % convert file name
                 'thrust',  1,...                       % (see above)
                 'showfig', 1,...                       % show figures
                 'ignore',  0.01,...                    % ignore first XX percent of data
                 'factor',  1.5,...                     % safety factor for thrust detection
                 'limit',   50,...                      % limit for days of separations between maneuvers
                 'offset',  50);

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