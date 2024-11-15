function [signalOut] = GenerateCos(signalIn)
    signalOut = signalIn;

    
    Nsamps = signalIn.SampleRate .* signalIn.PulseWidth;
    signalOut.TimeSamples = 0:1./signalIn.SampleRate:signalIn.PulseWidth;

    % use LFM equation with time samples
    signalOut.TimeSeries = cos(2.*pi.*signalIn.CenterFreq.*signalOut.TimeSamples);
    
end

