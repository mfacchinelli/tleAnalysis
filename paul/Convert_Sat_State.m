function [pos,vel] = Convert_Sat_State(pos,vel)
%Convert_Sat_State Converts the satellite's position and velocity vectors 
%from normalized values to km and km/sec
    global XKMPER XMNPDA AE;
    
	pos = Scale_Vector(XKMPER/AE, pos);
    vel = Scale_Vector(XKMPER/AE*XMNPDA/86400., vel);
end