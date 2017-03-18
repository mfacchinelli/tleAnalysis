%% Testing environment

clear all; close all; clc; format long g;

%...Constants
mu = 398600.441e9;          % [m3/s2]   Earth gravitational parameter
Re = 6378.136e3;            % [m]       Earth radius
Te = 23*3600+56*60+4.1004;  % [s]       Earth sidereal day

%...Read lines
file = 'files/delfic3.txt';

%% correctTLE

%...Read lines
fileID = fopen(file,'r');
data = fscanf(fileID,'%c');
fclose(fileID);

%...Check for first time
if ~strcmp(data(1),'#')
    %...Reshape and correct for element overlap
    data = split(string(data));
    if data(end,1) == '', data = data(1:end-1,1); end
    if mod(size(data,1),9) ~= 0 || size(char(data(end)),2) > 6
        warning('Fixing bugs in text file. This may take several seconds.');
        i = 1; % index to run through lines
        change = 0; % number of changes done
        limit = size(char(data(18:18:end,:)),1); % limiting number for check
        while i < limit
            try
                if size(char(data(i*18-1,:)),2) ~= 11
                    value17 = char(data(i*18-1,:));
                    data(i*18-1,:) = string(value17(1:11));
                    data = vertcat(data,zeros(1));
                    data(i*18+1:end,:) = data(i*18:end-1,:);
                    data(i*18,:) = string(value17(12:end));
                    change = change+1;
                    if mod(change,9) == 0, limit = limit+1; end
                end
            end
            i = i+1;
        end
    end
    if mod(size(data,1),9) ~= 0, error('Something went wrong while correcting the TLE file.'); end
    data = reshape(data,9,[]);

    %...Add comment
    data = horzcat(repmat('#',9,1),data);

    %...Write to file
    fileID = fopen(file,'w');
    fprintf(fileID,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n',data);
    fclose(fileID);
end

%% readTLE

%...Read lines
fileID = fopen(file,'r');
read = textscan(fileID,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','CommentStyle','#');
fclose(fileID);

%...Decode satellite identifier
satID = read{3};

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

ndd = char(read{6});
decimal = str2double(string(ndd(:,1:end-3)));
exponent = str2double(string(ndd(:,end-1:end)));
exponent(exponent>0) = -exponent(exponent>0); % force exponents to negative
ndd = 12*pi*decimal.*10.^exponent./(3600*24)^3;     % [rad/s^3] second derivative of mean motion

Bstar = char(read{7});
decimal = str2double(string(Bstar(:,1:5)));
exponent = str2double(string(Bstar(:,end-1:end)));
exponent(exponent>0) = -exponent(exponent>0); % force exponents to negative
Bstar = decimal.*10.^exponent*Re;                   % [1/m]     drag term

%...Compute semi-major axis
a = ((Te./(2*pi*n)).^2*mu).^(1/3);      % [m]       semi-major axis

%...Compute true anomaly
EA = MA.*ones(size(MA));
EA_0 = zeros(size(MA));
iter = 0;
while any(abs(EA-EA_0)>1e-6) && iter < 5e2 % iterative process
    iter = iter+1;
    EA_0 = EA;
    EA = EA_0 + (MA-EA_0+e.*sind(EA_0))./(1-e.*cosd(EA_0)); % eccentric anomaly
end
TA = wrapTo360(2.*atand(sqrt((1+e)./(1-e)).*tand(EA./2)));  % [deg] true anomaly

%...Remove duplicates
where = diff(t)~=0;
satID = satID(where); t = t(where); a = a(where); e = e(where); i = i(where); O = O(where);
o = o(where); TA = TA(where); nd = nd(where); ndd = ndd(where); Bstar = Bstar(where);

%...Combine Keplerian elements
extraction = horzcat(satID,t,a,e,i,O,o,TA);

%...Plot Keplerian elements
figure;
labels = {'a [m]','e [-]','i [deg]','\Omega [deg]','\omega [deg]','\vartheta [deg]'};
for i = 1:size(extraction,2)-1
    subplot(3,2,i)
    plot(extraction(:,1),extraction(:,i+1))
    xlabel('Time [day]')
    ylabel(labels{i})
    xlim([extraction(1,1),extraction(end,1)])
    grid on
    set(gca,'FontSize',13)
end
subplotTitle('Keplerian Elements')

%...Plot histogram of observation frequency
figure;
histogram(diff(t))
xlabel('\Delta t [day]')
ylabel('Occurrences [-]')
grid on
set(gca,'FontSize',13)

%% thrustTLE

%...Change in orbital elements
da = diff(extraction(:,2));
de = diff(extraction(:,3));
di = diff(extraction(:,4));
dO = diff(extraction(:,5));
do = diff(extraction(:,6));

%...Remove changes of 360 degrees from O and o
% dO(diff(dO)>350) = dO(diff(dO)>350)+360;
% dO(diff(dO)<-350) = dO(diff(dO)<-350)-360;

%...Save statistics to file (statTLE)
% Data structure
file = 'files/stat.txt';
fileID = fopen(file,'a+');
data = textscan(fileID,'','CommentStyle','#');

means = [mean(da);mean(de);mean(di);mean(dO);mean(do)];
stds = [std(da);std(de);std(di);std(dO);std(do)];
maxs = [max(da);max(de);max(di);max(dO);max(do)];
mins = [min(da);min(de);min(di);min(dO);min(do)];



fclose(fileID);

%...Detect thrust peaks
[peaks_a_1,locs_a_1] = findpeaks(da,'MinPeakHeight',std(da)); % positive change
[peaks_a_2,locs_a_2] = findpeaks(-da,'MinPeakHeight',std(da)); % negative change
[peaks_e_1,locs_e_1] = findpeaks(de,'MinPeakHeight',std(de)); % positive change
[peaks_e_2,locs_e_2] = findpeaks(-de,'MinPeakHeight',std(de)); % negative change
[peaks_i_1,locs_i_1] = findpeaks(di,'MinPeakHeight',std(di)); % positive change
[peaks_i_2,locs_i_2] = findpeaks(-di,'MinPeakHeight',std(di)); % negative change

%...Merge positive and negative values
peaks_a = sort(vertcat(peaks_a_1,peaks_a_2));
locs_a = sort(vertcat(locs_a_1,locs_a_2));
peaks_e = sort(vertcat(peaks_e_1,peaks_e_2));
locs_e = sort(vertcat(locs_e_1,locs_e_2));
peaks_i = sort(vertcat(peaks_i_1,peaks_i_2));
locs_i = sort(vertcat(locs_i_1,locs_i_2));

%...Check for repetitions
intersect(t(locs_a),t(locs_e))
intersect(t(locs_e),t(locs_i))
intersect(t(locs_a),t(locs_i))
