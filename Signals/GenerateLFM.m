function [signalOut] = GenerateLFM(signalIn)
    % copy input parameters to output parameters
    signalOut = signalIn;

    % use bandwidth and ceneter frequency to generate signal model:
    % x(t) = sin(phi(0) + phi(t))
    %       * phi(0) = initial condition
    %       * phi(t) = 2pi(delf/delt/2 * t^2 + f0*t)
    %
    %   where delf = f1 - f0
    %         delt = pulsewidth
    %         

    del_f = signalIn.Bandwidth;
    f0 = signalIn.CenterFreq - signalIn.Bandwidth/2;
    del_t = signalIn.PulseWidth;
    
    % using samplerate and pulsewidth, define time data
    Nsamps = signalIn.SampleRate .* signalIn.PulseWidth;
    signalOut.TimeSamples = 0:1./signalIn.SampleRate:signalIn.PulseWidth;

    % use LFM equation with time samples
    phi_0 = 0;
    phi_t = 2.*pi.* ( del_f ./ del_t ./ 2 .* signalOut.TimeSamples.^2 + f0.*signalOut.TimeSamples);
    signalOut.TimeSeries = sin(phi_0 + phi_t);
    
end

