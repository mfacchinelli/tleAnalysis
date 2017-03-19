%  MATLAB Function < statTLE >
%
%  Purpose:     collect statistical information on TLEs of satellites with
%               no thrust, and output data for thrust detection
%  Input:
%   - derivatives:  array containing changes in Keplerian elements for each
%                   time step
%   - options:      structure array containing:
%                       1) ID:      satellite identifier
%                       2) thrust:  presence of propulsion subsystem on
%                                   satellite
%  Output:
%   - extract:  structure array containing maximum and minimum limitation
%               values for each Keplerian element, for thrust detection

function extract = statTLE(derivatives,options)

%...Extract data
da = derivatives(:,1);
de = derivatives(:,2);
di = derivatives(:,3);
dO = derivatives(:,4);
do = derivatives(:,5);

%...Extract options
satID = options.ID;
thrust = options.thrust;

%...Open file
fileID = fopen('files/stat.txt','r+');
data = textscan(fileID,'%s\t%f\t%f\t%f\t%f\n','CommentStyle','#');

%...Add information only if no thrust
if strcmp(thrust,'no')
    ids = repmat(satID,5,1);
    means = [mean(da);mean(de);mean(di);mean(dO);mean(do)];
    stds = [std(da);std(de);std(di);std(dO);std(do)];
    maxs = [max(da);max(de);max(di);max(dO);max(do)];
    mins = [min(da);min(de);min(di);min(dO);min(do)];

    %...Check if satellite is already in file
    if ~any(data{1}==satID)
        %...Append to file
        saveData = [ids,means,stds,maxs,mins];
        for i = 1:5 
            fprintf(fileID,'%s\t%+.6e\t%+.6e\t%+.6e\t%+.6e\n',saveData(i,:));
        end
    end
end
fclose(fileID);

%...Collect data
fileID = fopen('files/stat.txt','r');
data = textscan(fileID,'%s\t%f\t%f\t%f\t%f\n','CommentStyle','#');
fclose(fileID);

%...Analyze data
max_a = max(data{4}(1:5:end));
min_a = abs(min(data{5}(1:5:end)));
max_e = max(data{4}(2:5:end));
min_e = abs(min(data{5}(2:5:end)));
max_i = max(data{4}(3:5:end));
min_i = abs(min(data{5}(3:5:end)));
max_O = max(data{4}(4:5:end));
min_O = abs(min(data{5}(4:5:end)));
max_o = max(data{4}(5:5:end));
min_o = abs(min(data{5}(5:5:end)));

%...Struct of extraced data
extract = struct('a',[max_a,min_a],'e',[max_e,min_e],'i',[max_i,min_i],'O',[max_O,min_O],'o',[max_o,min_o]);