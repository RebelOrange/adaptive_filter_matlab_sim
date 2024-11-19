function [z] = ReadFolderFileDat(folder, filename, options)
arguments
    folder 
    filename 
    options.WeightsFlag = 0;
    options.decBits = 32;
end

    filePath = dir(fullfile(folder,filename));
    filePath = fullfile(filePath.folder, filePath.name);
    if options.WeightsFlag
        dataInt = readmatrix(filePath);
        divider = 2.^(options.decBits);
        dataFP = dataInt./divider;

        z = complex(double(dataFP(:,1)),double(dataFP(:,2)));
    else
        data = readmatrix(filePath);
        z = complex(data(:,1),data(:,2));
    end

end

