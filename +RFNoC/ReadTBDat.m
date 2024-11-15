function [z] = ReadTBDat(filePath)
    data = readmatrix(filePath);
    z = complex(data(:,1),data(:,2));
    
end

