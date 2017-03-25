%  MATLAB Function < downloadTLE >
% 
%  Purpose:     download TLE from space-track.org
%  Input:
%   - options:  structure array containing:
%                   1) file:	file name to be read, to extract TLE 
%                               information
%                   2) satID:   satellite NORAD ID
%  Output:
%   - N/A

function downloadTLE(options)

%...Extract
filename = replace(options.file,'files/','');
satID = options.norID;

%...Check if file already exists
files = dir('files/*.txt');
for file = files'
    if strcmp(filename,file.name)
        present = true;
        break
    else
        present = false;
    end
end

if present == false
    %...User data
    username = input('Please enter a username for space-track.org: ','s');
    password = input('Please enter the corresponding password: ','s');

    %...Define dates
    start = '1980-01-01';
    stop = '2018-01-01';

    %...URL and links
    URL = 'https://www.space-track.org/ajaxauth/login';

    link = ['https://www.space-track.org/basicspacedata/',...
            'query/class/tle/',...
            'EPOCH/',start,'--',stop,'/NORAD_CAT_ID/',satID,'/',...
            'orderby/TLE_LINE1 ASC/format/tle'];

    post = {'identity',username,...
            'password',password,...
            'query',link};

    %...Write to file
    urlwrite(URL,['files/',filename],'Post',post,'Timeout',20);
    pause(10) % give time to download
end
