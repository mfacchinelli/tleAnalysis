function [POS,VEL] = SGP(TSINCE,XMO,XNODEO,OMEGAO,EO,XINCL,XNO,XNDT2O,XNDD6O)
%SGP This function is used to calculate the P0sition and velocity of
%satellites. TSINCE is time since eP0ch in minutes, tle is a P0inter to a
%tle_t structure with Keplerian orbital elements and P0s and vel are
%vector_t structures returning ECI satellite P0sition and velocity.
%Use Convert_Sat_State() to convert to km and km/s.

global CK2 CK4 E6A QOMS2T S TOTHRD XJ3 XKE XKMPER XMNPDA AE;

%% Initialization
IFLAG = 1;  % Let's just re-calculate these every iteration...
if (IFLAG ~=0)
    C1 = CK2*1.5;
    C2 = CK2/4.0;
    C3 = CK2/2.0;
    C4 = XJ3*AE*AE*AE/(4.0*CK2);
    COSIO = cos(XINCL);
    SINIO = sin(XINCL);
    A1 = power(XKE/XNO,TOTHRD);
    D1 = C1/A1/A1*(3.*COSIO*COSIO-1.)/power(1.-EO*EO,1.5);
    AO = A1*(1.-1./3.*D1-D1*D1-134./81.*D1*D1*D1);
    PO = AO*(1.-EO*EO);
    QO = AO*(1.-EO);
    XLO = XMO+OMEGAO+XNODEO;
    D1O = C3*SINIO*SINIO;
    D2O = C2*(7.*COSIO*COSIO-1.);
    D3O = C1*COSIO;
    D4O = D3O*SINIO;
    PO2NO = XNO/(PO*PO);
    OMGDT = C1*PO2NO*(5.*COSIO*COSIO-1.);
    XNODOT = -2.*D3O*PO2NO;
    C5 = .5*C4*SINIO*(3.+5.*COSIO)/(1.+COSIO);
    C6 = C4*SINIO;
    IFLAG = 0;
end

%% UPDATE FOR SECULAR GRAVITY AND ATMOSPHERIC DRAG
A = XNO+(2.*XNDT2O+3.*XNDD6O*TSINCE)*TSINCE;
A = AO*power(XNO/A,TOTHRD);
E = E6A;
if (A > QO)
    E = 1.-QO/A;
end
P = A*(1.-E*E);
XNODES = XNODEO+XNODOT*TSINCE;
OMGAS = OMEGAO+OMGDT*TSINCE;
XLS = FMod2p(XLO+(XNO+OMGDT+XNODOT+(XNDT2O+XNDD6O*TSINCE)*TSINCE)*TSINCE);

%% LONG PERIOD PERIODICS
AXNSL = E*cos(OMGAS);
AYNSL = E*sin(OMGAS)-C6/P;
XL = FMod2p(XLS-C5/P*AXNSL);

%% SOLVE KEPLERS EQUATION
U = FMod2p(XL-XNODES);
ITEM3 = 0;
EO1 = U;
TEM5 = 1.;
while true
    SINEO1 = sin(EO1);
    COSEO1 = cos(EO1);
    if (abs(TEM5) < E6A)
        break;
    end
    if (ITEM3 >= 10)
        break;
    end
    ITEM3 = ITEM3+1;
    TEM5 = 1.-COSEO1*AXNSL-SINEO1*AYNSL;
    TEM5 = (U-AYNSL*COSEO1+AXNSL*SINEO1-EO1)/TEM5;
    TEM2 = abs(TEM5);
    if (TEM2 > 1.)
        TEM5 = TEM2/TEM5;
    end
    EO1 = EO1+TEM5;
end

%% SHORT PERIOD PRELIMINARY QUANTITIES
ECOSE = AXNSL*COSEO1+AYNSL*SINEO1;
ESINE = AXNSL*SINEO1-AYNSL*COSEO1;
EL2 = AXNSL*AXNSL+AYNSL*AYNSL;
PL = A*(1.-EL2);
PL2 = PL*PL;
R = A*(1.-ECOSE);
RDOT = XKE*sqrt(A)/R*ESINE;
RVDOT = XKE*sqrt(PL)/R;
TEMP = ESINE/(1.+sqrt(1.-EL2));
SINU = A/R*(SINEO1-AYNSL-AXNSL*TEMP);
COSU = A/R*(COSEO1-AXNSL+AYNSL*TEMP);
SU = AcTan(SINU,COSU);

%% UPDATE FOR SHORT PERIODICS
SIN2U = (COSU+COSU)*SINU;
COS2U = 1.-2.*SINU*SINU;
RK = R+D1O/PL*COS2U;
UK = SU-D2O/PL2*SIN2U;
XNODEK = XNODES+D3O*SIN2U/PL2;
XINCK = XINCL+D4O/PL2*COS2U;

%% ORIENTATION VECTORS
SINUK = sin(UK);
COSUK = cos(UK);
SINNOK = sin(XNODEK);
COSNOK = cos(XNODEK);
SINIK = sin(XINCK);
COSIK = cos(XINCK);
XMX = -SINNOK*COSIK;
XMY = COSNOK*COSIK;
UX = XMX*SINUK+COSNOK*COSUK;
UY = XMY*SINUK+SINNOK*COSUK;
UZ = SINIK*SINUK;
VX = XMX*COSUK-COSNOK*SINUK;
VY = XMY*COSUK-SINNOK*SINUK;
VZ = SINIK*COSUK;

%% POSITION AND VELOCITY
X = RK*UX;
Y = RK*UY;
Z = RK*UZ;
XDOT = RDOT*UX;
YDOT = RDOT*UY;
ZDOT = RDOT*UZ;
XDOT = RVDOT*VX+XDOT;
YDOT = RVDOT*VY+YDOT;
ZDOT = RVDOT*VZ+ZDOT;

POS(1)=X;POS(2)=Y;POS(3)=Z;
VEL(1)=XDOT;VEL(2)=YDOT;VEL(3)=ZDOT;

[POS,VEL] = Convert_Sat_State(POS,VEL);

end