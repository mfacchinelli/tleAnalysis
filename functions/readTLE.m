%  MATLAB Function < readTLE >
% 
%  Purpose:     decode and plot Keplerian elements over time from given TLE
%               file; use correctTLE function to correct element overlap
%  Input:
%   - option:  structure array containing:
%                   1) file:    file name to be read, to extract TLE information
%                   2) showfig:	command whether to show plots
%                   3) outlier: command whether to apply Chauvenet's criterion
%  Output:
%   - extract:  structure array containing: 
%                   1) ID:          satellite identifier
%                   2) orbit:       time of TLE measurements and corresponding 
%                                   Keplerian elements (t,a,e,i,O,o,TA,MA)
%                   3) propagator:  data for propagation for each
%                                   observation time (n,nd,ndd,Bstar)

function [extract,options] = readTLE(options)

%...Global constants
global mu Re J2 Ts Tm

%...Preallocate arrays
satIDAll = cell(size(options));
keplerAll = cell(size(options));
propagationAll = cell(size(options));

%...Loop over files
for filenum = 1:size(options,2)
    %...Select options
    option = options(:,filenum);
    
    %...Extract option
    file = option.file;
    showfig = option.showfig;
    outlier = option.outlier;
    
    %...Download TLE if not available yet (source: space-track.org)
    downloadTLE(file)

    %...Correct file if first time
    correctTLE(file)

    %...Read lines
    fileID = fopen(file,'r');
    read = textscan(fileID,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','CommentStyle','#');
    fclose(fileID);

    %...Decode satellite identifier
    satID = string(read{3}{1});

    %...Decode time
    time = char(read{4});
    day = str2double(string(time(:,3:end,:)));
    year = str2double(string(time(:,1:2,:)));
    year(year>50) = 1900+year(year>50); % convert years to four digits
    year(year<50) = 2000+year(year<50); % ... (will only work until 2049)

    %...Sort data
    year_day = year+day/1e3;
    [~,index] = sort(year_day,1);
    year = year(index); % sort years
    day = day(index); % sort days

    %...Correct for leap years
    leap = year.*(mod(year-1,4)==0); % find leap years
    leap = diff(leap-1)>1; % find discontinuity in leap years

    %...Initial and final days
    yearInit = year(1); yearEnd = year(end);
    dayInit = day(1); dayEnd = day(end);

    %...Date since first day
    year = year - yearInit; % convert year to years since first measurement
    day = day - dayInit; % convert day to days since first measurement

    %...Adjust for leap years
    t = year.*365+day;                      % [day]     time since first measurement
    for i = find(leap==1)'
        t(i+1:end) = t(i+1:end)+1;
    end

    %...Show time interval
    file = regexprep(file,'[files/.txt]','');
    disp([newline,'Satellite: ',file])
    disp(['First observation on day ',num2str(dayInit),', year ',num2str(yearInit),'.'])
    disp(['Last observation on day ',num2str(dayEnd),', year ',num2str(yearEnd),'.'])

    %...Decode Keplerian elements
    i = deg2rad(str2double(read{12}));  % [rad]     inclination
    O = deg2rad(str2double(read{13}));  % [rad]     right ascension of ascending node
    e = str2double(read{14})./1e7;      % [-]       eccentricity
    o = deg2rad(str2double(read{15}));  % [rad]     argument of perigee
    MA = deg2rad(str2double(read{16})); % [rad]     mean anomaly
    n = 2*pi*str2double(read{17})./Ts; % mean motion without correction

    %...Decode variables for propagation
    nd = 2*pi*str2double(read{5})./Tm^2;	% [rad/min^2]	first derivative of mean motion

    ndd = char(read{6});
    decimal = str2double(string(ndd(:,1:end-3)));
    decimal(decimal<1e4) = decimal(decimal<1e4)*10; % force number of digits 
    exponent = str2double(string(ndd(:,end-1:end)));
    exponent(exponent>0) = -exponent(exponent>0); % force exponents to negative
    ndd = 2*pi*decimal.*10.^(exponent-5)./Tm^3; % [rad/min^3]	second derivative of mean motion

    Bstar = char(read{7});
    decimal = str2double(string(Bstar(:,1:5)));
    decimal(decimal<1e4) = decimal(decimal<1e4)*10; % force number of digits 
    exponent = str2double(string(Bstar(:,end-1:end)));
    exponent(exponent>0) = -exponent(exponent>0); % force exponents to negative
    Bstar = decimal.*10.^(exponent-5);  % [1/Re]    drag term

    %...Compute semi-major axis and correct mean motion
    a = (mu./n.^2).^(1/3);
    delta = 3/2*(1/2*J2*Re^2)./a.^2.*(3*cos(i).^2-1)./(1-e.^2).^(3/2);
    a = a.*(1-1/3*delta-delta.^2-134/81*delta.^3);
    delta = 3/2*(1/2*J2*Re^2)./a.^2.*(3*cos(i).^2-1)./(1-e.^2).^(3/2);
    n = n./(1+delta);    % [rad/s]   mean motion
    a = a./(1-delta);    % [m]       semi-major axis

    %...Compute true anomaly
    EA = MA.*ones(size(MA));
    EA_0 = zeros(size(MA));
    iter = 0;
    while any(abs(EA-EA_0)>1e-10) && iter < 5e3 % iterative process (with safety break)
        iter = iter+1;
        EA_0 = EA;
        EA = EA_0 + (MA-EA_0+e.*sin(EA_0))./(1-e.*cos(EA_0)); % eccentric anomaly
    end
    TA = wrapTo2Pi(2.*atan(sqrt((1+e)./(1-e)).*tan(EA./2)));  % [rad] true anomaly

    %...Combine Keplerian elements
    kepler = horzcat(t,a,e,i,O,o,TA,MA);
    propagation = horzcat(n.*60,nd,ndd,Bstar); % convert mean motion to rad/min

    %...Sort data
    kepler(:,2:end) = kepler(index,2:end);
    propagation = propagation(index,:);

    %...Remove duplicates
    where = diff(t)<=1e-8; % find duplicates in time
    kepler(where,:) = [];
    propagation(where,:) = [];

    %...Remove outliers
    if outlier == true
        %...Combine in one array
        combined = horzcat(kepler,propagation);

        %...Keplerian elements (exclude angles)
        for i = 2:size(kepler,2)-3
            dKE = diff(combined(:,i));
            combined_firstRow = combined(1,:);
            combined = chauvenet(combined(2:end,:),dKE);
            combined = vertcat(combined_firstRow,combined);
        end

        %...Uncombine arrays
        kepler = combined(:,1:8);
        propagation = combined(:,9:end);
    end
    
    %...Store all elements
    satIDAll{filenum} = satID;
    keplerAll{filenum} = kepler;
    propagationAll{filenum} = propagation;
end

%...Plot results
if showfig == true
    plotAll('elements',{keplerAll},options);
end

%...Struct of extraced data
extract = struct('ID',satIDAll,'orbit',keplerAll,'propagator',propagationAll);

%...Add filed in options
IDs = satIDAll;
[options.ID] = IDs{:};