%  MATLAB Function < propagateTLE >
% 
%  Purpose:	transformation from Cartesian components to Keplerian elements
%           observation
%  Input:
%   - cart:	array containing Cartesian coordinates in SI units with order:
%           [t,x,y,z,dxdt,dydt,dzdt]
%  Output:
%   - kepl: array containing Keplerian elements in SI units with order:
%           [t,a,e,i,O,o,TA,MA]

function [kepl] = cart2kepl(cart)

%...Global constants
global mu

%...Time
t = cart(:,1);
n = length(t); % number of epochs

%...Position
x = cart(:,2);
y = cart(:,3);
z = cart(:,4);

%...Velocity
dxdt = cart(:,5);
dydt = cart(:,6);
dzdt = cart(:,7);

%...Create intermediate variables
pos = [x y z]; % cartesian position array
vel = [dxdt dydt dzdt]; % cartesian velocity array
r = sqrt(x.^2+y.^2+z.^2); % magnitude radial distance
V = sqrt(dxdt.^2+dydt.^2+dzdt.^2); % magnitude velocity

hvec = cross(pos,vel); % angular momentum vectors at each epoch
h = sqrt(hvec(:,1).^2+hvec(:,2).^2+hvec(:,3).^2); % total angular momentum at each epoch

dankmemes = zeros(n,3);
dankmemes(:,3) = ones(n,1);

Nvec = cross(dankmemes,hvec);
N = sqrt(Nvec(:,1).^2+Nvec(:,2).^2+Nvec(:,3).^2);

%...Compute Keplerian elements
a = 1./(2./r-V.^2./mu);  % [m]   semi-major axis          

evec = cross(vel,hvec)/mu-pos./r; % eccentricity vectors at each epoch
e = sqrt(evec(:,1).^2+evec(:,2).^2+evec(:,3).^2);   % [-]   eccentricity at each epoch

i = wrapTo2Pi(acos(hvec(:,3)./h));  % [rad] inclination

Nxy = sqrt(Nvec(:,1).^2+Nvec(:,2).^2);
O = wrapTo2Pi(atan2(Nvec(:,2)./Nxy,Nvec(:,1)./Nxy));    % [rad] right ascesion of the ascending node

par1 = sum(cross(Nvec./N,evec).*hvec,2);
par2 = sum(cross(evec,pos).*hvec,2);

sign1 = sign(par1);
sign2 = sign(par2);

o = wrapTo2Pi(sign1.*acos(sum((evec./e).*(Nvec./N),2)));    % [rad] argument of pericenter
TA = wrapTo2Pi(sign2.*acos(sum((pos./r).*(evec./e),2)));    % [rad] true anomaly

EA = wrapTo2Pi(2*atan(sqrt((1-e)./(1+e)).*tan(TA/2)));  % [rad] eccentric anomaly

MA = wrapTo2Pi(EA-e.*sin(EA));                          % [rad] mean anomaly

%...Array of Keplerian elements
kepl = horzcat(t,a,e,i,O,o,TA,MA);