function [EPOCH,XNDT2O,XNDD6O,IEXP,BSTAR,IBEXP,XINCL,XNODEO,EO,OMEGAO,XMO,XNO] = TLE_PullApart(TLE,index)
%TLE_PullApart This function returns the needed variables from a line in a
%nice and concise form.

EPOCH = TLE.epoch(index);
XNDT2O = TLE.xndt2o(index); % [rev/day^2]
XNDD6O = TLE.xndd6o(index); % [rev/day^3]
IEXP = TLE.iexp(index);
BSTAR = TLE.bstar(index);    % [ER^-1]
IBEXP = TLE.ibexp(index);
XINCL = TLE.xincl(index);   % [deg]
XNODEO = TLE.xnodeo(index); % [deg]
EO = TLE.eo(index); % [-]
OMEGAO = TLE.omegao(index); % [deg]
XMO = TLE.xmo(index);   % [deg]
XNO = TLE.xno(index);   % [rev/day]

end

