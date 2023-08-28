clc; close all;clear;
%This graph is for the error associated with collecting more or less data
%points
collect = 0;

% Uniform sensor
set(1,:) =   ["Data\SkinPatch1x6_100_1.mat", ...
            "Data\SkinPatch1x6_80_1.mat",...
            "Data\SkinPatch1x6_60_1.mat",...
            "Data\SkinPatch1x6_40_1.mat",...
            "Data\SkinPatch1x6_20_1.mat "];

% Non-Uniform sensor
set(2,:) =   ["Data\SkinPatch1x6_100_3.mat", ...
            "Data\SkinPatch1x6_80_3.mat ",...
            "Data\SkinPatch1x6_60_2.mat ",...
            "Data\SkinPatch1x6_40_2.mat",...
            "Data\SkinPatch1x6_20_2.mat"];

% Collect error for each set
if collect
    for i = 1:2
        currSet = set(i,:);
        for j = 1:length(currSet)
            load(currSet(j));
            loadSet.SkinDataSet = SkinDataSet;
            SensorLocator(1, loadSet, "Running Error");
            input("Continue?");
            error(i).value(j) = lastError;
        end
    end
else
    load("Data\errorBySamples.mat");
end

%Graph with samples
f = figure();
hold on;
grid on;
for i = 1:2
    plot(error(i).samples, error(i).value, 'Marker','x', 'MarkerSize', 10, 'LineWidth', 3, 'MarkerEdgeColor','k');
    legends(i) = error(i).name;
end
xlabel("Number of Point Logs");
ylabel("Standard Deviation of Error (cm)");
title("Prediction Accuracy by Point Logs");
legend(legends);
hold off;

%Error table for each sensor
SkinA = load("Data\PatchAIndvErrors.mat").lastRunSkinData;
SkinB = load("Data\PatchBIndvErrors.mat").lastRunSkinData;

sensnumsA = 1:SkinA.sensNum;
sensnumsB = 1:SkinB.sensNum;
[~,orderA] = sort(SkinA.sensorError, 'descend');
[~,orderB] = sort(SkinB.sensorError, 'descend');

for i = sensnumsA
    Alabels(i) = "Sensor " + i;
end

for i = sensnumsB
    Blabels(i) = "Sensor " + i;
end


% f2 = figure();
% hold on;
% subplot(2,1,1);
% bar(sensnumsA, SkinA.sensorError(orderA));
% xtickangle(45)
% xticklabels(Alabels(orderA));
% subplot(2,1,2);
% bar(sensnumsB, SkinB.sensorError(orderB));
% xtickangle(45)
% hold off;

%%%%% Error Tables %%%%%%%%
    %Error table for each sensor
    SkinA = load("Data\UpdatedSkinPatch_A100.mat").SkinDataSet;
    SkinB = load("Data\UpdatedSkinPatch_B100.mat").SkinDataSet;

    trueSetA = load("SkinTruePositions\BlueLinearPatch.mat").trueSet;
    trueSetB = load("SkinTruePositions\Blue&WhiteVariedPatch.mat").trueSet;


    for i = sensnumsA
        SensorNumberA{i} = "Sensor " + i;
        RealPositionA{i} = sprintf("(%0.2f, %0.2f)", trueSetA.posReal(1,i), trueSetA.posReal(2,i));
        PredictedPositionA{i} = sprintf("(%0.2f, %0.2f)", SkinA.posPred(1,i), SkinA.posPred(2,i));
        PredictionErrorA{i} = sprintf("%0.2f", sqrt( (trueSetA.posReal(1,i)-SkinA.posPred(1,i))^2 + (trueSetA.posReal(2,i)-SkinA.posPred(2,i))^2 ));
        NoiseDeviationA{i} = sprintf("%0.1f", (std(SkinA.noiseRaw(:,i))/max(SkinA.dataAvgsLin(i,:)))*100);
    end
    TA = table(SensorNumberA',RealPositionA',PredictedPositionA',PredictionErrorA',NoiseDeviationA','VariableNames',{'Sensor Number','Real Position (cm)','Predicted Position (cm)','Prediction Error (cm)', 'Noise (% max)'});
    table2latex(TA)

    for i = sensnumsB
        SensorNumberB{i} = "Sensor " + i;
        RealPositionB{i} = sprintf("(%0.2f, %0.2f)", trueSetB.posReal(1,i), trueSetB.posReal(2,i));
        PredictedPositionB{i} = sprintf("(%0.2f, %0.2f)", SkinB.posPred(1,i), SkinB.posPred(2,i));
        PredictionErrorB{i} = sprintf("%0.2f", sqrt( (trueSetB.posReal(1,i)-SkinB.posPred(1,i))^2 + (trueSetB.posReal(2,i)-SkinB.posPred(2,i))^2 ));
        NoiseDeviationB{i} = sprintf("%0.1f", SkinB.SNR(i));
    end
    TB = table(SensorNumberB',RealPositionB',PredictedPositionB',PredictionErrorB',NoiseDeviationB','VariableNames',{'Sensor Number','Real Position (cm)','Predicted Position (cm)','Prediction Error (cm)', 'Noise (% max)'});
    table2latex(TB)
    

