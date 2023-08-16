%% Data Collection Program
% This program logs n sensor inputs while a button is pressed on square
% patch
% Author: Carson Kohlbrenner
% Date: 6/22/23
% Concurrent Arduino Code: SkinUnitNxN

%Note, this will not overide any saved data and will create a new file
clc; close all; clear;

%Calibrate?
calibrate = 1;

% Parameters
param = getParams();
TX = param.TX;
RX = param.RX;
s = RX*TX; %number of sensors
pl = TX; %Length number of data points
pw = RX; %Width number of data points
sampleSize = 50;
noiseSample = param.calibSamples;
description = input("Data Description: \n", "s");

%Struct Setup and serial communication
skinObj = serialport(param.serialPort,param.baudRate);
skinObj.UserData = struct("Data",[],"Time",[]);
totalP = pl*pw;
dataRaw = repmat(struct('Data',[]), totalP, 1 );
SkinDataSet.desc = description;
SkinDataSet.sensNum = s;
SkinDataSet.resWidth = pw;
SkinDataSet.resLength = pl;
SkinDataSet.noiseRaw = zeros(noiseSample, s);

% Figure to detect keyboard input
f = figure();
currP = 1;
%load chirp;
%y(1000:end) = [];
[y, Fs] = audioread('Resources/nextSound.wav');
%sound(y,Fs);

% Saving Data
fileName = "Data/SkinPatch" + RX + "RXx" + TX + "TX_" + totalP + "Data";
fileType = ".mat";
count = 1;
path = fileName+count+fileType;

fileContents = dir("Data");
while exist(path, "file")
    count = count + 1;
    path = fileName+count+fileType;
end


% Logging the data
% Data in struct with following parameters:
%
% SkinDataSet:
%   -desc = Description of data
%   -sensNum = number of sensors in patch
%   -resWidth = width resolution
%   -resLength = length resolution
%   -dataRaw: 
%       --data = [samples x s] (capacitance)
%       --time = [samples x 1] (ms)
%       --pos = [1x2] (x and y)
%       --avgData = [1 x s]
% 

%Logging the noise profile
[noiseProfile, SkinDataSet.noiseRaw] = calibrateSkin(skinObj);
SkinDataSet.noiseProfile = noiseProfile;

% Process of logging the data
for l = 1:pl
    for w = 1:pw
        fprintf("Point Pos: %0.0f, %0.0f \n", l, w);
        wait = waitforbuttonpress;
        flush(skinObj)
        temp = readSkin(skinObj);
        for i = 1:sampleSize
            if calibrate 
                dataRaw(currP).data(i,:) = readSkin(skinObj) - noiseProfile;
            else
                dataRaw(currP).data(i,:) = readSkin(skinObj);
            end
        end
        dataRaw(currP).pos = [l, w];
        currP = currP + 1;
        sound(y, Fs);
    end
end

%Intermitent Save
fprintf("Data Collection Complete");
SkinDataSet.dataRaw = dataRaw;
save(path, "SkinDataSet");
%% Break
spotTrain = 1; %Indicator to find how many data points

%Put the data into averages and usable forms
for i = 1:length(SkinDataSet.dataRaw)
    for j = 1:sampleSize
        SkinDataSet.dataRawLin(:, spotTrain) = SkinDataSet.dataRaw(i).data(j,:)';
        SkinDataSet.posLin(:, spotTrain) = SkinDataSet.dataRaw(i).pos';
        spotTrain = spotTrain+1;
    end
    SkinDataSet.dataRaw(i).avgData = mean(SkinDataSet.dataRaw(i).data, 1);
    SkinDataSet.dataAvgsLin(:, i) = SkinDataSet.dataRaw(i).avgData';
    SkinDataSet.posLinAvg(:,i) = SkinDataSet.dataRaw(i).pos';
end

% Saving Data, Final
save(path, "SkinDataSet");


