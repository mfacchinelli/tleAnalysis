clear all; close all; clc; format long g;
addpath functions/ propagation/

%...Globla constants
global mu Re Te
mu = 398600.441e9;          % [m3/s2]   Earth gravitational parameter
Re = 6378.136e3;            % [m]       Earth radius
Te = 23*3600+56*60+4.1004;  % [s]       Earth sidereal day

%% Input file 

%{  
    Choose file name from:
        'amateur'       Amateur Radio
        'cryosat'       CryoSat-2
        'debris'        COSMOS Debris
        'delfic3'       Delfi C3
        'envisat'       ENVISAT
        'goce'          GOCE
        'goes'          GOES-4
        'gps'           BIIR-2
        'grace'         GRACE-2
        'iridium'       Iridium 73
        'lageos'        LAGEOS-1
        'planet'        DOVE-2
        'noaa'          NOAA 06
        'zarya'         ISS
%}
options.file = 'envisat';

%% Settings

%{
    Select thrust setting:
        false:  for sure satellite has no thrust
        true:   no available information/do not know
%}
options.thrust = true;

%...Show figures
options.showfig = true;

%...Ignore first XX percent of data
options.ignore = 0.01;

%...Safety factor for thrust detection
options.factor = 1.5;

%...Limit for days of separations between maneuvers
options.limit = 50;

%...Make sure selection is intentional
if options.thrust == false
    warning('You selected no thrust!')
    input(['Press enter to confirm that this spacecraft has no thrust.',newline])
end

%% Decode TLE

options.file = ['files/',options.file,'.txt'];
data = readTLE(options);
kepler = data.orbit;

%% Thrust detection

options.ID = data.ID;
thrustPeriods = thrustTLE(kepler,options);

%% End

%...Inform user of completion
disp([newline,'Terminated'])