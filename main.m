clear; close all; clc; format long g;
addpath functions/ propagation/

%...Global constants
constants()

%% Input file

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
[stat,corr] = errorsTLE(data,options);

%% End

%...Inform user of completion
disp([newline,'Terminated'])