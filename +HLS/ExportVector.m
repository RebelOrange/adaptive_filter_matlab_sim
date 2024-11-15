function [] = ExportVector(vector, options)
arguments
    vector
    options.fileName = "xsim_samples.dat"
    options.folderName = pwd;
end
    [row, col] = size(vector);
    if row >1
        vector = vector.';
    end
    
    fileName = fullfile(options.folderName, options.fileName);
    disp("Writing CSV File: " + fileName + "...")

    writematrix(vector, fileName);
end

