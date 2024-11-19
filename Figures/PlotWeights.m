function [] = PlotWeights(Weights, figureConfig)
    


    MeanWeightDeviation(Weights);
    IndWeightDeviation(Weights);
    FinalWeights(Weights);
    WeightCloud(Weights, figureConfig);
end

