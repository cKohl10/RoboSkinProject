%% ProxVis
% Displays the real time data of n proximity sensors
clear; close all; clc;

% Parameters
    param = getParams();
    n = param.numSensors;
    skinObj = serialport(param.serialPort,param.baudRate);
    skinObj.UserData = struct("Data",[],"Time",[], "isTouched", []);
    threshold = param.threshold;
    noiseProfile = calibrateSkin(skinObj);

%Read in data real time
    f = figure();
    subplot(1,2,1);
    b = bar(1:n, 1:n);
    ylabel("Sensor Contact");
    xlabel("Sensor Number");
    title("Direct Touch");
    b.XDataSource = 'x2';
    b.YDataSource = 'skinObj.UserData.isTouched';
    ylim([0,1]);
    sgtitle("2x2 Skin Patch Proximity Sensing");
    subplot(1,2,2);
    p = bar(1:n, 1:n);
    ylabel("Sensed Capacitance");
    xlabel("Sensor Number");
    title("Skin Capacitance");
    p.XDataSource = 'x2';
    p.YDataSource = 'skinObj.UserData.Data';
    ylimit = 1;

    while true
        flush(skinObj);
        readSkin(skinObj, threshold, noiseProfile);
        readSkin(skinObj, threshold, noiseProfile);
        figure(f);
        data = skinObj.UserData.Data;
        x2 = 1:length(data);
        ylimitTemp = max(data);
        if ylimitTemp > ylimit
            ylimit = ylimitTemp;
        else 
            ylimit = ylimit/(1+ylimit*0.00005);
        end
        ylim([0,ylimit]);
        refreshdata;
    end


% Reading in the data 
function readSkin(skinObj, threshold, noiseProfile)
    data = readline(skinObj);
    seperatedData = split(data, ',');
    for i = 1:length(seperatedData)
        val = str2double(seperatedData(i));
        if ~isnan(val)
            skinObj.UserData.Data(i) = val - noiseProfile(i);
            skinObj.UserData.isTouched(i) = val - noiseProfile(i)>threshold;
        end
    end
    %skinObj.UserData.Time = str2double(seperatedData(end));
end