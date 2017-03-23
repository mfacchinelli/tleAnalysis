clear; close all; clc; format long g;
addpath functions/ propagation/

%...Global constants
global mu Re Te
mu = 398600.441e9;          % [m3/s2]   Earth gravitational parameter
Re = 6378.136e3;            % [m]       Earth radius
Te = 23*3600+56*60+4.1004;  % [s]       Earth sidereal day

%% Input file 

%{  
    Choose NORAD ID and file name from:
        '14129'         'amateur'       Amateur Radio
        '36508'         'cryosat'       CryoSat-2
        '34393'         'debris'        COSMOS Debris
        '32789'         'delfic3'       Delfi C3
        '27386'         'envisat'       ENVISAT
        '34602'         'goce'          GOCE
        '11964'         'goes'          GOES-4
        '24876'         'gps'           BIIR-2
        '27392'         'grace'         GRACE-2
        '25346'         'iridium'       Iridium 73
        '08820'         'lageos'        LAGEOS-1
        '11962'         'meteor'        METEOR 2-06
        '11416'         'noaa'          NOAA 06
        '39132'         'planet'        DOVE-2
        '25544'         'zarya'         ISS
%}

options.norID = ''; % NORAD ID
options.file = '23789'; % file name

%...Download TLE if not available yet (source: space-track.org)
downloadTLE(options)

%% Settings

%{
    Select thrust setting:
        false:  for sure satellite has no thrust
        true:   no available information/do not know
%}
options.thrust = true;

%...Show figures
options.showfig = false;

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

%...Convert file name
options.file = ['files/',options.file,'.txt'];

%% Decode TLE

data = readTLE(options);
keplerTLE = data.orbit;

%% Thrust detection

keplerProp = propagateTLE(data);
options.ID = data.ID;
% thrustPeriods = thrustTLE(kepler,options);

%% End

%...Inform user of completion
disp([newline,'Terminated'])