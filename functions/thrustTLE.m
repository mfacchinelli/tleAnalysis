%  MATLAB Function < thrustTLE >
%
%  Purpose:     detect thrust usage, by analyzing changes in TLE data
%  Input:
%   - kepler:   Keplerian elements of satellite to be analyzed 
%   - options:  structure array containing:
%                   1) showfig:     command whether to show plots
%                   2) ignore:      percent of data to ignore at beginning
%                                   of observations
%                   3) factor:      safety factor for thrust detection
%                   4) limit:       minimum separation in days between two
%                                   distinct thrusting maneuvers
% Output:
%   - thrustPeriods:    array with lower and upper bounds for thrust
%                       periods, in days

function thrustPeriods = thrustTLE(extract,options)

%...Extract data
keplerTLE = extract.orbit;

%...Extract options
showfig = options.showfig;
ignore = options.ignore;
factor = options.factor;
limit = options.limit;

%...Propagate orbit
keplerProp = propagateTLE(extract,options);

%...Residuals between propagated values and reference TLEs (FIX THIS)
% lower = ceil(ignore*size(keplerTLE,1));
% lower(lower==0) = 1;
lower = 0;

%...Find residuals
da = keplerTLE(2:end,2)-keplerProp(:,2);
de = keplerTLE(2:end,3)-keplerProp(:,3);
di = keplerTLE(2:end,4)-keplerProp(:,4);
dO = keplerTLE(2:end,5)-keplerProp(:,5);

%...Remove changes of 2pi degrees from O and o
dO(dO>pi) = dO(dO>pi)-2*pi;
dO(dO<-pi) = dO(dO<-pi)+2*pi;

%...Show plots
if showfig == true
    plotAll(keplerTLE,keplerProp,[da,de,di,dO],options);
end

%...Get statistics
data = statTLE([da,de,di,dO],options);

%...Detect thrust peaks
warning('off')
[~,locs_a_1] = findpeaks(da,'MinPeakHeight',factor*data.a(1)); % positive change
[~,locs_a_2] = findpeaks(-da,'MinPeakHeight',factor*data.a(2)); % negative change
[~,locs_e_1] = findpeaks(de,'MinPeakHeight',factor*data.e(1)); % positive change
[~,locs_e_2] = findpeaks(-de,'MinPeakHeight',factor*data.e(2)); % negative change
[~,locs_i_1] = findpeaks(di,'MinPeakHeight',factor*data.i(1)); % positive change
[~,locs_i_2] = findpeaks(-di,'MinPeakHeight',factor*data.i(2)); % negative change
[~,locs_O_1] = findpeaks(dO,'MinPeakHeight',factor*data.O(1)); % positive change
[~,locs_O_2] = findpeaks(-dO,'MinPeakHeight',factor*data.O(2)); % negative change
warning('on')

%...Merge positive and negative values
locs_a = lower+sort(vertcat(locs_a_1,locs_a_2));
locs_e = lower+sort(vertcat(locs_e_1,locs_e_2));
locs_i = lower+sort(vertcat(locs_i_1,locs_i_2));
locs_O = lower+sort(vertcat(locs_O_1,locs_O_2));
locs = {locs_a,locs_e,locs_i,locs_O};

%...Check for repetitions
thrustDays = [];
for i = 1:3
    for j = 1+i:4
        if i ~= j
            thrustDays = vertcat(thrustDays,intersect(keplerTLE(locs{i},1),keplerTLE(locs{j},1)));
        end
    end
end
thrustDays = unique(thrustDays);

%...Find thrust periods
thrustPeriods = [];
if ~isempty(thrustDays)
    separation = diff(thrustDays);
    where = [0;find(separation>limit);size(separation,1)+1]+1;
    disp([newline,'Periods where thrust was detected:'])
    for i = 1:size(where,1)-1
        thrustPeriods(i,:) = [floor(thrustDays(where(i))),ceil(thrustDays(where(i+1)-1))];
        disp([num2str(i),char(9),num2str(floor(thrustDays(where(i)))),' - ',num2str(ceil(thrustDays(where(i+1)-1)))])
    end
    
    %...Plot periods of thrust overlaid to Keplerian elements
    if showfig == true
        figure;
        labels = {'a [m]','e [-]','i [deg]','\Omega [deg]','\omega [deg]','\vartheta [deg]'};
        for i = 1:size(keplerTLE,2)-1
            subplot(3,2,i)
            hold on
            plot(keplerTLE(:,1),keplerTLE(:,i+1))
            ax = gca;
            ylimit = ax.YLim;
            for j = 1:size(thrustPeriods,1)
                pos = [thrustPeriods(j,1),ylimit(1),diff(thrustPeriods(j,:)),ylimit(2)];
                rectangle('Position',pos,'FaceColor',[0.95,0.5,0.5,0.5])
            end
            hold off
            xlabel('Time [day]')
            ylabel(labels{i})
            xlim([keplerTLE(1,1),keplerTLE(end,1)])
            ylim(ylimit)
            grid on
            set(gca,'FontSize',13)
        end
    end
else
    disp([newline,'No thrust was detected.'])
end

