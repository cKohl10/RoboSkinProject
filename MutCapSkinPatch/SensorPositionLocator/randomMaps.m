% Used to make a point log heat map figure

clc; close all; clear;

load("Data\SkinPatch1x6_100_3.mat");

%order_rand = randperm(length(SkinDataSet.dataRaw(1).avgData));
order_rand = 1:30;
fprintf("%i\n",find(order_rand==14));
points = [4*5+3, 13*5+3, 18*5+3];

%%%%%%%% Panel %%%%%%%%%%%
for i = 1:length(points)
    figure();
    currP = 1;
    for t = 1:15
        for r = 1:2
            sensorNumber = order_rand(currP);
            localMax = max(SkinDataSet.dataAvgsLin(order_rand(currP), :));
            value = SkinDataSet.dataRaw(points(i)).avgData(sensorNumber);
            cData(r,t) = value/localMax;
            currP = currP+1;
        end
    end
    h(i) = heatmap(cData, 'GridVisible','off', 'Colormap', hot, 'CellLabelColor','none',...
                'YLabel', "", 'XLabel', "",'ColorbarVisible','off', ...
                'Title', "", ...
                'FontSize', 8);

    %Make equal spacing
    originalUnits = h(i).Units;  % save original units (probaly normalized)
    h(i).Units = 'centimeters';  % any unit that will result in squares
    % Get number of rows & columns
    sz = size(h(i).ColorData); 
    % Change axis size & position;
    originalPos = h(i).Position; 
    % make axes square (not the table cells, just the axes)
    h(i).Position(3:4) = min(h(i).Position(3:4))*[1,1]; 
    if sz(1)>sz(2)
        % make the axis size more narrow and re-center
        h(i).Position(3) = h(i).Position(3)*(sz(2)/sz(1)); 
        h(i).Position(1) = (originalPos(1)+originalPos(3)/2)-(h(i).Position(3)/2);
    else
        % make the axis size shorter and re-center
        h(i).Position(4) = h(i).Position(4)*(sz(1)/sz(2));
        h(i).Position(2) = (originalPos(2)+originalPos(4)/2)-(h(i).Position(4)/2);
    end
    % Return axis to original units
    h(i).Units = originalUnits; 
    app.unitsSet = 1;
end