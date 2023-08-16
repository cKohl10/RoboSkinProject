%%% Make true set %%%
% Used to identify true sensor positions for comparison

clc; clear; close all;

% Replace data with needed values

trueSet.name = "Blue&WhiteVariedPatch";
trueSet.desc = "Linear vaired sensor locations, 3x10";
trueSet.Tx = 10;
trueSet.Rx = 3;

%Positioning (in)
xLine = 6 - ([5.813, 4.688, 3.688, 2.812, 2.062, 1.437, 0.937, 0.562, 0.312, 0.187] - (1/32));
yLine = [0.812, 0.563, 0.313] - (1/32);
[X,Y] = meshgrid(xLine, yLine);
x = X(:);
y = Y(:);
trueSet.posReal = [x';y'];

save(trueSet.name + ".mat", "trueSet")