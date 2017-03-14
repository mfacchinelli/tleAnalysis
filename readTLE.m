%  Purpose:     decode and plot Keplerian elements over time from given TLE
%               file; use correctTLE function to correct element overlap
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

%...Correct file if first time
correctTLE(file)

%...Read lines
fileID = fopen(file,'r');
read = textscan(fileID,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','CommentStyle','#');
fclose(fileID);

%...Decode time
time = char(read{4});
year = str2double(string(time(:,1:2,:)));
year(year>50) = 1900+year(year>50); % convert years to four digits
year(year<50) = 2000+year(year<50); % ... (will only work until 2049)
leap = year.*(mod(year-1,4)==0); % find leap years
leap = diff(leap-1)>1; % find discontinuity in leap years
yearInit = year(1); yearEnd = year(end);
year = year - yearInit; % convert year to years since first measurement
day = str2double(string(time(:,3:end,:)));
dayInit = day(1); dayEnd = day(end);
day = day - dayInit; % convert day to days since first measurement

%...Adjust for leap years
t = year.*365+day;                      % [day]     time since first measurement
for i = find(leap==1)'
    t(i+1:end) = t(i+1:end)+1;
end

%...Show time interval
disp(['First observation on day ',num2str(dayInit),', year ',num2str(yearInit),'.'])
disp(['Last observation on day ',num2str(dayEnd),', year ',num2str(yearEnd),'.'])

%...Decode Keplerian elements
i = str2double(read{12});       % [deg]     inclination
O = str2double(read{13});       % [deg]     right ascension of ascending node
e = str2double(read{14})./1e7;  % [-]       eccentricity
o = str2double(read{15});       % [deg]     argument of perigee
MA = str2double(read{16});      % [deg]     mean anomaly
n = str2double(read{17});       % [rad/s]   mean motion

%...Decode variables for propagation
nd = 4*pi*str2double(read{5})./(3600*24)^2; % [rad/s^2] first derivative of mean motion

% ndd = char(read{6});
% decimal = str2double(string(ndd(1,1:end-2,:)));
% exponent = -str2double(string(ndd(1,end,:)));
% ndd = 12*pi*decimal.*10.^exponent./(3600*24)^3;     % [rad/s^3] second derivative of mean motion
% 
% Bstar = char(read{7});
% decimal = str2double(string(Bstar(1,1:5,:)));
% exponent = str2double(string(Bstar(1,end-1:end,:)));
% exponent(exponent>0) = -exponent(exponent>0);
% Bstar = decimal.*10.^exponent*Re;                   % [1/m]     drag term

%...Compute semi-major axis
a = ((Te./(2*pi*n)).^2*mu).^(1/3);      % [m]       semi-major axis

%...Compute true anomaly
EA = MA.*ones(size(MA));
EA_0 = zeros(size(MA));
iter = 0;
while any(abs(EA-EA_0)>1e-10) && iter < 5e3 % iterative process (with safety break)
    iter = iter+1;
    EA_0 = EA;
    EA = EA_0 + (MA-EA_0+e.*sind(EA_0))./(1-e.*cosd(EA_0)); % eccentric anomaly
end
TA = wrapTo360(2.*atand(sqrt((1+e)./(1-e)).*tand(EA./2)));  % [deg] true anomaly

%...Remove duplicates
where = diff(t)~=0; % remove duplicates in time
t = t(where); a = a(where); e = e(where); i = i(where); O = O(where); o = o(where);
TA = TA(where); nd = nd(where); %ndd = ndd(where); %Bstar = Bstar(where);

%...Combine Keplerian elements
kepler = horzcat(t,a,e,i,O,o,TA);

%...Plot Keplerian elements
figure;
labels = {'a [m]','e [-]','i [deg]','\Omega [deg]','\omega [deg]','\vartheta [deg]'};
for i = 1:size(kepler,2)-1
    subplot(3,2,i)
    plot(kepler(:,1),kepler(:,i+1))
    xlabel('Time [day]')
    ylabel(labels{i})
    xlim([kepler(1,1),kepler(end,1)])
    grid on
    set(gca,'FontSize',13)
end
subplotTitle('Keplerian Elements')
saveas(gca,['figures/',file(7:end-4)],'epsc')

%...Plot histogram of observation frequency
figure;
histogram(diff(t))
xlabel('\Delta t [day]')
ylabel('Occurrences [-]')
grid on
set(gca,'FontSize',13)