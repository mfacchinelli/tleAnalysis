clear all; close all; clc; format long g;

%% Input file 

%{  
    Choose file name from:
        'amateur'       Amateur Radio   (full)
        'debris'        COSMOS Debris   (full)
        'delfic3'       Delfi C3        (full)
        'envisat'       ENVISAT         (full)
        'goce'          GOCE            (full)
        'goes'          GOES-4          (full)
        'gps'           BIIR-2          (full)
        'grace'         GRACE-2         (full)
        'lageos'        LAGEOS-1        (full)
        'planet'        DOVE-2          (full)
        'noaa'          NOAA 06         (full)
        'zarya'         ISS             (full)
%}
options.file = 'grace';

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
disp('Terminated')