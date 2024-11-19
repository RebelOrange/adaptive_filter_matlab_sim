function [] = IndWeightMisadjustment(Weights)
filters = fieldnames(Weights);

    for filter = 1:numel(filters)
    name = filters{filter};
    if  name == "Wiener"; continue; end
    figure("Name", "Weight Error "+ filters{filter})
    title(Weights.(name).Name+ " Weight Deviation")
        hold on
            Legend= {};
            [order samples] = size(Weights.(name).Weights);
            x = 1:length(Weights.(name).MSE);
            y = mag2db(abs(Weights.(name).MSE));
            plot(x,y,"-"); Legend{end+1} = "MSE";

            for n = 0:order-1
                y = mag2db(abs(Weights.(name).("MSE"+num2str(n))));
                plot(x,y, "--"); Legend{end+1} = "Tap " + num2str(n) + " SE";
            end

            legend(Legend);
            grid on; grid minor;

            xlabel("Sample Number")
            ylabel("Deviation (dB)")
        hold off
    end

end

