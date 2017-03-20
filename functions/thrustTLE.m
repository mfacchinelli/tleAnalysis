%  MATLAB Function < thrustTLE >
%
%  Purpose:     detect thrust usage, by analyzing changes in TLE data
%  Input:
%   - kepler:   Keplerian elements of satellite to be analyzed 
%   - options:  structure array containing:
%                   1) ignore:      percent of data to ignore at beginning
%                                   of observations
%                   2) factor:      safety factor for thrust detection
%                   3) limit:       minimum separation in days between two
%                                   distinct thrusting maneuvers
% Output:
%   - thrustPeriods:    array with lower and upper bounds for thrust
%                       periods, in days

function thrustPeriods = thrustTLE(kepler,options)

%...Extract options
ignore = options.ignore;
factor = options.factor;
limit = options.limit;

%...Change in orbital elements
lower = ceil(ignore*size(kepler,1));
lower(lower==0) = 1;
da = diff(kepler(lower:end,2));
de = diff(kepler(lower:end,3));
di = diff(kepler(lower:end,4));
dO = diff(kepler(lower:end,5));
do = diff(kepler(lower:end,6));

%...Remove changes of 360 degrees from O and o
dO(dO>180) = dO(dO>180)-360;
dO(dO<-180) = dO(dO<-180)+360;
do(do>180) = do(do>180)-360;
do(do<-180) = do(do<-180)+360;

%...Get statistics
data = statTLE([da,de,di,dO,do],options);

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
[~,locs_o_1] = findpeaks(do,'MinPeakHeight',factor*data.o(1)); % positive change
[~,locs_o_2] = findpeaks(-do,'MinPeakHeight',factor*data.o(2)); % negative change
warning('on')

%...Merge positive and negative values
locs_a = lower+sort(vertcat(locs_a_1,locs_a_2));
locs_e = lower+sort(vertcat(locs_e_1,locs_e_2));
locs_i = lower+sort(vertcat(locs_i_1,locs_i_2));
locs_O = lower+sort(vertcat(locs_O_1,locs_O_2));
locs_o = lower+sort(vertcat(locs_o_1,locs_o_2));
locs = {locs_a,locs_e,locs_i,locs_O,locs_o};

%...Check for repetitions
thrustDays = [];
for i = 1:3 % do not use O and o together (more likely to give false positives)
    for j = 1+i:5
        if i ~= j
            thrustDays = vertcat(thrustDays,intersect(kepler(locs{i},1),kepler(locs{j},1)));
        end
    end
end
thrustDays = unique(thrustDays);

%...Find thurst periods
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
    if strcmp(options.showfig,'yes')
        figure;
        labels = {'a [m]','e [-]','i [deg]','\Omega [deg]','\omega [deg]','\vartheta [deg]'};
        for i = 1:size(kepler,2)-1
            subplot(3,2,i)
            hold on
            plot(kepler(:,1),kepler(:,i+1))
            ax = gca;
            ylimit = ax.YLim;
            for j = 1:size(thrustPeriods,1)
                pos = [thrustPeriods(j,1),ylimit(1),diff(thrustPeriods(j,:)),ylimit(2)];
                rectangle('Position',pos,'FaceColor',[0.95,0.5,0.5,0.5])
            end
            hold off
            xlabel('Time [day]')
            ylabel(labels{i})
            xlim([kepler(1,1),kepler(end,1)])
            ylim(ylimit)
            grid on
            set(gca,'FontSize',13)
        end
    end
else
    disp([newline,'No thrust was detected.'])
end