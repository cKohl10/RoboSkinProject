% Add Error
% Not all measurements are perfect, use the data to add random errors
% assuming negligible systematic errors

clc; close all; clear;

[filename, pathname] = uigetfile('*.mat', 'Select a .mat file');
if isequal(filename,0)
   disp('User selected Cancel');
else
   disp(['User selected ', fullfile(pathname, filename)]);
   load(fullfile(pathname, filename));
end

% Noise error from averages
% avg = X_mean +/- sdom(X)

for i = 1:length(SkinDataSet.dataRaw)
    SkinDataSet.dataRaw(i).std = std(SkinDataSet.dataRaw(1).data);
    SkinDataSet.dataRaw(i).sdom = std(SkinDataSet.dataRaw(1).data)/length(SkinDataSet.dataRaw(i).data(:,1));

    SkinDataSet.sdomLin(:,i) = SkinDataSet.dataRaw(i).sdom';
    SkinDataSet.stdLin(:,i) = SkinDataSet.dataRaw(i).std';
end

% Measurement error
% posX = posX +/- deltaX
% posY = posY +/- deltaY

deltaX = 0.2; %cm
deltaY = 0.2; %cm

SkinDataSet.deltaX = deltaX;
SkinDataSet.deltaY = deltaY;

%SNR
for i = 1:SkinDataSet.sensNum
    SkinDataSet.SNR(i) = db(max(SkinDataSet.dataAvgsLin(i,:))/SkinDataSet.sensorError(i));
end

uisave("SkinDataSet", "UpdatedSkinPatch");