function [JDo] = Julian_Date_of_Year(year)
%Julian_Date_of_Year Calculate Julian Date of 0.0 Jan year
%   INPUT: YEAR
%   OUTPUT: JDo
    year = year - 1;
    A = Trunc(year/100);
    B = 2-A+Trunc(A/4);
    JDo = Trunc(365.25*year)+Trunc(30.6001*14)+1720994.5+B;
end