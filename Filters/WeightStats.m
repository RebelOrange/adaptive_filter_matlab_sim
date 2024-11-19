function [wStruct] = WeightStats(wStruct)
    filters = fieldnames(wStruct);

    % calculate Mean Square Error of weight vector at each step
    for filter = 1:numel(filters)
        name = filters{filter};
        [order, samples] = size(wStruct.(name).Weights);
        wStruct.(name).MSE = sum((wStruct.(name).Weights - wStruct.Wiener.Weights).^2,1) ./ numel(wStruct.Wiener.Weights);
        for n = 0:(order-1)
            wStruct.(name).("MSE"+num2str(n)) =((wStruct.(name).Weights(n+1,:) - wStruct.Wiener.Weights(n+1)).^2);
        end

    end
end

