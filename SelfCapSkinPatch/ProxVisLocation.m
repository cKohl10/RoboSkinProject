
%% ProxVis
% Displays the real time location prediction of a skin patch of n proximity sensors
clear; close all; clc;

% Parameters
    n = 4;
    skinObj = serialport("COM5",9600);
    skinObj.UserData = struct("Data",[],"Time",[], "isTouched", []);
    threshold = 100;

%Retrieving the neural network
    load("CurrentNet.mat");

%Read in data real time
    f = figure();
    ylabel("Sensed Capacitance");
    xlabel("Sensor Number");
    title("Skin Capacitance");
    p = scatter(1,1, 100, 'red', 'filled');
    p.XDataSource = 'locX';
    p.YDataSource = 'locY';
    ylim([1,14]);
    xlim([1,14]);
    title("Touch Location Visualizer");

    while true
        readSkin(skinObj, threshold);
        figure(f);
        data = skinObj.UserData.Data';
        if isequal(size(data), [4,1]) 
            output = net(data);
%             locX = output(2);
%             locY = output(1);
%             refreshdata;
            scatter(output(2), -output(1), 50, 'red', 'filled');
            ylim([-14,1]);
            xlim([1,14]);
            title("Touch Location Visualizer");
            drawnow;
        end
    end


% Reading in the data 
function readSkin(skinObj, threshold)
    data = readline(skinObj);
    seperatedData = split(data, ',');
    for i = 1:length(seperatedData) - 1
        val = str2double(seperatedData(i));
        if ~isnan(val)
            skinObj.UserData.Data(i) = val;
            skinObj.UserData.isTouched(i) = val>threshold;
        end
    end
    skinObj.UserData.Time = str2double(seperatedData(end));
end