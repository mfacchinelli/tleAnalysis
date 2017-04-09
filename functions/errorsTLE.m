%  MATLAB Function < errorsTLE >
%
%  Purpose:     analyse the residuals between TLE and propagated orbit
%               elements in order to find correlations between different
%               satellite and orbital properties     
%  Input:
%   - extract:  structure array containing: 
%                   1) ID:          satellite identifier
%                   2) orbit:       time of TLE measurements and corresponding 
%                                   Keplerian elements (t,a,e,i,O,o,TA,MA)
%                   3) propagator:  data for propagation for each
%                                   observation time (n,nd,ndd,Bstar)
%   - options:  structure array containing:
%                   1) file:    file name to be read, to extract TLE information
%                   2) showfig:	command whether to show plots
%                   3) ignore:  percentage of data which is ignored during
%                               the analysis
%                   4) offset:  number of steps to take between observations
%                   5) outlier: command whether to apply Chauvenet's criterion
%  Output:
%   - stat:     array containing satellite properties (mass, shape factor 
%               presence of solar panels) and Keplerian element statistical 
%               data (mean and std) for each satellite
%   - corr:     cell array containing correlations between different
%               Keplerian elements and errors

function [stat,corr] = errorsTLE(extract,options)

%...Get number of satellites
satnum = size(options,2);

%...Load data on satellites
load('statistics/satData.mat');

%...Initialize arrays for correlation data
Corr_err = NaN(satnum,6);
Corr_a = NaN(satnum,4);
Corr_e = NaN(satnum,4);
Corr_i = NaN(satnum,4);
Corr_O = NaN(satnum,4);

%...Initialize satellite statistics array
stat = NaN(satnum,11);

