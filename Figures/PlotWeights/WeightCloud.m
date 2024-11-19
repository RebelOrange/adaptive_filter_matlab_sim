function [] = WeightCloud(Weights, figureConfig)
    filters = fieldnames(Weights);
    
    for filter = 1:numel(filters)
    name = filters{filter};
    if name =="Wiener"; continue; end
    figure("Name",name + " Weight Cloud");
    title(Weights.(name).Name + " Complex Weight Convergence")
    hold on
    Legend = {};
        [order, N]  = size(Weights.(name).Weights);
        for n = 0:order-1
            x = real(Weights.(name).Weights(n+1,figureConfig.StartIndex:end));
            y = imag(Weights.(name).Weights(n+1,figureConfig.StartIndex:end));
            scatter(x,y,'.'); Legend{end+1} = Weights.(name).Name + " Tap " +num2str(n); 


            if (length(Weights.(name).Weights(1,:))>1500)
                x = mean(real(Weights.(name).Weights(n+1,(end-1000):end)));
                y = mean(imag(Weights.(name).Weights(n+1,(end-1000):end)));
                % disp(sprintf(Weights.(name).Name +" Real Variance: %d",var(real(Weights.(name).Weights(n+1,(end-1000):end)))))
                % disp(sprintf(Weights.(name).Name +" Imag Variance: %d",var(imag(Weights.(name).Weights(n+1,(end-1000):end)))))
            else
                x = mean(real(Weights.(name).Weights(n+1,(end-500):end)));
                y = mean(imag(Weights.(name).Weights(n+1,(end-500):end)));
                % disp(sprintf(Weights.(name).Name +" Real Variance: %d",var(real(Weights.(name).Weights(n+1,(end-500):end)))))
                % disp(sprintf(Weights.(name).Name +" Imag Variance: %d",var(imag(Weights.(name).Weights(n+1,(end-500):end)))))
            end
            
        end

        shapes = {"o","square","^"};
        for n = 0:order-1
            x = real(Weights.Wiener.Weights(n+1,:));
            y = imag(Weights.Wiener.Weights(n+1,:));
            scatter(x,y, shapes{n+1}+"k",'filled');Legend{end+1} = "Wiener Tap " +num2str(n); 

            if (length(Weights.(name).Weights(1,:))>1500)
                x = [real(Weights.Wiener.Weights(n+1,:)), mean(real(Weights.(name).Weights(n+1,(end-1000):end)))];
                y = [imag(Weights.Wiener.Weights(n+1,:)), mean(imag(Weights.(name).Weights(n+1,(end-1000):end)))];
            else
                x = [real(Weights.Wiener.Weights(n+1,:)), mean(real(Weights.(name).Weights(n+1,1:end)))];
                y = [imag(Weights.Wiener.Weights(n+1,:)), mean(imag(Weights.(name).Weights(n+1,1:end)))];
            end
            plot(x,y,'-r'); Legend{end+1} = "";
            
        end

        grid on; grid minor
        xlabel("Real Part")
        ylabel("Imag Part")
        axLim = 1.2;
        xlim([-axLim axLim])
        ylim([-axLim axLim])
        legend(Legend);
    hold off
end

