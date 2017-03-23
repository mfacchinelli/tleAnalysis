% startdate = '2000-01-01';
% enddate = '2017-09-03';

function downloadTLE(satID,filename,date,user)

date.start = start;
date.stop = stop;
user.name = username;
user.code = password;

URL = 'https://www.space-track.org/ajaxauth/login';

link = ['https://www.space-track.org/basicspacedata/',...
        'query/class/tle/',...
        'EPOCH/',start,'--',stop,'/NORAD_CAT_ID/',num2str(satID),'/',...
        'orderby/TLE_LINE1 ASC/format/tle'];

post = {'identity',username,...
        'password',password,...
        'query',link};

urlwrite(URL,filename,'Post',post,'Timeout',20);
% pause(5);