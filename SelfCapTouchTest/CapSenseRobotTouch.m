%Used for analyzing the capacitive sensor data found for 8M
clc; close all; clear;

dataRaw{1} = readmatrix("Data/ArmTest_8M_NoTouch_OFF",'Delimiter',',');
dataRaw{2} = readmatrix("Data/ArmTest_8M_OneTouch_OFF",'Delimiter',',');
dataRaw{3} = readmatrix("Data/ArmTest_8M_NoTouch_ON",'Delimiter',',');
dataRaw{4} = readmatrix("Data/ArmTest_8M_OneTouch_ON",'Delimiter',',');
dataRaw{5} = readmatrix("Data/ArmTest_8M_NoTouch_Moving",'Delimiter',',');
dataRaw{6} = readmatrix("Data/ArmTest_8M_OneTouch_Moving",'Delimiter',',');

for i = 1:6
    data{i} = cleanup(dataRaw{i});
end

titles = ["OFF", "ON", "Moving"];

f = figure();
hold on;
ylabel("Sensed Capacitance (Arbitrary Units)");
xlabel("Time (ms)");
sgtitle("Proximity Sensing");
for j = 1:3
        subplot(3,1,j);
        hold on;
        plotData = data{j*2 -1};
        plot(plotData(:,2), plotData(:,1));
        plotData = data{j*2};
        plot(plotData(:,2), plotData(:,1));
        ylabel("Capacitance (Arbitrary Units)");
        xlabel("Time (ms)");
        xlim([0,30000])
        title(titles(j))
        legend(["No Touch", "One Touch"]);
end
%legend(["NoTouch OFF", "OneTouch OFF", "NoTouch ON", "OneTouch ON", "NoTouch Moving", "OneTouch Moving"]);


function dataNew = cleanup(data)
    %Finds the starting point of data
    dataClean = rmmissing(data(:,1:2));
    start = 1;
    for i = 1:length(dataClean)
        if dataClean(i,2) < 140
            start = i;
            break;
        end
    end
    dataNew = dataClean(start:end,:);
end