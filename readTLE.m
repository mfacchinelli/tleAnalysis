%  Purpose:     decode and plot Keplerian elements over time from given TLE
%               file; the function can handle string overlap (in progress)
%  Input:
%   - file:     file name to be read, containing TLE information
%  Output:
%   - kepler:   array of time of TLE measurements and corresponding 
%               Keplerian elements (t,a,e,i,O,o,TA)

function kepler = readTLE(file)

%...Constants
mu = 398600.441e9;          % [m3/s2]   Earth gravitational parameter
Te = 23*3600+56*60+4.1004;  % [s]       Earth sidereal day

%...Read lines
fileID = fopen(file,'r');
read = fscanf(fileID,'%c');
fclose(fileID);

%...Reshape
read = split(string(read));
if mod(size(read,1),9) ~= 0, error('Something went wrong while reading the TLE file.'); end
read = reshape(read,9,[]);

%...Decode time (disregards leap years)
time = char(read(4,1:2:end));
year = str2double(string(time(:,1:2,:)));
year(year>50) = 1900+year(year>50); % convert years to four digits
year(year<50) = 2000+year(year<50); % ... (will only work until 2049)
year = year - year(1); % convert year to years since first measurement
day = str2double(string(time(:,3:end,:)));
day = day - day(1); % convert day to days since first measurement

%...Decode rest of lines
% satID = read(3,1:2:end);                % [-]       satellite identifier
t = year.*365+day;                     % [day]     time since first measurement
i = str2double(read(3,2:2:end));        % [deg]     inclination
O = str2double(read(4,2:2:end));        % [deg]     right ascension of ascending node
e = str2double(read(5,2:2:end))./1e7;   % [-]       eccentricity
o = str2double(read(6,2:2:end));        % [deg]     argument of perigee
MA = str2double(read(7,2:2:end));       % [deg]     mean anomaly
n = str2double(read(8,2:2:end));        % [rad/s]   mean motion
T = Te./n;                              % [s]       period
a = ((T./(2*pi)).^2*mu).^(1/3);         % [m]       semi-major axis

%...Combine Keplerian elements
kepler = vertcat(t,a,e,i,O,o,MA);

%...Plot Keplerian elements
figure;
labels = {'a [m]','e [-]','i [deg]','\Omega [deg]','\omega [deg]','M [deg]'};
for i = 1:size(kepler,1)-1
    subplot(3,2,i)
    plot(kepler(1,:),kepler(i+1,:))
    xlabel('Time [day]')
    ylabel(labels{i})
    xlim([kepler(1,1),kepler(1,end)])
    grid on
    set(gca,'FontSize',13)
end
