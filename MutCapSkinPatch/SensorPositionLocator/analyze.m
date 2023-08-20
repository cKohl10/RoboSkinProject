% Used to produce graphs for the paper

clc; close all; clear;

set1 = ["Data/SkinPatch1x6_100_2.mat", "SkinTruePositions/Blue&WhiteVariedPatch.mat"];
set2 = ["Data/SkinPatch1x6_52_2.mat", "SkinTruePositions/BlueLinear Patch.mat", ];

%Change this for different data sets
set = set1;

load(set(1));
load(set(2));

%Ease of use
sensorNum = 11;
ppi = 10;
X = SkinDataSet.posLinAvgReal(1,:);
Y = SkinDataSet.posLinAvgReal(2,:);
Z = SkinDataSet.dataAvgsLin(sensorNum, :);
realSensorPos = trueSet.posReal(:, sensorNum);

%%%%%% Surface Plot %%%%%%%%%
    %Interpolated data
    F = scatteredInterpolant(X', Y', Z');
    F.Method = 'natural';
    newX = (0:(1/ppi):SkinDataSet.lengthIn);
    newY = (SkinDataSet.widthIn:-(1/ppi):0);
    [Xgrid,Ygrid] = meshgrid(newX, newY); %Make new locations to interpolate at
    xlin = Xgrid(:); %Flatten the matrix
    ylin = Ygrid(:);
    DataInterp = F([xlin, ylin]); %evaluate interpolation
    
    %For testing interpolation
    %save("testing.mat", "DataInterp", "F", "newX", "newY", "X", "Y");
    
    %Organizing data into heat map
    currP = 1;
    for x = 1:length(newX)
        for y = 1:length(newY)
            Zgrid(y,x) = DataInterp(currP);
            currP = currP + 1;
        end
    end
    
    f1 = figure();
    hold on;
    surfc(Xgrid,Ygrid,Zgrid/100);
    axis equal;
    hold off;

%%%%% Asymptotic relationship graph %%%%%%%
    relDistX = abs(X - realSensorPos(1));
    relDistY = abs(Y - realSensorPos(2));
    relDist = sqrt(relDistX.^2 + relDistY.^2)*2.54; %cm

    xFit = linspace(min(relDist), max(relDist), 1000);
    p = polyfit(relDist, Z, 6);
    zFit = polyval(p, xFit);

    f2 = figure();
    hold on;
    grid on;
    scatter(relDist, Z, 40, 'filled');
    plot(xFit, zFit, 'LineWidth', 2);
    legend(["Experimental Data", "Line of Best Fit"]);
    title("Sensor " + sensorNum +" Reading vs Surface Distance");
    xlabel("Point Distance from Sensor True Position (cm)");
    ylabel("Sensor Value (Arbitrary Units)");
    hold off;

%%%%%% Error Table %%%%%%%
    load(set(3))

    f3 = figure();

    