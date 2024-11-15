function [] = PlotWeights(Weights)
    filters = fieldnames(Weights);

    figure("Name", "Weight Error")
    hold on
        Legend= {};
        for filter = 1:numel(filters)
            name = filters{filter};
            if name == "Wiener"; continue; end
            x = 1:length(Weights.(name).MSE);
            y = mag2db(abs(Weights.(name).MSE));
            plot(x,y); Legend{end+1} = name;

        end

        legend(Legend);
    hold off

    figure("Name", "Final Weights")
    hold on
        Legend = {};
        for filter = 1:numel(filters)
            name = filters{filter};

            colors = {'b','c','m'};
            [order, N]  = size(Weights.(name).Weights);
            if order ==1
                y = [abs(Weights.(name).Weights); zeros(order,N)];
            else
                y = abs(Weights.(name).Weights);
            end

            if name =="Wiener"
                for i = 1:order
                    stem(i.*ones(size(y(i,:))),y(i,:), 'k^','filled'); 
                    if i == 1; Legend{end+1} = name;
                    else; Legend{end+1} = "";
                    end 
                end
            else
                for i = 1:order
                    stem(i.*ones(size(y(i,:))),y(i,:), colors{filter}); 
                    if i == 1; Legend{end+1} = name;
                    else; Legend{end+1} = "";
                    end 
                end
            end
            
            
        end

        legend(Legend);
    hold off
end

