%  MATLAB Function < mergeArrays >
%
%  Purpose:     merge two arrays into one at every second element
%  Input:
%   - a:        first array
%   - b:        second array
% Output:
%   - merged:   array containing elements of a and b in an alternating
%               fashion

function merged = mergeArrays(a,b)

merged = NaN(size(a,1) + size(b,1),size(a,2));

merged(1:2:end,:) = a;
merged(2:2:end,:) = b;