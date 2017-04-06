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
        GRACE-2         '27392'     no thrust
        Iridium 73      '25346'
        LAGEOS-1        '08820'
        METEOR 2-06     '11962'
        NOAA 06         '11416'
        DOVE-2          '39132'     no thrust
        ISS             '25544'
    Or insert a custom one.
%}

%...Load settings
options = settings();

%% Decode TLE

%...Extract TLE data
[data,options] = readTLE(options);

%% Thrust detection

%...Detect periods of thrust usage
thrustTLE(data,options);

%% Find residuals

%...Compute residuals between Keplerian elements and propagation
residualsTLE(data,options);

%% End

%...Inform user of completion
disp([newline,'Terminated'])