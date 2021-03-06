%  MATLAB Function < statTLE >
%
%  Purpose:     collect statistical information on TLEs of satellites with
%               no thrust, and output data for thrust detection
%  Input:
%   - residuals:    array containing changes in Keplerian elements for each
%                   time step
%   - options:      structure array containing:
%                       1) ID:      satellite identifier
%                       2) thrust:  presence of propulsion subsystem on
%                                   satellite
%                       3) factor:      safety factor for thrust detection
%  Output:
%   - extract:  structure array containing maximum and minimum limitation
%               values for each Keplerian element, for thrust detection

function extract = statTLE(residuals,options)

%...Set textfile name
filename = 'statistics/stat.txt';

%...Extract data
da = residuals{1};
de = residuals{2};
di = residuals{3};
dO = residuals{4};
CTP = residuals{5};

%...Extract options
satID = options.ID;
thrust = options.thrust;
factor = options.factor;

%...Open file
fileID = fopen(filename,'r+');
data = textscan(fileID,'%s\t%f\t%f\t%f\t%f\t%f\n','CommentStyle','#');

%...Add information only if no thrust
if thrust == false
    ids = repmat(satID,4,1);
    means = [mean(da);mean(de);mean(di);mean(dO)];
    stds = [std(da);std(de);std(di);std(dO)];
    maxs = [max(da);max(de);max(di);max(dO)];
    mins = [min(da);min(de);min(di);min(dO)];
    ctps = CTP*ones(4,1);

    %...Check if satellite is already in file
    if any(data{1}==satID) == false
        %...Append to file
        saveData = [ids,means,stds,maxs,mins,ctps];
        for i = 1:4 
            fprintf(fileID,'%s\t%+.6e\t%+.6e\t%+.6e\t%+.6e\t%+.6e\n',saveData(i,:));
        end
    end
end
fclose(fileID);

%...Collect data
fileID = fopen(filename,'r');
data = textscan(fileID,'%s\t%f\t%f\t%f\t%f\t%f\n','CommentStyle','#');
fclose(fileID);

%...Analyze data
max_a = max(data{4}(1:4:end))*factor;
min_a = abs(min(data{5}(1:4:end)))*factor;
max_e = max(data{4}(2:4:end))*factor;
min_e = abs(min(data{5}(2:4:end)))*factor;
max_i = max(data{4}(3:4:end))*factor;
min_i = abs(min(data{5}(3:4:end)))*factor;
max_O = max(data{4}(4:4:end))*factor;
min_O = abs(min(data{5}(4:4:end)))*factor;
max_CTP = max(data{6})/factor;

%...Struct of extraced data
extract = struct('a',[max_a,min_a],'e',[max_e,min_e],'i',[max_i,min_i],'O',[max_O,min_O],'CTP',max_CTP);