function [signalOut] = GenerateNoise(signalIn)
    % copy input parameters to output parameters
    signalOut = signalIn;
    
    % using samplerate and pulsewidth, define time data
    Nsamps = signalIn.SampleRate .* signalIn.PulseWidth;
    signalOut.TimeSamples = 0:1./signalIn.SampleRate:signalIn.PulseWidth;

    % generate white noise and filter to bandwidth
    %TODO: add bandwidht filter
    noise = randn(size(signalOut.TimeSamples));

    % filter noise at center freq
    % normalize center freq and bandwidth
    if (signalIn.Bandwidth ~= 10e6)
        bwNorm = signalIn.Bandwidth./(signalIn.SampleRate./2).*pi;
        cfNorm = signalIn.CenterFreq./(signalIn.SampleRate./2).*pi;
    
        firCoef = 2.*real(FIRdesign(cfNorm-bwNorm./2, cfNorm+bwNorm./2,10000, 1));
        noise = filtfilt(firCoef,1,noise);
    end
    signalOut.TimeSeries = noise;
end

