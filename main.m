clear; close all; clc; format long g;
addpath functions/ propagation/

%...Global constants
constants()

%% Input file 

%{  
    Choose NORAD ID and file name from:
        Amateur Radio   '14129'         'amateur'
        CryoSat-2       '36508'         'cryosat'       
        COSMOS Debris   '34393'         'debris'        
        Delfi C3        '32789'         'delfic3'       
        ENVISAT         '27386'         'envisat'       
        GOCE            '34602'         'goce'          
        GOES-4          '11964'         'goes'          
        BIIR-2          '24876'         'gps'           
        GRACE-2         '27392'         'grace'         
        Iridium 73      '25346'         'iridium'       
        LAGEOS-1        '08820'         'lageos'        
        METEOR 2-06     '11962'         'meteor'        
        NOAA 06         '11416'         'noaa'          
        DOVE-2          '39132'         'planet'        
        ISS             '25544'         'zarya'      
    Or insert a custom one.
%}

norID = ''; % NORAD ID
file = 'delfic3'; % file name

%% Settings

%{
    Select thrust setting:
        false:  for sure satellite has no thrust
        true:   no available information/do not know
%}
options = struct('norID',   norID,...                   % NORAD ID
                 'file',    ['files/',file,'.txt'],...  % convert file name
                 'thrust',  true,...                    % (see above)
                 'showfig', false,...                   % show figures
                 'ignore',  0.01,...                    % ignore first XX percent of data
                 'factor',  1.5,...                     % safety factor for thrust detection
                 'limit',   50,...                      % limit for days of separations between maneuvers
                 'offset',  1);

%...Make sure selection is intentional
if options.thrust == false
    warning('You selected no thrust!')
    input(['Press enter to confirm that this spacecraft has no thrust.',newline])
end

%...Clean up
clear norID file

%% Decode TLE

%...Decode
data = readTLE(options);
keplerTLE = data.orbit;

%% Thrust detection

keplerProp = propagateTLE(options,data);
options.ID = data.ID;
% thrustPeriods = thrustTLE(kepler,options);

%% Test

k = options.offset;
for i = 1:size(keplerProp,2)-2
    subplot(3,2,i)
    plot(keplerProp(:,1),keplerProp(:,i+1)-keplerTLE((k+1):k:end,i+1))
    xlim([keplerProp(1,1),keplerProp(end,1)])
    grid on
    set(gca,'FontSize',13)
end

mean(keplerProp(:,2)-keplerTLE((k+1):k:end,2))
std(keplerProp(:,2)-keplerTLE((k+1):k:end,2))
max(keplerProp(:,2)-keplerTLE((k+1):k:end,2))
min(keplerProp(:,2)-keplerTLE((k+1):k:end,2))

%% End

%...Inform user of completion
disp([newline,'Terminated'])