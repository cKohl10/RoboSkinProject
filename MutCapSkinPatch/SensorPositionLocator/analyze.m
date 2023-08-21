% Used to produce graphs for the paper

clc; close all; clear;

set1 = ["Data/SkinPatch1x6_100_2.mat", "SkinTruePositions/Blue&WhiteVariedPatch.mat", "Data/SkinPatch1x6_100_2ErrorCompare.mat"];
set2 = ["Data/SkinPatch1x6_52_2.mat", "SkinTruePositions/BlueLinearPatch.mat", "Data/SkinPatch1x6_52_2ErrorCompare.mat"];

%Change this for different data sets
set = set1;

load(set(1));
load(set(2));

%Ease of use
sensorNum = 14;
ppi = 100;
X = SkinDataSet.posLinAvgReal(1,:)*2.54;
Y = SkinDataSet.posLinAvgReal(2,:)*2.54;
Z = SkinDataSet.dataAvgsLin(sensorNum, :)./20;
realSensorPos = trueSet.posReal(:, sensorNum);

%%%%%% Surface Plot %%%%%%%%%
    %Interpolated data
    F = scatteredInterpolant(X', Y', Z');
    F.Method = 'natural';
    newX = (0:(1/ppi):SkinDataSet.lengthIn*2.54);
    newY = (SkinDataSet.widthIn*2.54:-(1/ppi):0);
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
    cm = hot(100);
    colormap(f1, cm(1:70,:));
    sc = surfc(Xgrid,Ygrid,Zgrid, 'EdgeColor','none');
    s = scatter3(X,Y,Z,50,'cyan', 'filled', 'MarkerEdgeColor','k');
    [M,c] = contour3(Xgrid, Ygrid, Zgrid, [0.6*max(Z),0.6*max(Z)], 'EdgeColor', 'green', 'LineWidth', 3);
    title("Interpolated Sensor " + sensorNum + " Data");
    xlabel("Length (cm)");
    ylabel("Width (cm)");
    zlabel("Sensor Value (Arbitrary Units)");
    legend([s, c], "Experimental Values", "Threshold");
    axis equal;
    grid on;
    hold off;

%%%%% Asymptotic relationship graph %%%%%%%
    relDistX = abs(X - realSensorPos(1)*2.54);
    relDistY = abs(Y - realSensorPos(2)*2.54);
    relDist = sqrt(relDistX.^2 + relDistY.^2); %cm

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
    h = heatmap(errorObj.error*2.54);
    colormap(h,copper);
    colormap(h, flipud(colormap(h)));
    h.Title = "Total Prediction Error (cm)";
    h.XData = errorObj.threshold(1,:)*100;
    h.YData = ceil((errorObj.ppi(:,1)'/ 2.54)/2)*2;    
    h.XLabel = "Weighted Area Threshold (% Max)";
    h.YLabel = "Interpolated Pixels Per cm";

%%%%% Finger Snapshot %%%%%%
    f4 = figure();
    hold on;
    imshow(SkinDataSet.dataRaw(30).img);
    title("Data Log Snaphsot");
