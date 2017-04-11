%  MATLAB Function < settings >
% 
%  Purpose:	define settings globally using a GUI
%  Input:
%   - N/A
%  Output:
%   - N/A

function options = settings()

%...Warn of possible incompatibility with old versions
vers = version;
year = str2double(vers(1,end-5:end-2));
if year < 2017
    if vers(end-5:end-1) ~= '2016b'
        waitfor(warndlg({'This version of MATLAB is not up-to-date.';'There might be compatibility issues.'},'Version Warning'))
    end
end
    
%...Display welcome message
disp('Welcome! Please fill in the data in the pop-up window.')

%	Select thrust setting:
%   	false (0):  for sure satellite has no thrust
%    	true  (1):  no available information/do not know

%...Select mode
% mode = questdlg('Choose how to input settings.','Mode Selection','Select','Manual','Default','Default');
mode = 'Manual';

%...Use mode
defaultAnswer = {'32784,32787,32789','1','1','5','1.05','50','1','1'};
switch mode
    case 'Default'
        answer = defaultAnswer;
    case 'Manual'
        %...Ask for inputs
        answer = inputdlg({'NORAD identifiers:',...
                           'Usage of thrust (1/0):',...
                           'Show figures (1/0):',...
                           'Initial data to ignore (%):',...
                           'Safety factor for detection (-):',...
                           'Separation between thrust periods (day):',...
                           'Number of steps for propagation (-):',...
                           'Apply Chauvenet criterion (1/0):'},...
                          'TLE Analysis',...
                          1,...
                          defaultAnswer,'on');
    case 'Select'
        %...Select from dropdown list
        d = dir('files/');
        files = {d.name}; files(:,1:3) = [];
        [selection,~] = listdlg('PromptString','Select a file:',...
                                'SelectionMode','single',...
                                'ListString',files);
        
        %...Ask for inputs
        answer = inputdlg({'Usage of thrust (1/0):',...
                           'Show figures (1/0):',...
                           'Initial data to ignore (%):',...
                           'Safety factor for detection (-):',...
                           'Separation between thrust periods (day):',...
                           'Number of steps for propagation (-):',...
                           "Apply Chauvenet's criterion (1/0):"},...
                          'TLE Analysis',...
                          1,...
                          defaultAnswer(2:end),'on');
        
        %...Combine
        file = regexprep(files(selection),'[files/.txt]','');
        answer = [file;answer];
end
      
%...Adapt name and account for possible multiple inputs
name = string(split(answer{1},','));
for filenum = 1:size(name,1)
    filename{filenum} = ['files/',char(name(filenum,:)),'.txt'];
end

%...Save inputs in options structure array
options = struct('file',    filename,...
                 'thrust',  logical(str2double(answer{2})),...  % (see above)
                 'showfig', logical(str2double(answer{3})),...  % show figures
                 'ignore',  str2double(answer{4})/100,...       % ignore first XX percent of data
                 'factor',  str2double(answer{5}),...           % safety factor for thrust detection
                 'limit',   str2double(answer{6}),...           % limit for days of separations between maneuvers
                 'offset',  str2double(answer{7}),...           % number of steps to take between observations
                 'outlier', logical(str2double(answer{8})));	% apply Chauvenet's criterion

%...Special considerations if thrust is false
if any([options.thrust]) == false
    %...Make sure selection is intentional
    waitfor(warndlg({'You selected no thrust!';'Press OK to confirm this selection.'},'Thrust Warning'))
    
    %...Force outlier detection if satellite has no thrust
    outliers = num2cell(true(1,size(options,2)));
    [options.outlier] = outliers{:};
end

%...Load data on satellites
load('statistics/satData.mat');

%...Check if satellite is in file
for filename = name'
    try 
        satellites(char(filename));
    catch
        %...Ask for data
        answer = inputdlg({'Satellite mass (kg):',...
                           'Number of units (-):',...
                           'Deployable solar panels (T/F):'},...
                          join([filename,'Data']),...
                          1,...
                          {'NaN','NaN','NaN'},'on');
        satellites(char(filename)) = [str2double(answer{1}),str2double(answer{2}),str2double(answer{3})];

        %...Save with new data
        save('statistics/satData.mat','satellites');
    end
end