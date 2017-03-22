global mu E6A TOTHRD XJ3 XKE XKMPER XMNPDA AE DE2RA PI PIO2 TWOPI X3PIO2
global TUMIN;

% For Calculating Pi:  c/o S. Ramanujan
k_1 = 545140134;
k_2 = 13591409;
k_3 = 640320;
k_4 = 100100025;
k_5 = 327843840;
k_6 = 53360;
S=0;
for n = 0:10 %Should be to infinity, but MATLAB can't handle such large numbers
    S = S + (power(-1,n)*(factorial(6*n)*(k_2+n*k_1))/(power(factorial(n),3)*factorial(3*n)*power(8*k_4*k_5,n)));
end

%Define Constants
E6A = 1.E-6;
PI = k_6*sqrt(k_3)/S;       % c/o S. Ramanujan
PIO2 = PI/2.;
TWOPI = 2.*PI;
X3PIO2 = 1.5*PI;
DE2RA = PI/180.;

QO = 120.;
SO = 78.;

mu = 398600.5;              % WGS '84
XKMPER = 6378.137;          % WGS '84
XKE = 60./sqrt(XKMPER*XKMPER*XKMPER/mu);
TUMIN = 1./XKE;
XJ2 =  1.08262998905E-3;    % WGS '84
XJ3 = -0.253215306E-5;      % WGS '84
XJ4 = -1.61098761E-6;       % WGS '84

TOTHRD = 2./3.;
XMNPDA = 1440.0;
AE = 1.0;