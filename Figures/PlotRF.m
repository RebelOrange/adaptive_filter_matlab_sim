function [] = PlotRF(signalIn)
    nexttile
    hold on
        title("FFT")
        Npoint = length(signalIn.TimeSamples);
        x = linspace(-signalIn.SampleRate./1e9, signalIn.SampleRate./1e9, Npoint);
        y = fftshift(fft(signalIn.TimeSeries, Npoint)./Npoint);
        y = mag2db(abs(y));

        plot(x, y)
        
        xlabel("Frequency (GHz)")
        ylabel("Magnitude (dB)")
        grid on; grid minor;

    hold off
    nexttile
    hold on
        title("Timeseries")
        x = signalIn.TimeSamples.*1e6; %usec
        y = signalIn.TimeSeries;

        plot(x, y);

        xlabel("Time (\musec)")
        ylabel("Amplitude")

        grid on; grid minor;
    hold off
end

