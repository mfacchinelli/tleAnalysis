%  MATLAB Function < SGP4 >
%
%  Purpose:     propagate TLE data with SGP4 algorithm, based on Spacetrack 
%               Report No. 3; originally created by Paul Schattenberg and 
%               adapted by the tleAnalysis team
%  Input:
%   - TSINCE:   time difference between initial time and final time (time
%               of propagation)
%   - AODP:     semi-major axis at initial time
%   - XMO:      mean anomaly at initial time
%   - XNODEO:   right ascension of ascending node at initial time
%   - OMEGAO:   argument of perigee at initial time
%   - EO:       eccentricity at initial time
%   - XINCL:    inclination at initial time
%   - XNODP:    mean motion at initial time
%   - BSTAR:    Bstar parameter at initial time
%  Output:
%   - cart:     Cartesian coordinates after propagation

function [cart] = SGP4(TSINCE,AODP,XMO,XNODEO,OMEGAO,EO,XINCL,XNODP,BSTAR)

%...Global constants
global mu Re J2 J4 Ts Tm

% Inputs:
%   Time [min]
%   a [Re]
%   MA [rad]
%   o [rad]
%   O [rad]
%   e [-]
%   i [rad]
%   n [rad/min]
%   Bstar [1/Re]

QO = 120.0;
SO = 78.0;
S = (1.+SO/(Re/1e3));
CK2 = .5*J2;
CK4 = -.375*J4;
TEMP = (QO-SO)/(Re/1e3);
QOMS2T = TEMP*TEMP*TEMP*TEMP;

%% RECOVER ORIGINAL MEAN MOTION (XNODP) AND SEMIMAJOR AXIS (AODP) FROM INPUT ELEMENTS

IFLAG = 1;
if (IFLAG == 1)
%     A1 = power((sqrt(mu/Re^3*60^2)/XNO),2/3);
    COSIO = cos(XINCL);
    THETA2 = COSIO*COSIO;
    X3THM1 = 3.*THETA2-1.;
    EOSQ = EO*EO;
    BETAO2 = 1.-EOSQ;
    BETAO = sqrt(BETAO2);
