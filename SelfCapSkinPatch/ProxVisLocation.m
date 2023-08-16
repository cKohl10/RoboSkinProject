
%% ProxVis
% Displays the real time location prediction of a skin patch of n proximity sensors
clear; close all; clc;

% Parameters
    param = getParams();
    length = param.TX;
    width = param.RX;
    n = length*width;
    extra = 2; %Extra visibility outside of skin sensor range
    skinObj = serialport(param.serialPort,param.baudRate);
    skinObj.UserData = struct("Data",[],"Time",[], "isTouched", []);
    threshold = param.threshold;

%Retrieving the neural network
    load("CurrentNet.mat");

%Calibrating Sensor
    noiseProfile = calibrateSkin(skinObj);

%Read in data real time
    f = figure();
    hold on;
    axis equal;
    ylim([-length-extra,-1 + extra]);
    xlim([1-extra,width+extra]);
    set(gca,'DataAspectRatio',[1 1 1])
    title("Touch Location Visualizer");
    scat = scatter(0,0);
    %Drawing the box
    plot([1,width], [-length, -length], 'k', 'LineWidth',2);
    plot([1,width], [-1, -1], 'k', 'LineWidth',2);
    plot([1,1], [-1, -length], 'k', 'LineWidth',2);
    plot([width,width], [-1, -length], 'k', 'LineWidth',2);

    while true
        flush(skinObj);
        readSkin(skinObj, threshold, noiseProfile);
        readSkin(skinObj, threshold, noiseProfile);
        figure(f);
        hold on;
        if exist('scat', 'var'), delete(scat); end
        data = skinObj.UserData.Data';
        if isequal(size(data), [n,1]) && any(skinObj.UserData.isTouched)
            output = net(data);
            scat = scatter(output(2), -output(1), 50, 'red', 'filled');
            drawnow;
        end
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