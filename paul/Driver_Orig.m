% DRIVER                                                   3 NOV 80
% WGS-72 PHYSICAL AND GEOPOTENTIAL CONSTANTS
%        CK2= .5*J2*AE**2     CK4=-.375*J4*AE**4

clc;
clear all;
close all;

global CK2 CK4 E6A QOMS2T S TOTHRD XJ3 XKE XKMPER XMNPDA AE;
global DE2RA PI PIO2 TWOPI X3PIO2;

DE2RA = .174532925E-1;
E6A = 1.E-6;
PI = 3.14159265;
PIO2 = 1.57079633;
QO = 120.0;
SO = 78.0;
TOTHRD = .66666667;
TWOPI = 6.2831853;
X3PIO2 = 4.71238898;
XJ2 = 1.082616E-3;
XJ3 = -.253881E-5;
XJ4 = -1.65597E-6;
XKE = .743669161E-1;
XKMPER = 6378.135;
XMNPDA = 1440.0;
AE = 1.;

%% Select Ephemeris Type and Output Times
CK2 = .5*XJ2*AE*AE;
CK4 = -.375*XJ4*AE*AE*AE*AE;
TEMP = (QO-SO)*AE/XKMPER;
QOMS2T = TEMP*TEMP*TEMP*TEMP;
S = AE*(1.+SO/XKMPER);
filename = input('TLE Filename (*.txt): ','s');
TLE = ReadTLE([filename,'.txt']);

index = 1;
while true
    n = input('IEPT,TS,TF,DELT: ','s');
    n = regexp(n,',','split');
    IEPT = str2num(n{1});
    TS = str2num(n{2});
    TF = str2num(n{3});
    DELT = str2num(n{4});
    if (IEPT <= 0)
        disp('IEPT NOT A VALID NUMBER!');
        return;
    end
    IDEEP = 0;
    
    %% Read In Mean Elements From 2 Card T(Trans) or G(INTERN) Format
    [EPOCH,XNDT2O,XNDD6O,IEXP,BSTAR,IBEXP,XINCL,XNODEO,EO,OMEGAO,XMO,XNO] = TLE_PullApart(TLE,index);
    if (XNO <= 0.0)
        return;
    end
    if (IEPT > 5)
        fprintf('EPHEMERIS NUMBER %d NOT LEGAL, WILL SKIP THIS CASE\n',IEPT);
        continue;
    end
    
    XNDD6O = XNDD6O*power(10.,IEXP);
    XNODEO = XNODEO*DE2RA;
    OMEGAO = OMEGAO*DE2RA;
    XMO = XMO*DE2RA;
    XINCL = XINCL*DE2RA;
    TEMP = TWOPI/XMNPDA/XMNPDA;
    XNO = XNO*TEMP*XMNPDA;
    XNDT2O = XNDT2O*TEMP;
    XNDD6O = XNDD6O*TEMP/XMNPDA;
    
    %% Input Check for Period vs. Ephemeris Selected
    %  Period GE 225 Minutes is Deep Space
    A1 = power(XKE/XNO,TOTHRD);
    TEMP = 1.5*CK2*(3.*cos(XINCL)*cos(XINCL)-1.)/power(1.-EO*EO,1.5);
    DEL1 = TEMP/(A1*A1);
    AO = A1*(1.-DEL1*(.5*TOTHRD+DEL1*(1.+134./81.*DEL1)));
    DELO = TEMP/(AO*AO);
    XNODP = XNO/(1.+DELO);
    if ((TWOPI/XNODP/XMNPDA) >= 0.15625)
        IDEEP = 1;
    end
    
    BSTAR = BSTAR*power(10.,IBEXP)/AE;
    TSINCE = TS;
    IFLAG = 1;
    if (IDEEP == 1 && (IEPT == 1 || IEPT == 2 || IEPT == 4))
        disp('SHOULD USE DEEP SPACE EPHEMERIS');
    end
    if (IDEEP == 0 && (IEPT == 3 || IEPT == 5))
        disp('SHOULD USE NEAR EARTH EPHEMERIS');
    end
    while true
        switch IEPT
            case 1
                [POS,VEL] = SGP(TSINCE,XMO,XNODEO,OMEGAO,EO,XINCL,XNO,XNDT2O,XNDD6O);
            case 2
                [POS,VEL] = SGP4(TSINCE,XMO,XNODEO,OMEGAO,EO,XINCL,XNO,BSTAR);
            case 3
                disp('SDP4 NOT YET IMPLIMENTED!  FALLING BACK TO SGP.');
                [POS,VEL] = SGP(IFLAG,TSINCE,XMO,XNODEO,OMEGAO,EO,XINCL,XNO,XNDT2O,XNDD6O,BSTAR);
                % SDP4(IFLAG,TSINCE);
            case 4
                disp('SGP8 NOT YET IMPLIMENTED!  FALLING BACK TO SGP.');
                [POS,VEL] = SGP(IFLAG,TSINCE,XMO,XNODEO,OMEGAO,EO,XINCL,XNO,XNDT2O,XNDD6O,BSTAR);
                % SGP8(IFLAG,TSINCE);
            case 5
                disp('SDP8 NOT YET IMPLIMENTED!  FALLING BACK TO SGP.');
                [POS,VEL] = SGP(IFLAG,TSINCE,XMO,XNODEO,OMEGAO,EO,XINCL,XNO,XNDT2O,XNDD6O,BSTAR);
                % SDP8(IFLAG,TSINCE);
        end
        X = POS(1);
        Y = POS(2);
        Z = POS(3);
        XDOT = VEL(1);
        YDOT = VEL(2);
        ZDOT = VEL(3);

        fprintf('%17.8f %17.8f %17.8f %17.8f %17.8f %17.8f %17.8f\n',TSINCE,X,Y,Z,XDOT,YDOT,ZDOT);

        TSINCE = TSINCE+DELT;
        if (abs(TSINCE) > abs(TF))
            break;
        end
    end
    return;
end