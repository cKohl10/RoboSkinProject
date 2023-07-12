%% Linear Regression Model
clc; close all; clear;

%Choose which data to train on
load("Data/SkinPatch2x2_196Data2.mat");

%Hyperparameter to train the model
ExecuteTrain = 0;

%If train = 1, train the model again
if ExecuteTrain
    
    inputs = SkinDataSet.dataRawLin;
    outputs = SkinDataSet.posLin;

    % Create a feedforward neural network with 4 input neurons and 2 output neurons
    net = feedforwardnet(10);
    
    % Train the neural network using the inputs and targets
    %[net,tr] = train(net,dataAvgs,location);
    [net,tr] = train(net,inputs,outputs);

    save("CurrentNet", "net");
else
    load("CurrentNet.mat");
end

%Hyper parameters
boxWidth = SkinDataSet.resWidth;
n = SkinDataSet.sensNum;
location = SkinDataSet.posLinAvg;
colormap hot;

% Test the neural network using new inputs
outputs = net(SkinDataSet.dataAvgsLin);
for i = 1:length(outputs)
    fprintf("Original Location: %0.2f, %0.2f. Predicted Location %0.2f, %0.2f\n", location(1,i), location(2,i), outputs(1,i), outputs(2,i))
end

%Catagorizing the error
[horzErr, vertErr] = meshgrid(1:boxWidth, 1:boxWidth); %Defining the error in each spot
totErr = zeros(1,length(outputs));
spot = 1;
for i=1:boxWidth
    for j = 1:boxWidth
        horzErr(i,j) = abs(outputs(2,spot) - location(2,spot))^2;
        vertErr(i,j) = abs(outputs(1,spot) - location(1,spot))^2;
        totErr(spot) = sqrt(horzErr(i,j)^2 + vertErr(i,j)^2);
        spot = spot+1;
    end
end

%Display Error
f = figure();
colormap(f, "hot");
xlim([1,14]);
ylim([-14,1]);
scatter(location(2,:), -location(1,:), 800, totErr, 'filled', 'square');
title("Error of Model");
ylabel("Y Position");
xlabel("X Position");
colorbar;

%Data Visualization
h = figure();
colormap(h, "hot");
sgtitle("Sensor Average Training Data")
for i = 1:n
    subplot(sqrt(n), sqrt(n), i);
    hold on;
    scatter(location(2,:), -location(1,:), 80, SkinDataSet.dataAvgsLin(i,:), 'filled', 'square');
    colorbar;
    ylabel("Y Position");
    xlabel("X Position");
    title("Sensor #"+ i);
end

