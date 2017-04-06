%  MATLAB Function < downloadTLE >
% 
%  Purpose:     download TLE from space-track.org; originally created by
%               Paul Schattenberg and adapted by the tleAnalysis team
%  Input:
%   - file:     file name to be corrected, containing TLE information
%  Output:
%   - N/A

function downloadTLE(file)

%...Extract
filename = replace(file,'files/','');

%...Check if file already exists
present = false;
files = dir('files/*.txt');
for file = files'
    if strcmp(filename,file.name)
        present = true;
        break
    else
        present = false;
    end
end

%...Remove extension
filename = replace(filename,'.txt','');

if present == false
    %...User data
    userdata = 'statistics/credentials.txt';
    fileID = fopen(userdata,'r+');
    data = textscan(fileID,'%s\n','CommentStyle','#');
        
    if isempty(data{1})
        %...Ask for credentials
        answer = inputdlg({'Username:',...
                           'Password:'},...
                          'space-track.org',...
                          1,...
                          {'',''},'on');
                      
        %...Extract credentials
        username = answer{1};
        password = answer{2};
        
        %...Store credentials
        for i = 1:2
            fprintf(fileID,'%s\n',answer{i});
        end
    else
        %...Extract credentials
        username = data{1}(1);
        password = data{1}(2);
    end
    fclose(fileID);

    %...Inform user on progress
     disp([newline,'Downloading, please wait...',newline])

    %...Define dates
    start = '1980-01-01';
    stop = '2012-12-01'; % reduce to avoid corrupted data points

    %...URL and links
    URL = 'https://www.space-track.org/ajaxauth/login';

    link = ['https://www.space-track.org/basicspacedata/',...
            'query/class/tle/',...
            'EPOCH/',start,'--',stop,'/NORAD_CAT_ID/',filename,'/',...
            'orderby/TLE_LINE1 ASC/format/tle'];

    post = {'identity',username,...
            'password',password,...
            'query',link};

    %...Write to file
    urlwrite(URL,['files/',filename,'.txt'],'Post',post,'Timeout',20);
    pause(5) % give time to download
end
