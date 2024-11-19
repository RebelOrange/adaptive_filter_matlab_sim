clear all 
close all
clc
warning off all

addpath("Signals\");
addpath("Models\");
addpath("Figures\");
addpath("Figures\PlotWeights\");
addpath("Filters\");
addpath("Utils\");
addpath(genpath("experiment_jsons\"));

%% load experiment config
% fname = "experiment_jsons\SIR\sir_3.json";
% fname = "experiment_jsons\LearningRate\l_rate_3.json";
% fname = "experiment_jsons\AOA\aoa_1.json";
datasets_folder = "C:\\Users\\david\\OneDrive\\Documents\\4. rfdev\\data\\";
% fname = "experiment_jsons\NoiseBandwidth\nbw_1.json";
exp = "4";
fname = "experiment_jsons\SIR\sir_" + exp + ".json";
% fname = "experiment_jsons\NoiseBandwidth\nbw_" +exp +".json";
SAVE_FIGS = 0;


% fname = "record_jsons\SNR\sir_" + exp +".json";
fname = "record_jsons\BW\nbw_" + exp+ ".json";
% fname = "record_jsons\path_length\pl_3.json";
fid = fopen(fname);
jsonstr = char(fread(fid,inf)');
fclose(fid);
exp_config = jsondecode(jsonstr);
exp_config.FileConfig.ExperimentFolder = datasets_folder+exp_config.FileConfig.ExperimentFolder;

exp_config.FilterConfig.NLMSLearningRate = 0.3;
% exp_config.FilterConfig.FilterOrder = 1;

IMPORT_SIM_DATA = 1;
IMPORT_VIVADO_RESULTS = 1;
    LOAD_1TAP = 0;
    LOAD_3TAP = 1;
DISPLAY_FIGURES = 1;

FILTER_TYPE = "*nlms*";
FILTER_ORDER = "3tap";
if exp_config.FilterConfig.NLMSLearningRate == 0.03
    LEARNING_RATE = "*0_03*";
else
    LEARNING_RATE = "*0_3*";
end


if (IMPORT_SIM_DATA)
    main_data = RFNoC.ReadTBDat(exp_config.FileConfig.ExperimentFolder + "main"+ exp_config.FileConfig.FilenamePrefix);
    aux_data = RFNoC.ReadTBDat(exp_config.FileConfig.ExperimentFolder + "aux"+ exp_config.FileConfig.FilenamePrefix);

    %convert settings to SDRSignals struct
    SDRSignals.main_0.I = real(main_data.');
    SDRSignals.main_0.Q = imag(main_data.');
    SDRSignals.main_0.TimeSamplesIQ = (0:length(real(main_data))-1)./exp_config.SDRConfig.IQRate;
    SDRSignals.main_0.SampleRate = exp_config.SDRConfig.IQRate;
    SDRSignals.main_0.Name = "Input IQ";
    SDRSignals.main_0.Antenna = "Main";
    SDRSignals.main_0.Source = "SDR DDC";
    SDRSignals.main_0.Type = "";
    SDRSignals.main_0.CenterFreq = exp_config.SDRConfig.BasebandFreq;
    SDRSignals.main_0.PulseWidth = exp_config.SignalConfig.PulseWidth;
    SDRSignals.main_0.Bandwidth = exp_config.SignalConfig.Bandwidth;

    SDRSignals.aux_0.I = real(aux_data.');
    SDRSignals.aux_0.Q = imag(aux_data.');
    SDRSignals.aux_0.TimeSamplesIQ = (0:length(real(aux_data))-1)./exp_config.SDRConfig.IQRate;
    SDRSignals.aux_0.SampleRate = exp_config.SDRConfig.IQRate;
    SDRSignals.aux_0.Name = "Input IQ";
    SDRSignals.aux_0.Antenna = "Aux";
    SDRSignals.aux_0.Source = "SDR DDC";
    SDRSignals.aux_0.Type = "";
    SDRSignals.aux_0.CenterFreq = exp_config.SDRConfig.BasebandFreq;
    SDRSignals.aux_0.PulseWidth = exp_config.SignalConfig.PulseWidth;
    SDRSignals.aux_0.Bandwidth = exp_config.SignalConfig.Bandwidth;
    
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
    

end

%% import vivado results
if (IMPORT_VIVADO_RESULTS)
    if LOAD_1TAP
    FILTER_ORDER = "1tap";
    sim_data = RFNoC.ReadFolderFileDat(exp_config.FileConfig.ExperimentFolder, "sim_results" + FILTER_TYPE + FILTER_ORDER + ".dat", "WeightsFlag",0);
    weight_0_data = RFNoC.ReadFolderFileDat(exp_config.FileConfig.ExperimentFolder, "weight_0" + FILTER_TYPE + FILTER_ORDER + ".dat", WeightsFlag=1);
    weight_1_data = complex(zeros(size(real(weight_0_data))),zeros(size(real(weight_0_data))));
    weight_2_data = complex(zeros(size(real(weight_0_data))),zeros(size(real(weight_0_data))));

    vivado1TapSignals.main_0 = SDRSignals.main_0;
    vivado1TapSignals.main_0.I = real(sim_data).';
    vivado1TapSignals.main_0.Q = imag(sim_data).';
    vivado1TapSignals.main_0.TimeSamplesIQ = (0:length(real(sim_data))-1)./exp_config.SDRConfig.IQRate;
    vivado1TapSignals.main_0.SampleRate = exp_config.SDRConfig.IQRate;
    vivado1TapSignals.main_0.Name = "Hardware NLMS (1 Tap)";
    vivado1TapSignals.main_0.Source = "SDR DDC";
    vivado1TapSignals.main_0.Antenna = "Output";
    vivado1TapSignals.main_0.Type = "";
    vivado1TapSignals.main_0.Weights = [weight_0_data, weight_1_data, weight_2_data].';

    end

    if LOAD_3TAP
    FILTER_ORDER = "3tap";
    sim_data = RFNoC.ReadFolderFileDat(exp_config.FileConfig.ExperimentFolder, "sim_results" + FILTER_TYPE + FILTER_ORDER + LEARNING_RATE+ ".dat", "WeightsFlag",0);
    weight_0_data = RFNoC.ReadFolderFileDat(exp_config.FileConfig.ExperimentFolder, "weight_0" + FILTER_TYPE + FILTER_ORDER + LEARNING_RATE+ ".dat", WeightsFlag=1);
    if exp_config.FilterConfig.FilterOrder == 3
        weight_1_data = RFNoC.ReadFolderFileDat(exp_config.FileConfig.ExperimentFolder,  "weight_1" + FILTER_TYPE + FILTER_ORDER+ LEARNING_RATE + ".dat", WeightsFlag=1);
        weight_2_data = RFNoC.ReadFolderFileDat(exp_config.FileConfig.ExperimentFolder,  "weight_2" + FILTER_TYPE + FILTER_ORDER + LEARNING_RATE+ ".dat", WeightsFlag=1);
    else
        weight_1_data = complex(zeros(size(real(weight_0_data))),zeros(size(real(weight_0_data))));
        weight_2_data = complex(zeros(size(real(weight_0_data))),zeros(size(real(weight_0_data))));
    end

   vivado3TapSignals.main_0 = SDRSignals.main_0;
    vivado3TapSignals.main_0.I = real(sim_data).';
    vivado3TapSignals.main_0.Q = imag(sim_data).';
    vivado3TapSignals.main_0.TimeSamplesIQ = (0:length(real(sim_data))-1)./exp_config.SDRConfig.IQRate;
    vivado3TapSignals.main_0.SampleRate = exp_config.SDRConfig.IQRate;
    
    vivado3TapSignals.main_0.Name = "Hardware NLMS (3 Tap)";
    vivado3TapSignals.main_0.Source = "SDR DDC";
    vivado3TapSignals.main_0.Antenna = "Output";
    vivado3TapSignals.main_0.Type = "";
    vivado3TapSignals.main_0.Weights = [weight_0_data, weight_1_data, weight_2_data].';
    end
else
    %error("Selected both MATLAB and Vivado import.")
end

%% add weights
% Weights.LMS.Weights = LMSSignals.main_0.Weights;
% Weights.MOLS.Weights = MOLSSignals.main_0.Weights;
% Weights.LMF.Weights = LMFSignals.main_0.Weights;
% Weights.NLMF.Weights = NLMFSignals.main_0.Weights;

Weights.NLMS.Weights = NLMSSignals.main_0.Weights;
Weights.NLMS.Name = "Matlab NLMS";

if (LOAD_3TAP && LOAD_1TAP)
    Weights.Vivado3Tap.Weights = vivado3TapSignals.main_0.Weights;
    Weights.Vivado3Tap.Name = "Hardware NLMS";
    Weights.Vivado1Tap.Weights = vivado1TapSignals.main_0.Weights;
    Weights.Vivado1Tap.Name = "Hardware NLMS";
elseif (LOAD_3TAP && ~LOAD_1TAP)
     Weights.Vivado3Tap.Weights = vivado3TapSignals.main_0.Weights;
    Weights.Vivado3Tap.Name = "Hardware NLMS";
elseif (~LOAD_3TAP && LOAD_1TAP)
     Weights.Vivado1Tap.Weights = vivado1TapSignals.main_0.Weights;
    Weights.Vivado1Tap.Name = "Hardware NLMS";
end
Weights.Wiener.Weights = WienerSignals.main_0.Weights;
Weights.Wiener.Name = "Wiener";

[Weights] = WeightStats(Weights);


%% Figures
if (DISPLAY_FIGURES)
    % PlotSignals(FSSignals, BPSignals, RXSignals, SDRSignals);
    % PlotSignals(RXSignals);

    %     FigureConfig.StartIndex = 1;
    %     PlotWeights(Weights,FigureConfig);
    %     PlotSignals(WienerSignals, NLMSSignals);
    %     PlotMisadjustment(WienerSignals, NLMSSignals, vivado3TapSignals);
    % 
    % return 
    if (LOAD_3TAP && LOAD_1TAP)
        PlotSignals(SDRSignals, NLMSSignals, vivado3TapSignals, vivado1TapSignals, WienerSignals);
    elseif (LOAD_3TAP && ~LOAD_1TAP)
        PlotSignals(SDRSignals, NLMSSignals, vivado3TapSignals, WienerSignals);
    elseif (~LOAD_3TAP && LOAD_1TAP)
        PlotSignals(SDRSignals, NLMSSignals, vivado1TapSignals, WienerSignals);
    end

    if exist('exp_config.FigureConfig')
        PlotWeights(Weights, exp_config.FigureConfig);
    else
        FigureConfig.StartIndex = 1;
        PlotWeights(Weights,FigureConfig);
    end
    PlotMisadjustment(WienerSignals, NLMSSignals, vivado3TapSignals);
end

if SAVE_FIGS
    output_folder = "Latex_Figures\sim_experiments\SNR\exp" + exp + "\";
    % output_folder = "Latex_Figures\sim_experiments\BW\exp" + exp + "\";
    output_folder = "Latex_Figures\real_experiments\SNR\exp" + exp + "\";

    figHandles = findall(0, 'Type', 'figure');

    for i = 1:numel(figHandles)
        disp(sprintf("Saving figure %d: %s", i, figHandles(i).Name))
        saveas(figHandles(i), output_folder +  figHandles(i).Name + ".jpg")
    end
end