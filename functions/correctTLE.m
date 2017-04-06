%  MATLAB Function < correctTLE >
%
%  Purpose:     correct the TLE information from element overlap
%  Input:
%   - file:     file name to be corrected, containing TLE information
%  Output:
%   - N/A

function correctTLE(file)

%...Read lines
fileID = fopen(file,'r');
data = fscanf(fileID,'%c');
fclose(fileID);

%...Check for first time
if ~strcmp(data(1),'#')
    %...Reshape and correct for element overlap
    data = split(string(data));
    if data(end,1) == '', data = data(1:end-1,1); end
    if mod(size(data,1),9) ~= 0 || size(char(data(end)),2) > 6
        warning off backtrace
        warning('Fixing bugs in text file. This may take several seconds.');
        warning on backtrace
        i = 1; % index to run through lines
        change = 0; % number of changes done
        limit = size(char(data(18:18:end,:)),1); % limiting number for check
        while i < limit
            try
                if size(char(data(i*18-1,:)),2) ~= 11
                    value17 = char(data(i*18-1,:));
                    data(i*18-1,:) = string(value17(1:11));
                    data = vertcat(data,zeros(1));
                    data(i*18+1:end,:) = data(i*18:end-1,:);
                    data(i*18,:) = string(value17(12:end));
                    change = change+1;
                    if mod(change,9) == 0, limit = limit+1; end
                end
            end
            i = i+1;
        end
    end
    if mod(size(data,1),9) ~= 0, error('Something went wrong while correcting the TLE file.'); end
    data = reshape(data,9,[]);

    %...Add comment
    data = horzcat(repmat('#',9,1),data);

    %...Write to file
    fileID = fopen(file,'w');
    fprintf(fileID,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n',data);
    fclose(fileID);
end