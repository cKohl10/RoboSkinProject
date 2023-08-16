function [noiseProfile, noiseRaw] = calibrateSkin(skinObj)
    param = getParams();
    
    fprintf("Calibrating...");
    noiseRaw = zeros(param.calibSamples, param.numSensors);
    flush(skinObj);
    for i =1:20, readSkin(skinObj); end
    for i = 1:param.calibSamples
        noiseRaw(i,:) = readSkin(skinObj);
    end
    noiseProfile = mean(noiseRaw, 1);
    fprintf("Calibration Complete\n");
end