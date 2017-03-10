clear all; close all; clc;

%% Input file 

file = 'noaa-06.txt';       % NOAA 06   (full) doesn't work
file = 'noaa.txt';          % NOAA 06   (reduced) works
file = 'zarya.txt';         % ISS       (reduced) works

%% Decode TLE

keplerElements = readTLE(file);

t = keplerElements(1,:)';   % [day]     time since first measurement
a = keplerElements(2,:)';   % [m]       semi-major axis
e = keplerElements(3,:)';   % [-]       eccentricity
i = keplerElements(4,:)';   % [deg]     inclination
O = keplerElements(5,:)';   % [deg]     right ascension of ascending node
o = keplerElements(6,:)';   % [deg]     argument of perigee
MA = keplerElements(7,:)';  % [deg]     mean anomaly

%% Thrust detection

