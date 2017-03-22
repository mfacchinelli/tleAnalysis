function [JD] = TLE_Epoch(epoch)
%TLE_EPOCH Summary of this function goes here
%   Detailed explanation goes here

    year = Trunc(epoch/1000);
    doy = (epoch*0.001-year)*1000;
    if (year < 57)
        year = year + 2000;
    else
        year = year + 1900;
    end
    
    JD = Julian_Date_of_Year(year)+doy;
end