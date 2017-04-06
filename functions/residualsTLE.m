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
%                   5) offset:      number of steps to take between observations
% Output:
%   - thrustPeriods:    array with lower and upper bounds for thrust
%                       periods, in days

function residualsTLE(extract,options)

%...Loop over files
for filenum = 1:size(options,2)
    %...Select options
    option = options(:,filenum);

    %...Extract data
    keplerTLE = extract(filenum).orbit;

    %...Extract options
    showfig = option.showfig;
    ignore = option.ignore;
    factor = option.factor;
    limit = option.limit;
    k = option.offset;

    %...Propagate orbit
    keplerProp = propagateTLE(extract(filenum),option);

    %...Ignore intial part of TLE (avoid injection maneuver)
    lower = ceil(ignore*size(keplerTLE,1));
    lower(lower==0) = 1;

    %...Find residuals in propagation and correct for constant offset
    daProp = keplerProp(:,2)-keplerTLE(lower:k:end-1,2);
    a_offset = median(daProp); daProp = daProp-a_offset;
    keplerProp(:,2) = keplerProp(:,2)-a_offset;

    deProp = keplerProp(:,3)-keplerTLE(lower:k:end-1,3);
    e_offset = median(deProp); deProp = deProp-e_offset;
    keplerProp(:,3) = keplerProp(:,3)-e_offset;

    diProp = keplerProp(:,4)-keplerTLE(lower:k:end-1,4);
    i_offset = median(diProp); diProp = diProp-i_offset;
    keplerProp(:,4) = keplerProp(:,4)-i_offset;

    dOProp = keplerProp(:,5)-keplerTLE(lower:k:end-1,5);
    O_offset = median(dOProp); dOProp = dOProp-O_offset;
    keplerProp(:,5) = keplerProp(:,5)-O_offset;

    %...Change in orbital elements
    lower = ceil(ignore*size(keplerTLE,1));
    lower(lower==0) = 1;
    daTLE = diff(keplerTLE(lower:end,2));
    deTLE = diff(keplerTLE(lower:end,3));
    diTLE = diff(keplerTLE(lower:end,4));
    dOTLE = diff(keplerTLE(lower:end,5));

    %...Remove changes of 2pi degrees from O and o
    dOProp(dOProp>pi) = dOProp(dOProp>pi)-2*pi;
    dOProp(dOProp<-pi) = dOProp(dOProp<-pi)+2*pi;
    dOTLE(dOTLE>pi) = dOTLE(dOTLE>pi)-2*pi;
    dOTLE(dOTLE<-pi) = dOTLE(dOTLE<-pi)+2*pi;

    %...Show plots
    if showfig == true
        plotAll('residuals',{keplerTLE,keplerProp,[daProp,deProp,diProp,dOProp]},option);
    end
end