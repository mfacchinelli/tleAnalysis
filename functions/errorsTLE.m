%  MATLAB Function < errorsTLE >
%
%  Purpose:         
%  Input:
%   - 
% Output:
%   - 

function [stat,corr] = errorsTLE(extract,options)

%...Get number of satellites
satnum = size(options,2);

%...Load data on satellites
load('statistics/satData.mat');

%...Initialize arrays for correlation data
Corr_err = NaN(satnum,7);
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
    
    %...Get data of current satellite
    data = extract(filenum);

    %...Kepler elements
    keplerTLE = data.orbit;

    %...Propagate orbit
    keplerProp = propagateTLE(data,option);

    %...Ignore intial part of TLE (avoid injection maneuver)
    lower = ceil(ignore*size(keplerTLE,1));
    lower(lower==0) = 1;
    
    %...Remove first XX percent of TLE data
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

    dTAProp = keplerProp(:,6)-keplerTLE(:,6); % don't remove offset

    %...Remove changes of 2pi degrees from O and TA
    dOProp(dOProp>pi) = dOProp(dOProp>pi)-2*pi;
    dOProp(dOProp<-pi) = dOProp(dOProp<-pi)+2*pi;
    dTAProp(dTAProp>pi) = dTAProp(dTAProp>pi)-2*pi;
    dTAProp(dTAProp<-pi) = dTAProp(dTAProp<-pi)+2*pi;

    %...Apply Chauvenet's criterion if required
    if (outlier == true)
        %...Make one combined matrix and remove outliers
        smoothed = horzcat(keplerTLE,keplerProp,daProp,deProp,diProp,dOProp);
        smoothed = chauvenet(smoothed,daProp);
        smoothed = chauvenet(smoothed,deProp);
        smoothed = chauvenet(smoothed,diProp);
        smoothed = chauvenet(smoothed,dOProp);
        smoothed = chauvenet(smoothed,dTAProp);

        keplerTLE = smoothed(:,1:8);
        keplerProp = smoothed(:,9:16);
        daProp = smoothed(:,17);

        deProp = smoothed(:,18);
        diProp = smoothed(:,19);
        dOProp = smoothed(:,20);
    end
    
    %...Compute statistical properties of residuals
    a_stat = [std(daProp),mean(daProp)];
    e_stat = [std(deProp),mean(deProp)];
    i_stat = [std(diProp),mean(diProp)];
    O_stat = [std(dOProp),mean(dOProp)];
    
    %...Access current satellite and save sttistics to array
    current_sat = satellites(norID);
    stat(filenum,:) = [current_sat(1),current_sat(2),current_sat(3),a_stat,e_stat,i_stat,O_stat];

    %...Show plots
    if showfig == true
        plotAll('residuals',{keplerTLE,keplerProp,[daProp,deProp,diProp,dOProp]},options);
    end

    t = keplerTLE(:,1);
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
    Corr_err(filenum,:) = [Cor_dade(1,2),Cor_dadi(1,2),Cor_dadO(1,2),Cor_dadO(1,2),Cor_dedi(1,2),Cor_dedO(1,2),Cor_didO(1,2)];

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