%     DEL1 = 1.5*CK2*X3THM1/(A1*A1*BETAO*BETAO2);
%     AO = A1*(1.-DEL1*(.5*2/3+DEL1*(1.+134./81.*DEL1)));
%     DELO = 1.5*CK2*X3THM1/(AO*AO*BETAO*BETAO2);
%     XNODP = XNO/(1.+DELO);
%     AODP = AO/(1.-DELO);
    
    % Initialization
    
    % FOR PERIGEE LESS THAN 220 KILOMETERS, THE ISIMP FLAG IS SET AND
    % THE EQUATIONS ARE TRUNCATED TO LINEAR VARIATION IN SQRT A AND
    % QUADRATIC VARIATION IN MEAN ANOMALY. ALSO, THE C3 TERM, THE
    % DELTA OMEGA TERM, AND THE DELTA M TERM ARE DROPPED.
    
    ISIMP = 0;
    if((AODP*(1.-EO)/1) < (220/(Re/1e3)+1))
        ISIMP = 1;
    end
    
    % FOR PERIGEE BELOW 156 KM, THE VALUES OF
    % S AND QOMS2T ARE ALTERED
    
    S4 = S;
    QOMS24 = QOMS2T;
    PERIGE = (AODP*(1.-EO)-1)*(Re/1e3);
    if (PERIGE < 156.)
        if (PERIGE <= 98.)
            S4 = 20.;
        else
            S4 = PERIGE-78.;
        end
        QOMS24 = power(((120.-S4)/(Re/1e3)),4);
        S4 = S4/(Re/1e3)+1;
    end
    PINVSQ = 1./(AODP*AODP*BETAO2*BETAO2);
    TSI = 1./(AODP-S4);
    ETA = AODP*EO*TSI;
    ETASQ = ETA*ETA;
    EETA = EO*ETA;
    PSISQ = abs(1.-ETASQ);
    COEF = QOMS24*TSI*TSI*TSI*TSI;
    COEF1 = COEF/power(PSISQ,3.5);
    C2 = COEF1*XNODP*(AODP*(1.+1.5*ETASQ+EETA*(4.+ETASQ))+.75*CK2*TSI/PSISQ*X3THM1*(8.+3.*ETASQ*(8.+ETASQ)));
    C1 = BSTAR*C2;
    SINIO = sin(XINCL);
    A3OVK2 = --0.253881E-5/CK2*power(1,3);
    C3 = COEF*TSI*A3OVK2*XNODP*SINIO/EO;
    X1MTH2 = 1.-THETA2;
    C4 = 2.*XNODP*COEF1*AODP*BETAO2*(ETA*(2.+.5*ETASQ)+EO*(.5+2.*ETASQ)-2.*CK2*TSI/(AODP*PSISQ)*(-3.*X3THM1*(1.-2.*EETA+ETASQ*(1.5-.5*EETA))...
        +.75*X1MTH2*(2.*ETASQ-EETA*(1.+ETASQ))*cos(2.*OMEGAO)));
    C5 = 2.*COEF1*AODP*BETAO2*(1.+2.75*(ETASQ+EETA)+EETA*ETASQ);
    THETA4 = THETA2*THETA2;
    TEMP1 = 3.*CK2*PINVSQ*XNODP;
    TEMP2 = TEMP1*CK2*PINVSQ;
    TEMP3 = 1.25*CK4*PINVSQ*PINVSQ*XNODP;
    XMDOT = XNODP+.5*TEMP1*BETAO*X3THM1+.0625*TEMP2*BETAO*(13.-78.*THETA2+137.*THETA4);
    X1M5TH = 1.-5.*THETA2;
    OMGDOT = -.5*TEMP1*X1M5TH+.0625*TEMP2*(7.-114.*THETA2+395.*THETA4)+TEMP3*(3.-36.*THETA2+49.*THETA4);
    XHDOT1 = -TEMP1*COSIO;
    XNODOT = XHDOT1+(.5*TEMP2*(4.-19.*THETA2)+2.*TEMP3*(3.-7.*THETA2))*COSIO;
    OMGCOF = BSTAR*C3*cos(OMEGAO);
    XMCOF = -2/3*COEF*BSTAR/EETA;
    XNODCF = 3.5*BETAO2*XHDOT1*C1;
    T2COF = 1.5*C1;
    XLCOF = .125*A3OVK2*SINIO*(3.+5.*COSIO)/(1.+COSIO);
    AYCOF = .25*A3OVK2*SINIO;
    DELMO = power((1.+ETA*cos(XMO)),3);
    SINMO = sin(XMO);
    X7THM1 = 7.*THETA2-1.;
    if (ISIMP ~= 1)
        C1SQ = C1*C1;
        D2 = 4.*AODP*TSI*C1SQ;
        TEMP = D2*TSI*C1/3.;
        D3 = (17.*AODP+S4)*TEMP;
        D4 = .5*TEMP*AODP*TSI*(221.*AODP+31.*S4)*C1;
        T3COF = D2+2.*C1SQ;
        T4COF = .25*(3.*D3+C1*(12.*D2+10.*C1SQ));
        T5COF = .2*(3.*D4+12.*C1*D3+6.*D2*D2+15.*C1SQ*(2.*D2+C1SQ));
    end
    IFLAG = 0;
end

%% Update for Secular Gravity and Atmospheric Drag

XMDF = XMO+XMDOT*TSINCE;
OMGADF = OMEGAO+OMGDOT*TSINCE;
XNODDF = XNODEO+XNODOT*TSINCE;
OMEGA = OMGADF;
XMP = XMDF;
TSQ = TSINCE*TSINCE;
XNODE = XNODDF+XNODCF*TSQ;
TEMPA = 1.-C1*TSINCE;
TEMPE = BSTAR*C4*TSINCE;
TEMPL = T2COF*TSQ;
if (ISIMP ~= 1)
    DELOMG = OMGCOF*TSINCE;
    DELMTEMP = 1.+ETA*cos(XMDF);
    DELM = XMCOF*(DELMTEMP*DELMTEMP*DELMTEMP-DELMO);
    TEMP = DELOMG+DELM;
    XMP = XMDF+TEMP;
    OMEGA = OMGADF-TEMP;
    TCUBE = TSQ*TSINCE;
    TFOUR = TSINCE*TCUBE;
    TEMPA = TEMPA-D2*TSQ-D3*TCUBE-D4*TFOUR;
    TEMPE = TEMPE+BSTAR*C5*(sin(XMP)-SINMO);
    TEMPL = TEMPL+T3COF*TCUBE+TFOUR*(T4COF+TSINCE*T5COF);
