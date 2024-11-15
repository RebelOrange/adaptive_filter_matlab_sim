function [dataFP] = ReadWeightDat(filePath, options)
arguments
    filePath 
    options.decBits = 32;
end
    dataInt = readmatrix(filePath);
    divider = 2^(options.decBits); % fixed point location
    dataFP = dataInt./divider;

    dataFP = complex(double(dataFP(:,1)), double(dataFP(:,2)));
    
end

