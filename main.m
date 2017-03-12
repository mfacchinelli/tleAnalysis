clear all; close all; clc; format long g;

%% Input file 

%{  
    Choose file name from:
        'debris'        COSMOS Debris   (full)      works
        'delfic3'       Delfi C3        (full)      works
        'gps'           BIIR-2          (full)      works
        'grace'         GRACE-2         (full)      works
        'noaa'          NOAA 06         (reduced)   works
        'zarya'         ISS             (full)      works
%}
file = 'zarya';

%% Decode TLE

keplerElements = readTLE(['files/',file,'.txt']);

t = keplerElements(1,:)';   % [day]     time since first measurement
a = keplerElements(2,:)';   % [m]       semi-major axis
e = keplerElements(3,:)';   % [-]       eccentricity
i = keplerElements(4,:)';   % [deg]     inclination
O = keplerElements(5,:)';   % [deg]     right ascension of ascending node
o = keplerElements(6,:)';   % [deg]     argument of perigee
TA = keplerElements(7,:)';  % [deg]     true anomaly

%% Thrust detection

