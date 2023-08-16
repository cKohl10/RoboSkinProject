function param = getParams()
%%%%%%%%%%% This function sets all the hyper parameters for testing %%%%%%
param.TX = 11;
param.RX = 2;
param.threshold = 100;
param.calibSamples = 50;
param.numSensors = param.TX*param.RX;

% Serial Communications
param.serialPort = "COM4";
param.baudRate = 115200;

end