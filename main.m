clear all; close all; clc; format long g;

%% Input file 

%{  
    Choose file name from:
        'amateur'       Amateur Radio
        'debris'        COSMOS Debris
        'delfic3'       Delfi C3
        'envisat'       ENVISAT
        'goce'          GOCE
        'goes'          GOES-4
        'gps'           BIIR-2
        'grace'         GRACE-2
        'lageos'        LAGEOS-1
        'planet'        DOVE-2
        'noaa'          NOAA 06
        'zarya'         ISS
%}
options.file = 'zarya';

%% Settings

%{
    Select thrust setting:
        'no':   for sure satellite has no thrust
        'na':   no available information/do not know (can be any string
                except for 'no')
%}
options.thrust = 'na';

%...Make sure selection is intentional
if strcmp(options.thrust,'no')
    warning('You selected no thrust!')
    input(['Press enter to confirm that this spacecraft has no thrust.',newline])
end

%...Show figures
options.showfig = 'no';

%...Ignore first XXX percent of data
options.ignore = 0.05;

%...Safety factor for thrust detection
options.factor = 1.5;

%...Limit for days of separations between maneuvers
options.limit = 50;

%% Decode TLE

options.file = ['files/',options.file,'.txt'];
data = readTLE(options);
kepler = data.orbit;

%% Thrust detection

options.ID = data.ID;
thrustTLE(kepler,options)

%% End

%...Inform user of completion
disp([newline,'Terminated'])