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

file = 'lageos';
thrust = 'na'; 
% no:   for sure satellite has no thrust
% na:   no available information/do not know

%% Decode TLE

options = struct('showfig','yes');
data = readTLE(['files/',file,'.txt'],options);
kepler = data.orbit;

t = kepler(:,1);    % [day]     time since first measurement
a = kepler(:,2);    % [m]       semi-major axis
e = kepler(:,3);    % [-]       eccentricity
i = kepler(:,4);    % [deg]     inclination
O = kepler(:,5);    % [deg]     right ascension of ascending node
o = kepler(:,6);    % [deg]     argument of perigee
TA = kepler(:,7);   % [deg]     true anomaly

%% Thrust detection

options = struct('ID',data.ID,'thrust',thrust);

thrustDetection(kepler,options)

%% End

%...Inform user of completion
disp('Terminated')