%...Loop over files
for filenum = 1:satnum
    %...Select options
    option = options(:,filenum);
    
    %...Extract option
    file = option.file;
    showfig = option.showfig;
    outlier = option.outlier;
    ignore = option.ignore;
    k = option.offset;
    
    %...Get NORAD ID
    norID = regexprep(file,'[files/.txt]','');
    
    %...Extract data
    data = extract(filenum);
    keplerTLE = data.orbit;

    %...Propagate orbit
    keplerProp = propagateTLE(data,option);

    %...Ignore intial part of TLE (avoid injection maneuver)
    lower = ceil(ignore*size(keplerTLE,1));
    lower(lower==0) = 1;
    
    %...Remove first XX percent of TLE data
    keplerPlot = keplerTLE(lower:k:end-1,:);
    keplerTLE = keplerTLE(lower+k:k:end,:);
    
    %...Find residuals in propagation and correct for constant offset
    daProp = keplerProp(:,2)-keplerTLE(:,2);
    a_offset = median(daProp); daProp = daProp-a_offset;
    keplerProp(:,2) = keplerProp(:,2)-a_offset;

    deProp = keplerProp(:,3)-keplerTLE(:,3);
    e_offset = median(deProp); deProp = deProp-e_offset;
    keplerProp(:,3) = keplerProp(:,3)-e_offset;

    diProp = keplerProp(:,4)-keplerTLE(:,4);
    i_offset = median(diProp); diProp = diProp-i_offset;
    keplerProp(:,4) = keplerProp(:,4)-i_offset;

    dOProp = keplerProp(:,5)-keplerTLE(:,5);
    O_offset = median(dOProp); dOProp = dOProp-O_offset;
    keplerProp(:,5) = keplerProp(:,5)-O_offset;

    dTAProp = keplerProp(:,6)-keplerTLE(:,6); % do not remove offset

    %...Remove changes of 2pi degrees from O and TA
    dOProp(dOProp>pi) = dOProp(dOProp>pi)-2*pi;
    dOProp(dOProp<-pi) = dOProp(dOProp<-pi)+2*pi;
    dTAProp(dTAProp>pi) = dTAProp(dTAProp>pi)-2*pi;
    dTAProp(dTAProp<-pi) = dTAProp(dTAProp<-pi)+2*pi;
    
    %...Apply Chauvenet's criterion if required
    if outlier == true
        %...Combine in one array
        combined = horzcat(keplerTLE,keplerProp,keplerPlot,daProp,deProp,diProp,dOProp);
        
        %...Remove outliers
        combined = chauvenet(combined,daProp);
        combined = chauvenet(combined,deProp);
        combined = chauvenet(combined,diProp);
        combined = chauvenet(combined,dOProp);
        combined = chauvenet(combined,dTAProp);
        
        %...Uncombine arrays
        keplerTLE = combined(:,1:8);
        keplerProp = combined(:,9:16);
        keplerPlot = combined(:,17:24);
        daProp = combined(:,25);
        deProp = combined(:,26);
        diProp = combined(:,27);
        dOProp = combined(:,28);
    end
    
    %...Show plots
    if showfig == true
        plotAll('residuals',{keplerTLE,keplerProp,mergeArrays(keplerPlot,keplerProp),[daProp,deProp,diProp,dOProp]},option);
    end
    
    %...Compute statistical properties of residuals
    a_stat = [std(daProp),mean(daProp)];
    e_stat = [std(deProp),mean(deProp)];
    i_stat = [std(diProp),mean(diProp)];
    O_stat = [std(dOProp),mean(dOProp)];
    
    %...Access current satellite and save statistics
    current_sat = satellites(norID);
    stat(filenum,:) = [current_sat(1),current_sat(2),current_sat(3),a_stat,e_stat,i_stat,O_stat];

    %...Extract Keplerian elements
    a = keplerTLE(:,2);
    e = keplerTLE(:,3);
    i = keplerTLE(:,4);
    O = keplerTLE(:,5);

    %...Correlations between errors
    Cor_dade = corrcoef([daProp,deProp]);
    Cor_dadi = corrcoef([daProp,diProp]);
    Cor_dadO = corrcoef([daProp,dOProp]);
    Cor_dedi = corrcoef([deProp,diProp]);
    Cor_dedO = corrcoef([deProp,dOProp]);
    Cor_didO = corrcoef([diProp,dOProp]);

    %...Correlations between orbital elements and errors
    Cor_ada = corrcoef([a,daProp]);
    Cor_ade = corrcoef([a,deProp]);
    Cor_adi = corrcoef([a,diProp]);
    Cor_adO = corrcoef([a,dOProp]);

    Cor_eda = corrcoef([e,daProp]);
    Cor_ede = corrcoef([e,deProp]);
    Cor_edi = corrcoef([e,diProp]);
    Cor_edO = corrcoef([e,dOProp]);

    Cor_ida = corrcoef([i,daProp]);
    Cor_ide = corrcoef([i,deProp]);
    Cor_idi = corrcoef([i,diProp]);
    Cor_idO = corrcoef([i,dOProp]);

    Cor_Oda = corrcoef([O,daProp]);
    Cor_Ode = corrcoef([O,deProp]);
    Cor_Odi = corrcoef([O,diProp]);
    Cor_OdO = corrcoef([O,dOProp]);

    %...Store correlation data
    Corr_err(filenum,:) = [Cor_dade(1,2),Cor_dadi(1,2),Cor_dadO(1,2),...
                           Cor_dedi(1,2),Cor_dedO(1,2),Cor_didO(1,2)];

    Corr_a(filenum,:) = [Cor_ada(1,2),Cor_ade(1,2),Cor_adi(1,2),Cor_adO(1,2)];
    Corr_e(filenum,:) = [Cor_eda(1,2),Cor_ede(1,2),Cor_edi(1,2),Cor_edO(1,2)];
    Corr_i(filenum,:) = [Cor_ida(1,2),Cor_ide(1,2),Cor_idi(1,2),Cor_idO(1,2)];
    Corr_O(filenum,:) = [Cor_Oda(1,2),Cor_Ode(1,2),Cor_Odi(1,2),Cor_OdO(1,2)];
end

%...Add all correlation data in one cell array
corr{1} = Corr_err;
corr{2} = Corr_a;
corr{3} = Corr_e;
corr{4} = Corr_i;
corr{5} = Corr_O;