end
A = AODP*power(TEMPA,2);
E = EO-TEMPE;
XL = XMP+OMEGA+XNODE+XNODP*TEMPL;
BETA = sqrt(1.-E*E);
XN = sqrt(mu/Re^3*60^2)/power(A,1.5);

%% Long Period Periodics

AXN = E*cos(OMEGA);
TEMP = 1./(A*BETA*BETA);
XLL = TEMP*XLCOF*AXN;
AYNL = TEMP*AYCOF;
XLT = XL+XLL;
AYN = E*sin(OMEGA)+AYNL;

%% Solve Keplers Equation

CAPU = wrapTo2Pi(XLT-XNODE);
TEMP2 = CAPU;
for i=1:10
    SINEPW = sin(TEMP2);
    COSEPW = cos(TEMP2);
    TEMP3 = AXN*SINEPW;
    TEMP4 = AYN*COSEPW;
    TEMP5 = AXN*COSEPW;
    TEMP6 = AYN*SINEPW;
    EPW = (CAPU-TEMP4+TEMP3-TEMP2)/(1.-TEMP5-TEMP6)+TEMP2;
    if (abs(EPW-TEMP2) <= 1e-6)
        break;
    end
    TEMP2 = EPW;
end

%% Short Period Preliminary Quantities

ECOSE = TEMP5+TEMP6;
ESINE = TEMP3-TEMP4;
ELSQ = AXN*AXN+AYN*AYN;
TEMP = 1.-ELSQ;
PL = A*TEMP;
R = A*(1.-ECOSE);
TEMP1 = 1./R;
RDOT = sqrt(mu/Re^3*60^2)*sqrt(A)*ESINE*TEMP1;
RFDOT = sqrt(mu/Re^3*60^2)*sqrt(PL)*TEMP1;
TEMP2 = A*TEMP1;
BETAL = sqrt(TEMP);
TEMP3 = 1./(1.+BETAL);
COSU = TEMP2*(COSEPW-AXN+AYN*ESINE*TEMP3);
SINU = TEMP2*(SINEPW-AYN-AXN*ESINE*TEMP3);
U = atan2(SINU,COSU);
SIN2U = 2.*SINU*COSU;
COS2U = 2.*COSU*COSU-1.;
TEMP = 1./PL;
TEMP1 = CK2*TEMP;
TEMP2 = TEMP1*TEMP;

%% Update for Short Periodics

RK = R*(1.-1.5*TEMP2*BETAL*X3THM1)+.5*TEMP1*X1MTH2*COS2U;
UK = U-.25*TEMP2*X7THM1*SIN2U;
XNODEK = XNODE+1.5*TEMP2*COSIO*SIN2U;
XINCK = XINCL+1.5*TEMP2*COSIO*SINIO*COS2U;
RDOTK = RDOT-XN*TEMP1*X1MTH2*SIN2U;
RFDOTK = RFDOT+XN*TEMP1*(X1MTH2*COS2U+1.5*X3THM1);

%% Orientation Vectors

SINUK = sin(UK);
COSUK = cos(UK);
SINIK = sin(XINCK);
COSIK = cos(XINCK);
SINNOK = sin(XNODEK);
COSNOK = cos(XNODEK);
XMX = -SINNOK*COSIK;
XMY = COSNOK*COSIK;
UX = XMX*SINUK+COSNOK*COSUK;
UY = XMY*SINUK+SINNOK*COSUK;
UZ = SINIK*SINUK;
VX = XMX*COSUK-COSNOK*SINUK;
VY = XMY*COSUK-SINNOK*SINUK;
VZ = SINIK*COSUK;

%% Position and Velocity

X = RK*UX;
Y = RK*UY;
Z = RK*UZ;
XDOT = RDOTK*UX+RFDOTK*VX;
YDOT = RDOTK*UY+RFDOTK*VY;
ZDOT = RDOTK*UZ+RFDOTK*VZ;

cart(1) = X*Re; cart(2) = Y*Re; cart(3) = Z*Re;
cart(4) = XDOT*Re*Tm/Ts; cart(5) = YDOT*Re*Tm/Ts; cart(6) = ZDOT*Re*Tm/Ts;

end