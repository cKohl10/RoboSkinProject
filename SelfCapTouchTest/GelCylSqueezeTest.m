%Used for analyzing the capacitive sensor data found for 8M
%Test data is of the gel cylinder, original ecoflex test
clc; close all; clear;

%Loading in the data:
%Figure 1:
% Test that was recorded on video:
dataRaw{1} = readmatrix("Data/GelCyl_8M_Squeeze",'Delimiter',',');

%Figure 2: Five touches made for each test
% Test lightly touching surface of ecoflex with one finger
dataRaw{2} = readmatrix("Data/GelCyl_8M_LightTouch",'Delimiter',',');

% Test squeezing ecoflex with one finger 
dataRaw{4} = readmatrix("Data/GelCyl_8M_NoContact2OneFingerSqueeze",'Delimiter',',');

% Test lightly touching the surface with two fingers
dataRaw{3} = readmatrix("Data/GelCyl_8M_TwoFingerLightTouch_3",'Delimiter',',');

% Test squeezing ecoflex with two fingers
dataRaw{5} = readmatrix("Data/GelCyl_8M_TwoFingerSqueeze_2",'Delimiter',',');

yMax = 0;
for i = 1:5
    data{i} = cleanup(dataRaw{i});
    yMaxTemp = max(data{i}(:,1));
    if yMaxTemp > yMax
        yMax = yMaxTemp;
    end
end


f = figure();
hold on;
grid on;
ylabel("Sensed Capacitance (Arbitrary Units)");
xlabel("Time (s)");
plotData = data{1};
plot(plotData(:,2)./1000, plotData(:,1), 'LineWidth', 2);
%xlim([0,30000])
title("EcoFlex 0035 Squeeze Proximity Sensing");
%legend(["NoTouch OFF", "OneTouch OFF", "NoTouch ON", "OneTouch ON", "NoTouch Moving", "OneTouch Moving"]);

% Figure two
figure();
hold on;
grid on;
titles = ["Light Touch on Surface of Gel", "Squeezing Gel"];
for i = 1:2
    subplot(2,1,i);
    hold on;
    grid on;
    plotData = data{i*2};
    plot(plotData(:,2)./1000, plotData(:,1), 'LineWidth', 2);
    plotData = data{i*2+1};
    plot(plotData(:,2)./1000, plotData(:,1), 'LineWidth', 2);
    ylabel("Sensed Capacitance (Arbitrary Units)");
    xlabel("Time (s)");
    title(titles(i));
    legend(["One Finger", "Two Fingers"]);
    ylim([0,yMax]);
end



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