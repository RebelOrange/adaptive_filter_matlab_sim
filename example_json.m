clear all
close all
clc

% example json reader
fname = "experiment_setup.json";
fid = fopen(fname);
jsonstr = char(fread(fid,inf)');
fclose(fid);
data = jsondecode(jsonstr);

%% old 
%% Signal and Noise Model
% TODO: setup signal and noise model
if (RUN_ALL_MODELS)
    modelSignals.main_0 = GenerateSignal("Type","LFM", "CenterFreq", 20e6, "Bandwidth", 1e6, "TransmitPower",1, PulseWidth=200e-6 );
    modelSignals.aux_0 = GenerateSignal("Type","Noise","CenterFreq",20e6, "Bandwidth",1e6, "TransmitPower", 1, PulseWidth=200e-6);
end