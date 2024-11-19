function [] = FinalWeights(Weights)
    filters = fieldnames(Weights);
    figure("Name", "Final Weights")
    hold on
        title("Final Weight Magnitudes")
        Legend = {};
            colors = {'b','m','m'};
        for filter = 1:numel(filters)
            name = filters{filter};

            [order, N]  = size(Weights.(name).Weights);
            if order ==1
                y = [abs(Weights.(name).Weights); zeros(order,N)];
            else
                y = abs(Weights.(name).Weights);
            end

            if name =="Wiener"
                for i = 1:order
                    scatter((i-1).*ones(size(y(i,:))),y(i,:), 'k^','filled','MarkerEdgeAlpha',1); 
                    if i == 1; Legend{end+1} = Weights.(name).Name;
                    else; Legend{end+1} = "";
                    end 
                end
            else
                for i = 1:order
                    scatter((i-1).*ones(size(y(i,1:end-1))),y(i,1:end-1), colors{filter}, 'MarkerEdgeAlpha',0.05); Legend{end+1} = "";
                    scatter((i-1).*ones(size(y(i,end))),y(i,end), colors{filter}, 'MarkerEdgeAlpha',1); Legend{end+1} = Weights.(name).Name;
                   
                end
            end
            
            
        end

        legend(Legend);
        grid on;
        grid minor;
        xlabel("Filter Tap")
        ylabel("Magnitude |w|")
    hold off
end

