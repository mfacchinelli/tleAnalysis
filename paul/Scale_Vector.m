function [v1] = Scale_Vector(k,v1)
%Scale_Vector Multiplies the vector v1 by the scalar k
    v1(1)=v1(1)*k;
	v1(2)=v1(2)*k;
	v1(3)=v1(3)*k;
	v1(4)=Magnitude(v1);
end