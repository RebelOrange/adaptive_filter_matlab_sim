function [] = SaveAsTBDat(I, Q, options)
arguments
    I 
    Q 
    options.fileName = "xsim_samples.dat"
    options.folderName = pwd;
end
    
    IQArray = int16(zeros(numel(I),2));
    IQArray(:,1) = I;
    IQArray(:,2) = Q;

    fileName = fullfile(options.folderName, options.fileName);
    disp("Writing Testbench File: " + fileName + "...")

    writematrix(IQArray, fileName);
end

