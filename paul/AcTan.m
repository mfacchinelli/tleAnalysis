function [X] = AcTan(SINX,COSX)
%AcTan Four-quadrant arctan function
if (COSX == 0)
    if (SINX > 0)
        X = 0.5*pi;
        return;
    else
        X = 1.5*pi;
        return;
    end
else
    if (COSX > 0)
        if (SINX > 0)
            X = atan(SINX/COSX);
            return;
        else
            X = 2*pi+atan(SINX/COSX);
            return;
        end
    else
        X = pi+atan(SINX/COSX);
    end
end
end