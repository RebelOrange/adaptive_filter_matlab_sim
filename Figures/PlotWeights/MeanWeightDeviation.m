function [] = MeanWeightDeviation(Weights)
filters = fieldnames(Weights);

    figure("Name", "Weight Error")
    title("Mean Weight Deviation")
    colors = {"b","r"};
    hold on
        Legend= {};
        for filter = 1:numel(filters)
            name = filters{filter};
            if name == "Wiener"; continue; end
            [order samples] = size(Weights.(name).Weights);
            x = 1:length(Weights.(name).MSE);
            y = mag2db(abs(Weights.(name).MSE));
            plot(x,y,"-"+colors{filter}); Legend{end+1} = Weights.(name).Name;

        end

        legend(Legend);
        grid on; grid minor;
        xlabel("Sample Number")
        ylabel("Deviation (dB)")
    hold off
end

