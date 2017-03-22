function [TLE] = ReadTLE(filename)
%ReadTLE This function reads all TLE data for a given filename.
Data = textread(filename, '%s', 'delimiter', '');

empty_TLE_vector = zeros(size(Data,1)/2,1);
TLE.catnum = empty_TLE_vector;
TLE.epoch = empty_TLE_vector;
TLE.epoch_jd = empty_TLE_vector;
TLE.xndt2o = empty_TLE_vector;
TLE.xndd6o = empty_TLE_vector;
TLE.iexp = empty_TLE_vector;
TLE.bstar = empty_TLE_vector;
TLE.ibexp = empty_TLE_vector;
TLE.xincl = empty_TLE_vector;
TLE.xnodeo = empty_TLE_vector;
TLE.eo = empty_TLE_vector;
TLE.omegao = empty_TLE_vector;
TLE.xmo = empty_TLE_vector;
TLE.xno = empty_TLE_vector;

%% Extract Line 1 Data
index = 1;
for count = 1:2:size(Data,1)
    RowData = Data{count};
    
    TLE.catnum(index,1) = str2double(RowData(3:7));
    TLE.epoch(index,1) = str2double(RowData(19:32));
    TLE.epoch_jd(index,1) = TLE_Epoch(TLE.epoch(index));
    TLE.xndt2o(index,1) = str2double(RowData(34:43));
    TLE.xndd6o(index,1) = str2double(RowData(45:50))*1.E-5;
    TLE.iexp(index,1) = str2double(RowData(51:52));
    TLE.bstar(index,1) = str2double(RowData(54:59))*1.E-5;
    TLE.ibexp(index,1) = str2double(RowData(60:61));
    
    index = index + 1;
end

%% Extract Line 2 Data
index = 1;
for count = 2:2:size(Data,1)
    RowData = Data{count};
    
    TLE.xincl(index,1) = str2double(RowData(9:16)); % Inclination [deg]
    TLE.xnodeo(index,1) = str2double(RowData(18:25));   % RAAN [deg]
    TLE.eo(index,1) = str2double(RowData(27:33))*1.E-7;    % Eccen [-]
    TLE.omegao(index,1) = str2double(RowData(35:42));   % Arg of Perigee [deg]
    TLE.xmo(index,1) = str2double(RowData(44:51));  % Mean Anomoly [deg]
    TLE.xno(index,1) = str2double(RowData(53:63));  % Mean Notion [rev/day]
    
    index = index + 1;
end

%% Remove Consectuative Duplicate Entries (For whatever reason sometimes these exist)
for index = size(TLE.epoch_jd):-1:2
    if isequal(TLE.epoch_jd(index),TLE.epoch_jd(index-1))
%         fprintf('Duplicate Entry Removed for Satellite %d at Index: %d.\n',TLE.catnum(index),index);
        TLE.catnum(index) = [];
        TLE.epoch(index) = [];
        TLE.epoch_jd(index) = [];
        TLE.xndt2o(index) = [];
        TLE.xndd6o(index) = [];
        TLE.iexp(index) = [];
        TLE.bstar(index) = [];
        TLE.ibexp(index) = [];
        TLE.xincl(index) = [];
        TLE.xnodeo(index) = [];
        TLE.eo(index) = [];
        TLE.omegao(index) = [];
        TLE.xmo(index) = [];
        TLE.xno(index) = [];
        pause(0.1);
    end
end
clear index;

end

