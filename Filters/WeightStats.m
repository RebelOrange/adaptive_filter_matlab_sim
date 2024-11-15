function [wStruct] = WeightStats(wStruct)
    filters = fieldnames(wStruct);

    % calculate Mean Square Error of weight vector at each step
    for filter = 1:numel(filters)
        name = filters{filter};
        wStruct.(name).MSE = sum((wStruct.(name).Weights - wStruct.Wiener.Weights).^2,1) ./ numel(wStruct.Wiener.Weights);
    end
end

