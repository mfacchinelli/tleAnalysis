%  Purpose:     collect statistical information on TLEs of satellites with
%               no thrust, and output data for thrust detection
%  Input:
%   - derivatives:  
%   - options:      
%  Output:
%   - N/A

function statTLE(derivatives,options)

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
    if any(data{1}~=satID)
        %...Append to file
        saveData = [ids,means,stds,maxs,mins];
        for i = 1:5
            fprintf(fileID,'%s\t%+.6e\t%+.6e\t%+.6e\t%+.6e\n',saveData(i,:));
        end
    end
end

%...Collect data
data = textscan(fileID,'%s\t%f\t%f\t%f\t%f\n','CommentStyle','#');
fclose(fileID);

%...Analyze data
max_a = max()
