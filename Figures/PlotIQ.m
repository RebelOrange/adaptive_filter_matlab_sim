function [] = PlotIQ(signalIn)
    plotdata = signalIn.I + 1i.*signalIn.Q;
    plotdata(isnan(plotdata)) = 0;
    tsamp = signalIn.TimeSamplesIQ;
    Fs = signalIn.SampleRate;

    % stft data
    [z, f, t] = stft(plotdata,Fs, "FFTLength", 128, "OverlapLength", 96, ...
        "Window", kaiser(128,0.5));
    tCorrect = 1e6;

    % fft data
    Npoint = length(tsamp);
    x = linspace(-Fs./2./1e6, Fs./2./1e6, Npoint);
    y = fftshift(fft(plotdata(length(tsamp)./6:end), Npoint)./Npoint);
    y = mag2db(abs(y));


    fig = figure(Name = signalIn.Source + signalIn.Name + signalIn.Type);
    fig.Position = [680 385 813 613];
    clf
    subplot(3,1,[2, 1])
    sgtitle(signalIn.Name +": " + signalIn.Antenna)
    if false
        hold on
            waterfall(f./1e6, t.*tCorrect, mag2db(abs(z)).')
            xlabel("Frequency (MHz)")
            ylabel("Time (\mu sec)")
            zlabel("Magnitude (dB)")
            view(-225, 60)
        hold off
    else
        hold on
            title("STFT")
            imagesc(t.*tCorrect, f./1e6, mag2db(abs(z)))
            colorbar
            ax = gca;
            axis xy
    
            ylabel("Frequency (MHz)")
            xlim([min(t.*tCorrect) max(t.*tCorrect)])
            ylim([min(f./1e6) max(f./1e6)])
    
                axes(Position=[0.59 0.44 0.3 0.2]);
                box on
                plot(x, y)
                grid on; grid minor;
                xlabel("Frequency (MHz)")
                ylabel("Magnitude (dB)")
                xlim([min(f./1e6) max(f./1e6)])
                
            
    
        hold off
    end
    subplot(3,1,3)
    hold on
        title("Timeseries")
        x = signalIn.TimeSamplesIQ;
        y = signalIn.Q;

        stem(x.*tCorrect, y)
        % ylim([-2^14, 2^14]);

        xlabel("Time (\musec)")
        ylabel("Amplitude (int16)")
        grid on; grid minor;
    hold off
end

