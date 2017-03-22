function [incl,RAAN,e_mag,omega,xm,xn] = rv2osc(r,v,mu)
%% Convert from Keplerian to Cartesian
%  INPUT:
%    1 r       [x,y,z] 								%[km]
%    2 v       [Vx,Vy,Vz] 							%[km/s]
%  
%  OUTPUT:
%    [A,a,e_mag,i,RAAN,omega,xm,xn,nu0,u0,l0,p]
%     where A=[a,e_mag,i,RAAN,omega,xm,xn,nu0,u0,l0,p]
%  
%  Code Derrived from Fundimental of Astrodynamics, 1971.
%  Bate, Roger R, Donald D Mueller and Jerry E White. 
%  Fundamentals of Astrodynamics. New York: Dover Publications, Inc., 1971.
%  
%  Pg. 58 to 71 (Notes, Comments and Equations):
%    Section 2.3 Classical Orbital Elements
%    Section 2.4 Determining The Orbital Elements from r and v
%  
%  INPUT:   r=[x,y,z]   v=[Vx,Vy,Vz]
%  OUTPUT:  [A,a,e_mag,i,RAAN,omega,nu0,u0,l0,p]
%  
%  Code Written By:  Paul Schattenberg, 2014

%% Initialization Setup
global mu message
if (exist('message')~=1)
    message=0;
end
if (nargin<=2)
    mu = 398600.4415; % (Astronomical Almanac '17) (TT)
end

I=[1,0,0];
J=[0,1,0];
K=[0,0,1];

%% Determine the magnitude of the position and velocity vectors
R=norm(r);                                          %[km]
V=norm(v);                                          %[km/s]

%%  Calculate the angular momentum vector, h:
h=cross(r,v);                                       %[km^2/s]
H=norm(h);                                          %[km^2/s]

%%  Calculate the node vecotor, n:
n=cross(K,h);                                       %[km^2/s]
N=norm(n);                                          %[km^2/s]

%%  Calculate the eccentricity vector, e:
e=(1/mu)*((V*V-mu/R)*r-dot(r,v)*v);                 %[-]
e_mag=norm(e);                                      %[-]

%%  Calculate the inclination, i:
incl=acos(Dot(h,K)/H);                              %[rad]
if (incl==0 && message == 1);
    disp('NOTE:  Orbit on Equatorial Plane.')
end

%%  Calculate the right ascension of ascending node, RAAN:
RAAN=acos(Dot(n,I)/N);                              %[rad]
if (n(2) < 0)
    RAAN=2*pi-RAAN;
end
if (i==0 && message == 1)
    disp('WARNING:  RAAN Undefined.')
end

%%  Find the argument of perigee, omega:
omega=acos(Dot(n,e)/(N*e_mag));                     %[rad]
if (e(3) < 0)
    omega=-omega;
end
if (i==0 && message == 1)
    disp('WARNING:  Omega Undefined.')
end


%%  Calculate the true anomoly at epoch, nu:
nu0=acos(dot(e,r)/(e_mag*R));                       %[rad]
if (dot(r,v) < 0)
    nu0=-nu0;
end
if (nu0==0 && message == 1)
    disp('Note:  Object is Presently at Periapsis.')
end

%%  Calcualte the mean anamoly, M:
E=acos((e_mag+cos(nu0))/(1+e_mag*cos(nu0)));
xm=E-(e_mag*sin(E));
if (xm < 0)
    xm=2*pi+xm;
end

%%  Calculate the mean motion, n:
p=H*H/mu;
A=p/(1-e_mag*e_mag);
period=2.*pi*sqrt(A*A*A/mu);
xn=86400./period;

end