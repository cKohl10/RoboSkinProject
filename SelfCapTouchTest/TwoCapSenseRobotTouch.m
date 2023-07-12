%Used for analyzing the capacitive sensor data found for 8M with two
%capacitance sensors
clc; close all; clear;

%dataRaw{1} = readmatrix("Data/ArmTest_8M_NoTouch_OFF_2Caps",'Delimiter',',');
%dataRaw{2} = readmatrix("Data/ArmTest_8M_OneTouch_OFF_2Caps",'Delimiter',',');
dataRaw{3} = readmatrix("Data/ArmTest_8M_NoTouch_ON_2Caps",'Delimiter',',');
dataRaw{4} = readmatrix("Data/ArmTest_8M_OneTouch_ON_2Caps",'Delimiter',',');
dataRaw{5} = readmatrix("Data/ArmTest_8M_NoTouch_Moving_2Caps",'Delimiter',',');
dataRaw{6} = readmatrix("Data/ArmTest_8M_OneTouch_Moving_2Caps",'Delimiter',',');

for i = 3:6
    data{i} = cleanup(dataRaw{i});
end

titles = ["ON No Touch", "On One Touch", "Moving No Touch", "Moving Multi Touch"];

f = figure();
hold on;
ylabel("Sensed Capacitance (Arbitrary Units)");
xlabel("Time (ms)");
sgtitle("Proximity Sensing - Two Nearby Capacitors");
for j = 3:6
        subplot(2,2,j-2);
        hold on;
        plotData = data{j};
        plot(plotData(:,3)./1000, plotData(:,1));
        plot(plotData(:,3)./1000, plotData(:,2));
        ylabel("Sensed Capacitance (Arbitrary Units)");
        xlabel("Time (s)");
        xlim([0,30])
        title(titles(j-2))
        legend(["Sensor 1 (Right)", "Sensor 2 (Left)"]);
end
%legend(["NoTouch OFF", "OneTouch OFF", "NoTouch ON", "OneTouch ON", "NoTouch Moving", "OneTouch Moving"]);


function dataNew = cleanup(data)
    %Finds the starting point of data
    dataClean = rmmissing(data(:,1:3));
    start = 1;
    for i = 1:length(dataClean)
        if dataClean(i,2) < 150
            start = i;
            break;
        end
    end
    dataNew = dataClean(start:end,:);
end