%  MATLAB Function < thrustTLE >
%
%  Purpose:     detect thrust usage, by analyzing changes in TLE data
%  Input:
%   - kepler:   Keplerian elements of satellite to be analyzed 
%   - option:   structure array containing:
%                   1) showfig:     command whether to show plots
%                   2) limit:       minimum separation in days between two
%                                   distinct thrusting maneuvers
% Output:
%   - thrustPeriods:    array with lower and upper bounds for thrust
%                       periods, in days

function thrustTLE(data,options)

%...Loop over files
for filenum = 1:size(options,2)
    %...Select options
    option = options(:,filenum);
    
    %...Select data
    kepler = data(filenum).orbit;

    %...Extract option
    file = option.file;
    showfig = option.showfig;
    limit = option.limit;

    %...Get location of peaks
    [locs,CTP,maxCTP] = peaksTLE(kepler,option); % CTP: continuous thrust parameter

    %...Look for decay
    if kepler(end,2) <= 6.6e6
        decay = true;
    else 
        decay = false;
    end

    %...Look for thrust only if satellite does not decay
    file = regexprep(file,'[files/.txt]','');
    disp([newline,'Satellite: ',file])
    if decay == false
        %...Check for repetitions with tolerances of +/- 5 days
        thrustDays = [];
        for i = 1:3
            for j = 1+i:4
                if i ~= j
                    tol = 5/max(abs([kepler(locs{i},1);kepler(locs{j},1)]));
                    if ~isempty(tol)
                        locA = ismembertol(kepler(locs{i},1),kepler(locs{j},1),tol);
                        thrustDays = vertcat(thrustDays,kepler(locs{i}(locA)));
                    end
                end
            end
        end
        thrustDays = unique(thrustDays);

        %...Find thrust periods from change in orbital elements
        thrustPeriods = [];
        if ~isempty(thrustDays)
            impulsiveThrust = true;
            separation = diff(thrustDays);
            where = [0;find(separation>limit);size(separation,1)+1]+1;
            disp('Impulsive thrust detected.')
            for i = 1:size(where,1)-1
                thrustPeriods(i,:) = [floor(thrustDays(where(i))),ceil(thrustDays(where(i+1)-1))];
            end
        else
            impulsiveThrust = false;
        end

        %...Find continuous thrust and/or satellite decay
        if impulsiveThrust == false    
            %...Check if CTP is within constraints
            if CTP <= maxCTP || abs(CTP) < 0.05
                continuousThrust = false;
            else 
                continuousThrust = true;
                disp('Continuous thrust detected.')
            end

            %...Inform user on no thrust
            if continuousThrust == false
                disp('No thrust was detected.')
            end
        end

        %...Plot periods of thrust overlaid to Keplerian elements
        if showfig == true && impulsiveThrust == true
            plotAll('thrust',{kepler,thrustPeriods},option)
        end
    else
        disp('Satellite decayed.')
    end
end