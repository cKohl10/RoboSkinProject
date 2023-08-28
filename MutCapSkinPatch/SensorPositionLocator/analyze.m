% Used to produce graphs for the paper

clc; close all; clear;

set1 = ["Data/SkinPatch1x6_100_3.mat", "SkinTruePositions/Blue&WhiteVariedPatch.mat", "Data/SkinPatch1x6_100_3ErrorCompare.mat"];
set2 = ["Data/SkinPatch1x6_52_2.mat", "SkinTruePositions/BlueLinearPatch.mat", "Data/SkinPatch1x6_52_2ErrorCompare.mat"];

%Change this for different data sets
set = set1;

load(set(1));
load(set(2));
load(set(3));
load("Data\errorBySamples.mat");

%Ease of use
sensorNum = 14;
ppcm = 100;
zFactor = 30; %For plot visibility

X = SkinDataSet.posLinAvgReal(1,:)*2.54;
Y = SkinDataSet.posLinAvgReal(2,:)*2.54;
Z = SkinDataSet.dataAvgsLin(sensorNum, :);
realSensorPos = trueSet.posReal(:, sensorNum);

%%%%%% Surface Plot %%%%%%%%%
    %Interpolated data
    F = scatteredInterpolant(X', Y', Z');
    F.Method = 'natural';
    newX = (0:(1/ppcm):SkinDataSet.lengthIn*2.54);
    newY = (SkinDataSet.widthIn*2.54:-(1/ppcm):0);
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

    %%% Skin Sensor Object %%
    % Define the vertices of the rectangle
    zBox = -2;
    vertices = [0 0 0; 0 1 0; 6 1 0; 6 0 0; 0 0 zBox; 0 1 zBox; 6 1 zBox; 6 0 zBox] * 2.54;
    
    % Define the faces of the rectangle
    faces = [1 2 3 4; 5 6 7 8; 1 2 6 5; 1 4 8 5; 3 4 8 7; 2 3 7 6];

    
    f1 = figure();
    hold on;
    cm = hot(100);
    colormap(f1, cm(1:70,:));
    sc = surf(Xgrid,Ygrid,Zgrid, 'EdgeColor','none');
    s = scatter3(X,Y,Z,40,'c', 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 1);%, 'MarkerEdgeColor','k');
    %ps = scatter3(trueSet.posReal(1,sensorNum), trueSet.posReal(2,sensorNum)+error(2).value(1), 0, 200, 'g', 'filled', 'MarkerEdgeColor','k');
    %plot3([trueSet.posReal(1,sensorNum), trueSet.posReal(1,sensorNum)], ...
        %[trueSet.posReal(2,sensorNum)+error(2).value(1), trueSet.posReal(2,sensorNum)+error(2).value(1)],...
        %[0, 300],'Color', 'green', 'LineStyle', '-.', 'LineWidth',3);
    rs = scatter3(trueSet.posReal(1,sensorNum), trueSet.posReal(2,sensorNum), zeros(size(trueSet.posReal(2,sensorNum))), 'k', 'x', 'LineWidth', 2);
    %[M,c] = contour3(Xgrid, Ygrid, Zgrid, [0.65*max(Z),0.65*max(Z)], 'EdgeColor', 'g', 'LineWidth', 4);
    % Plot the rectangle
    patch('Faces', faces, 'Vertices', vertices, 'FaceColor', 'b', 'FaceAlpha', 0.2);
    view([-2 -4 1.5]);
    %title("Interpolated Sensor " + sensorNum + " Data");
    title("Topographic Sensor " + sensorNum + " Data");
    xlabel("Length (cm)");
    ylabel("Width (cm)");
    zlabel("Sensor Value (Arbitrary Units)");
    %legend([s, c, ps], "Experimental Values", "65% Threshold", "Prediction Location");
    legend([s, sc, rs], "Experimental Values", "Interpolated Values", "Sensor " + sensorNum + " Real Position");
    daspect([1,1,zFactor]);
    zlim([zBox-1,300]);
    grid on;
    hold off;

%%%%% Asymptotic relationship graph %%%%%%%
    relDistX = abs(X - realSensorPos(1));
    relDistY = abs(Y - realSensorPos(2));
    relDist = sqrt(relDistX.^2 + relDistY.^2); %cm
    relErr = sqrt(2)*SkinDataSet.deltaX*ones(size(relDist));

    xFit = linspace(min(relDist), max(relDist), 1000);

    p = polyfit(relDist, Z, 6);
    zFit = polyval(p, xFit);
    zErr = SkinDataSet.stdLin(sensorNum,:);

    % Expected values
    a = 160;
    b = 0;
    c = -12;
    d = 1.1;
    expectFunc = @(a,b,c,d,x) a./(b+d*x) + c;
    expectData = expectFunc(a,b,c,d,xFit);

    f2 = figure();
    hold on;
    grid on;
    plt = plot(xFit, expectData, 'LineWidth', 3);
    %errorbar(relDist, Z, zErr,zErr,relErr,relErr,'.');
    scatter(relDist,Z,40, 'filled', 'MarkerEdgeColor', 'k');
    %plot(xFit, zFit, 'LineWidth', 2);
    legend(["Ideal Relationship", "Experimental Data"]);
    title("Sensor " + sensorNum +" Reading vs Surface Distance");
    xlabel("Point Distance from Sensor True Position (cm)");
    ylabel("Sensor Value (Arbitrary Units)");
    hold off;

%%%%%% Error Table %%%%%%%


    f3 = figure();
    h = heatmap(errorObj.error*2.54);
    colormap(h,copper);
    colormap(h, flipud(colormap(h)));
    h.Title = "Prediction Standard Deviation Error (cm)";
    h.XData = errorObj.threshold(1,:)*100;
    h.YData = errorObj.ppi(:,1)';    
    h.XLabel = "Weighted Area Threshold (% Max)";
    h.YLabel = "Interpolated Pixels Per cm";

%%%%% Finger Snapshot %%%%%%
    f4 = figure();
    hold on;
    imshow(SkinDataSet.dataRaw(30).img);
    title("Data Log Snaphsot");

%%%%% Error Plot %%%%%%%
    Z1grid = interp(X,Y,Z,2,SkinDataSet);
    h1 = heatmap(Z1grid);



function Zgrid = interp(X,Y,Z,ppcm, SkinDataSet)
    %Interpolated data
    F = scatteredInterpolant(X', Y', Z');
    F.Method = 'natural';
    newX = (0:(1/ppcm):SkinDataSet.lengthIn*2.54);
    newY = (SkinDataSet.widthIn*2.54:-(1/ppcm):0);
    [Xgrid,Ygrid] = meshgrid(newX, newY); %Make new locations to interpolate at
    xlin = Xgrid(:); %Flatten the matrix
    ylin = Ygrid(:);
    DataInterp = F([xlin, ylin]); %evaluate interpolation

        %Organizing data into heat map
    currP = 1;
    for x = 1:length(newX)
        for y = 1:length(newY)
            Zgrid(y,x) = DataInterp(currP);
            currP = currP + 1;
        end
    end

end