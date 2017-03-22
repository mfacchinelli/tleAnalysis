function [v3] = Cross(v1,v2)
%Cross Produces cross product of v1 and v2, and returns in v3
    v3(1)=v1(2)*v2(3)-v1(3)*v2(2);
	v3(2)=v1(3)*v2(1)-v1(1)*v2(3);
	v3(3)=v1(1)*v2(2)-v1(2)*v2(1);
    v3(4)=Magnitude(v3);
end