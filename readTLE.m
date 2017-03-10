clear all; close all; clc;

%...Input file name
% file = 'noaa-06.txt';       % NOAA 06   (full) doesn't work
% file = 'noaa.txt';          % NOAA 06   (reduced) works
file = 'zarya.txt';         % ISS       (reduced) works

%...Read lines
fileID = fopen(file,'r');
read = fscanf(fileID,'%c'); % %s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n
fclose(fileID);

%...Reshape
read = split(string(read));
if mod(size(read,1),9) ~= 0, error('Something went wrong while reading the TLE file.'); end
read = reshape(read,9,[]);

%...Constants
mu = 398600.441e9;          % [m3/s2]   Earth gravitational parameter
Te = 23*3600+56*60+4.1004;  % [s]       Earth sidereal day

%...Decode lines
satID = read(3,1:2:end);                % [-]       satellite identifier
i = str2double(read(3,2:2:end));        % [deg]     inclination
O = str2double(read(4,2:2:end));        % [deg]     right ascension of ascending node
e = str2double(read(5,2:2:end))./1e7;   % [-]       eccentricity
o = str2double(read(6,2:2:end));        % [deg]     argument of perigee
M = str2double(read(7,2:2:end));        % [deg]     mean anomaly
n = str2double(read(8,2:2:end));        % [rad/s]   mean motion
T = Te./n;                              % [s]       period
a = ((T./(2*pi)).^2*mu).^(1/3);         % [m]       semi-major axis
b = a.*sqrt(1-e.^2);                    % [m]       semi-minor axis

%...Combine Keplerian elements
kepler = vertcat(a./1000,e,i,O,o,M);

%...Plot Keplerian elements
figure;
labels = {'a [km]','e [-]','i [deg]','\Omega [deg]','\omega [deg]','M [deg]'};
for i = 1:size(kepler,1)
    subplot(3,2,i)
    plot(kepler(i,:))
    xlabel('Time [?]')
    ylabel(labels{i})
    grid on
    set(gca,'FontSize',13)
end
