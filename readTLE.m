%  Purpose:     decode and plot Keplerian elements over time from given TLE
%               file; the function can handle string overlap
%  Input:
%   - file:     file name to be read, containing TLE information
%  Output:
%   - kepler:   array of time of TLE measurements and corresponding 
%               Keplerian elements (t,a,e,i,O,o,TA)

function kepler = readTLE(file)

%...Constants
mu = 398600.441e9;          % [m3/s2]   Earth gravitational parameter
Re = 6378.136e3;            % [m]       Earth radius
Te = 23*3600+56*60+4.1004;  % [s]       Earth sidereal day

%...Read lines
fileID = fopen(file,'r');
read = fscanf(fileID,'%c');
fclose(fileID);

%...Reshape and correct for element overlap
read = split(string(read));
if mod(size(read,1),9) ~= 0 || size(char(read(end)),2) > 6
    warning('Fixing bugs in text file. This may take several seconds.');
    i = 1; % index to run through lines
    change = 0; % number of changes done
    limit = size(char(read(18:18:end,:)),1); % limiting number for check
    while i < limit
        try
            if size(char(read(i*18-1,:)),2) ~= 11
                value17 = char(read(i*18-1,:));
                read(i*18-1,:) = string(value17(1:11));
                read = vertcat(read,zeros(1));
                read(i*18+1:end,:) = read(i*18:end-1,:);
                read(i*18,:) = string(value17(12:end));
                change = change+1;
                if mod(change,9) == 0, limit = limit+1; end
            end
        end
        i = i+1;
    end
end
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

%...Decode Keplerian elements
t = year.*365+day;                      % [day]     time since first measurement
i = str2double(read(3,2:2:end));        % [deg]     inclination
O = str2double(read(4,2:2:end));        % [deg]     right ascension of ascending node
e = str2double(read(5,2:2:end))./1e7;   % [-]       eccentricity
o = str2double(read(6,2:2:end));        % [deg]     argument of perigee
MA = str2double(read(7,2:2:end));       % [deg]     mean anomaly
n = str2double(read(8,2:2:end));        % [rad/s]   mean motion

%...Decode variables for propagation
nd = 4*pi*str2double(read(5,1:2:end))./(3600*24)^2; % [rad/s^2] first derivative of mean motion

ndd = char(read(6,1:2:end));
decimal = str2double(string(ndd(1,1:end-2,:)));
exponent = -str2double(string(ndd(1,end,:)));
ndd = 12*pi*decimal.*10.^exponent./(3600*24)^3;     % [rad/s^3] second derivative of mean motion

Bstar = char(read(7,1:2:end));
decimal = str2double(string(Bstar(1,1:5,:)));
exponent = str2double(string(Bstar(1,end-1:end,:)));
exponent(exponent>0) = -exponent(exponent>0);
Bstar = decimal.*10.^exponent*Re;                   % [1/m]     drag term

%...Compute semi-major axis
a = ((Te./(2*pi*n)).^2*mu).^(1/3);      % [m]       semi-major axis

%...Compute true anomaly
EA = MA.*ones(size(MA));
EA_0 = zeros(size(MA));
while any(abs(EA-EA_0)>1e-10) % iterative process
    EA_0 = EA;
    EA = EA_0 + (MA-EA_0+e.*sind(EA_0))./(1-e.*cosd(EA_0)); % eccentric anomaly
end
TA = wrapTo360(2.*atand(sqrt((1+e)./(1-e)).*tand(EA./2)));  % [deg] true anomaly

%...Combine Keplerian elements
kepler = vertcat(t,a,e,i,O,o,TA);

%...Plot Keplerian elements
figure;
labels = {'a [m]','e [-]','i [deg]','\Omega [deg]','\omega [deg]','\vartheta [deg]'};
for i = 1:size(kepler,1)-1
    subplot(3,2,i)
    plot(kepler(1,:),kepler(i+1,:))
    xlabel('Time [day]')
    ylabel(labels{i})
    xlim([kepler(1,1),kepler(1,end)])
    grid on
    set(gca,'FontSize',13)
end
subplotTitle('Keplerian Elements')
saveas(gca,['figures/',file(7:end-4)],'epsc')

%...Plot histogram of observation frequency
figure;
histogram(t(2:end)-t(1:end-1))
xlabel('\Delta t [day]')
ylabel('Occurrences [-]')
grid on
set(gca,'FontSize',13)