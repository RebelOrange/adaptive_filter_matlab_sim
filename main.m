clear all
close all
clc

warning off all

addpath("Signals\");
addpath("Models\");
addpath("Figures\");
addpath("Filters\");
addpath("Utils\");

%% load experiment config
% fname = "experiment_jsons\SIR\sir_3.json";
% fname = "experiment_jsons\LearningRate\l_rate_3.json";
% fname = "experiment_jsons\AOA\aoa_1.json";
datasets_folder = "C:\\Users\\david\\OneDrive\\Documents\\4. rfdev\\data\\";
% fname = "experiment_jsons\NoiseBandwidth\nbw_3.json";
fname = "experiment_jsons\SIR\sir_2.json";
fid = fopen(fname);
jsonstr = char(fread(fid,inf)');
fclose(fid);
exp_config = jsondecode(jsonstr);
exp_config.FileConfig.ExperimentFolder = datasets_folder+exp_config.FileConfig.ExperimentFolder;

%% input parameters
DISPLAY_FIGURES         = 1;
GEN_NEW_DATA            = 1;
SAVE_RESULTS            = 0;
IMPORT_MATLAB_RESULTS   = 0;
IMPORT_VIVADO_RESULTS   = 0;

SAVE_PATH = "";
MATLAB_RESULTS_PATH = "";
VIVADO_RESULTS_PATH = "";

if (GEN_NEW_DATA)
    RUN_ALL_MODELS = 1;
else
    RUN_ALL_MODELS = 0;
end

addpath(pwd);
%% Data Struture Outline
% custom "signal" struct:
% signal:
%   * IQ                - Nx1 Timeseries IQ amplitude (double, int16, etc)
%   * CenterFreq        - Signal center freq (Hz)
%   * SampleRate        - sample rate (Hz)
%   * TimeSamples       - Nx1 time samples based on sample rate (nsec)
%   * PulseWidth        - Pulsewidth (sec)
%   * SignalType        - String of signal type information (LFM, Noise,
%   etc)
%   * SignalAntenna     - Source antenna (main, aux1, aux2, etc)
%   * SignalSource      - String of signal generation source (Antenna,
%   Freespace, etc)
%   * SignalDestination - String of original desitination of signal
%   * SignalName        - String of signal name for plotting purposes
%
% General form of script:
%       signalin -> | process blockho | -> signalout (new fields)
% 
% All signals are stored in a signals struct:
% signals:
%   * main_0
%   * aux_0
%   * aux_1
%   * etc
if (RUN_ALL_MODELS)
    modelSignals.main_0 = GenerateSignal("Type","LFM", "CenterFreq", exp_config.SignalConfig.CenterFreq, ...
     "Bandwidth",exp_config.SignalConfig.Bandwidth, "TransmitPower",1, "PulseWidth",exp_config.SignalConfig.PulseWidth);
    modelSignals.aux_0 = GenerateSignal("Type","Noise","CenterFreq",exp_config.SignalConfig.CenterFreq, ...
     "Bandwidth",exp_config.SignalConfig.NoiseBandwidth, "TransmitPower",1, "PulseWidth", exp_config.SignalConfig.PulseWidth);
end
%% Freespace, Beampattern, and Receiver Models
if (RUN_ALL_MODELS)    
    FixedSignals = FixedSNRModel(modelSignals,"SNR", exp_config.SignalConfig.SNR, "NoiseAmplitude", ...
    exp_config.SignalConfig.NoiseAmplitude, "Leakage", exp_config.SignalConfig.Leakage, "PhaseAngle", ...
    exp_config.SignalConfig.PhaseAngle, "SIR", exp_config.SignalConfig.SIR);

end
%% Digitization Model
% TODO: add ap_fixed function in MATLAB_HLS package
if (RUN_ALL_MODELS)
    SDRSignals = SDRModel(FixedSignals, "ClockFreq", exp_config.SDRConfig.ClockFreq, "IQRate",...
     exp_config.SDRConfig.IQRate, "BasebandFreq",exp_config.SDRConfig.BasebandFreq);
end
% return
%% Import Data
%TODO: imported data should have the same "signal" structure as the modeled
%data. Possibly save sim settings as a JSON? 
if (IMPORT_MATLAB_RESULTS)
    main_data = RFNoC.ReadTBDat(exp_config.FileConfig.ExperimentFolder + "main"+ exp_config.FileConfig.FilenamePrefix);
    aux_data = RFNoC.ReadTBDat(exp_config.FileConfig.ExperimentFolder + "aux"+ exp_config.FileConfig.FilenamePrefix);
%     main_data = RFNoC.ReadTBDat("C:\Users\david\OneDrive\Documents\4. rfdev\data\input\noise_cancel\main_samples.dat");
%     aux_data = RFNoC.ReadTBDat("C:\Users\david\OneDrive\Documents\4. rfdev\data\input\noise_cancel\aux_samples.dat");

    %convert settings to SDRSignals struct
    SDRSignals.main_0.I = real(main_data.');
    SDRSignals.main_0.Q = imag(main_data.');
    SDRSignals.main_0.Name = "IQ";
    SDRSignals.main_0.Antenna = "Main";
    SDRSignals.main_0.CenterFreq = exp_config.SDRConfig.BasebandFreq;
    SDRSignals.main_0.PulseWidth = exp_config.SignalConfig.PulseWidth;
    SDRSignals.main_0.Bandwidth = exp_config.SignalConfig.Bandwidth;

    SDRSignals.aux_0.I = real(aux_data.');
    SDRSignals.aux_0.Q = imag(aux_data.');
    SDRSignals.aux_0.Name = "IQ";
    SDRSignals.aux_0.Antenna = "Aux";
    SDRSignals.aux_0.CenterFreq = exp_config.SDRConfig.BasebandFreq;
    SDRSignals.aux_0.PulseWidth = exp_config.SignalConfig.PulseWidth;
    SDRSignals.aux_0.Bandwidth = exp_config.SignalConfig.Bandwidth;
    
end
if (IMPORT_VIVADO_RESULTS)
    sim_data = RFNoC.ReadTBDat("C:\Users\david\OneDrive\Documents\4. rfdev\data\input\noise_cancel\sim_results.dat");
    weight_0_data = RFNoC.ReadWeightDat("C:\Users\david\OneDrive\Documents\4. rfdev\data\input\noise_cancel\weight_0.dat");
    if exp_config.FilterConfig.FilterOrder == 1
        weight_1_data = RFNoC.ReadWeightDat("C:\Users\david\OneDrive\Documents\4. rfdev\data\input\noise_cancel\weight_1.dat");
        weight_2_data = RFNoC.ReadWeightDat("C:\Users\david\OneDrive\Documents\4. rfdev\data\input\noise_cancel\weight_2.dat");
    else
        weight_1_data = complex(zeros(size(real(weight_0_data))),zeros(size(real(weight_0_data))));
        weight_2_data = complex(zeros(size(real(weight_0_data))),zeros(size(real(weight_0_data))));
    end

    vivadoSignals.main_0 = SDRSignals.main_0;
    vivadoSignals.main_0.I = real(sim_data).';
    vivadoSignals.main_0.Q = imag(sim_data).';
    SDRSignals.aux_0.Name = "Vivado IQ";
    vivadoSignals.main_0.Weights = [weight_0_data, weight_1_data, weight_2_data].';

else
    %error("Selected both MATLAB and Vivado import.")
end
%% Adaptive Filter Comparisons
if true
    % TODO: add LMS, NLMS, and BLMS algorithms. Investigate RLS
    sig = SDRSignals.aux_0.I+1i.*SDRSignals.aux_0.Q;
    % lms_norm = 10./(sig*sig');
    lms_norm = 1;
    dataType = "double";
    [LMSSignals] = AdaptiveFIRModel(SDRSignals, "FilterOrder",exp_config.FilterConfig.FilterOrder, ...
            "LearningRate",exp_config.FilterConfig.LMSlearningRate.*lms_norm, "Type", "LMS", "DataType",dataType);
    [NLMSSignals] = AdaptiveFIRModel(SDRSignals, "FilterOrder",exp_config.FilterConfig.FilterOrder, ...
      "LearningRate", exp_config.FilterConfig.NLMSLearningRate, "Type", "NLMS", "DataType",dataType);
    [LMFSignals] = AdaptiveFIRModel(SDRSignals, "FilterOrder",exp_config.FilterConfig.FilterOrder,  ...
    "LearningRate", exp_config.FilterConfig.LMSlearningRate.*lms_norm, "Type", "LMF", "DataType",dataType);
    % [NLMFSignals] = AdaptiveFIRModel(SDRSignals, "LearningRate", 0.2, "Type", "NLMF", "DataType",dataType);
    
    [WienerSignals] = AdaptiveFIRModel(SDRSignals, "FilterOrder",exp_config.FilterConfig.FilterOrder, ...
     "LearningRate", exp_config.FilterConfig.LMSlearningRate, "Type", "Wiener");
    [MOLSSignals] = AdaptiveFIRModel(SDRSignals,  "FilterOrder",exp_config.FilterConfig.FilterOrder,...
     "Type", "MOLS", "DataType",dataType);
    
    Weights.LMS.Weights = LMSSignals.main_0.Weights;
    Weights.NLMS.Weights = NLMSSignals.main_0.Weights;
    % Weights.MOLS.Weights = MOLSSignals.main_0.Weights;
    % Weights.LMF.Weights = LMFSignals.main_0.Weights;
    % Weights.NLMF.Weights = NLMFSignals.main_0.Weights;
    % Weights.Vivado.Weights = vivadoSignals.main_0.Weights;
    Weights.Wiener.Weights = WienerSignals.main_0.Weights;


[Weights] = WeightStats(Weights);
end
%% Save and Export Results
if (SAVE_RESULTS)
    RFNoC.SaveAsTBDat(SDRSignals.main_0.I, SDRSignals.main_0.Q, "fileName",  "main"+ exp_config.FileConfig.FilenamePrefix,"folderName",exp_config.FileConfig.ExperimentFolder);
    RFNoC.SaveAsTBDat(SDRSignals.aux_0.I, SDRSignals.aux_0.Q, "fileName",  "aux" + exp_config.FileConfig.FilenamePrefix,"folderName",exp_config.FileConfig.ExperimentFolder);
end
%% Figures

DISPLAY_FIGURES = 1;
if (DISPLAY_FIGURES)
    % PlotSignals(FSSignals, BPSignals, RXSignals, SDRSignals);
    % PlotSignals(RXSignals);
    PlotSignals(FixedSignals, LMSSignals, NLMSSignals, WienerSignals);
    PlotWeights(Weights);

end