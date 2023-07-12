%Used for analyzing the capacitive sensor data found for 1M, 2M, 4M, and 8M
clc; close all; clear;

dataRaw{1} = readmatrix("Data/CapSense_1M",'Delimiter',',');
dataRaw{2} = readmatrix("Data/CapSense_2M",'Delimiter',',');
dataRaw{3} = readmatrix("Data/CapSense_4M",'Delimiter',',');
dataRaw{4} = readmatrix("Data/CapSense_8M",'Delimiter',',');

for i = 1:4
    data{i} = cleanup(dataRaw{i});
end

f = figure();
hold on;
ylabel("Sensed Capacitance (Arbitrary Units)");
xlabel("Time (ms)");
title("Proximity Sensing");
for i = 1:4
    plotData = data{i};
    plot(plotData(:,2), plotData(:,1));
end
legend(["1M", "2M", "4M", "8M"]);


function dataNew = cleanup(data)
    %Finds the starting point of data
    dataClean = rmmissing(data(:,1:2));
    start = 1;
    for i = 1:length(dataClean)
        if dataClean(i,2) < 10
            start = i;
            break;
        end
    end
    dataNew = dataClean(start:end,:);
end