% Reading in the data 
function dataClean = readSkin(skinObj)
    data = readline(skinObj);
    seperatedData = split(data, ',');
    dataClean = zeros(1, length(seperatedData));
    for i = 1:length(dataClean)
        val = str2double(seperatedData(i));
        if ~isnan(val)
            dataClean(i) = val;
        end
    end
    %If time is included in the measurement
    %skinObj.UserData.Time = str2double(seperatedData(end));
end