function [signalsOut] = SDRModel(signalsIn, options)
arguments
    signalsIn 
    options.ClockFreq double = 200e6;
    options.IQRate double = 5e6
    options.ADC = false;
    options.BasebandFreq double = 0e6;
end
    signalsOut = signalsIn;
    names = fieldnames(signalsIn);
    SDR = GetSDRStruct("ClockFreq",options.ClockFreq, "IQRate", options.IQRate);

    for name = 1:numel(names)
        signal = signalsIn.(names{name});
        %% digitize with quantization and SDR model
        % sample at clock freq
        Nsamps = length(signal.TimeSeries);
        adcFactor = round(signal.SampleRate./SDR.ClockFreq);
        adcArray = 1:adcFactor:Nsamps; % keep every X sample out of original arrays
        signal.TimeSeries = signal.TimeSeries(adcArray);
        signal.TimeSamples = signal.TimeSamples(adcArray);

        % quantize
        if options.ADC
            signal.TimeSeries = RFNoC.Digitize(signal.TimeSeries);
        end
        HLS.ap_fixed(signal.TimeSeries);
    

        %% downconvert to final IQ rate
        LOFreq = signal.CenterFreq - options.BasebandFreq; %TODO: build in baseband freq?

        % real part, multiply by cos(2*pi*LO*t) | imag part, multiply by -sin(2*pi*LO*t
        signal.I =  HLS.ap_fixed(signal.TimeSeries.*cos(2.*pi .* LOFreq .* signal.TimeSamples));
        signal.Q = HLS.ap_fixed(-signal.TimeSeries.*sin(2.*pi .* LOFreq .* signal.TimeSamples));

        % Image rejection LPF
        % images above the center freq should be rejected
        fracCenterFreq = 3.0;
        normalizedPassband = fracCenterFreq .* signal.CenterFreq./SDR.ClockFreq .*pi;
        firStruct = FIRDesigner(0, normalizedPassband, 100);
        signal.I = filter(firStruct.Coefs, 1, signal.I);
        signal.Q = filter(firStruct.Coefs, 1, signal.Q);
    
        % downsample again to IQ rate
        ddcFactor = round(SDR.ClockFreq./SDR.IQRate);
        ddcArray = 1:ddcFactor:length(signal.TimeSamples);
        signal.I = HLS.ap_fixed(signal.I(ddcArray));
        signal.Q = HLS.ap_fixed(signal.Q(ddcArray));
        signal.TimeSamplesIQ = signal.TimeSamples(ddcArray);

        % clean up parameters
        signal.CenterFreq = 0;
        signal.SampleRate = SDR.IQRate;
        signal.Source = "SDR DDC";
        signal.Destination = "";
        signal.Name = "IQ";

        signalsOut.(names{name}) = signal;

    end
    % signalsOut.aux_0.I = circshift(signalsOut.aux_0.I,-1);
    % signalsOut.aux_0.Q = circshift(signalsOut.aux_0.Q,-1);

    if true
        corrRF = xcorr(signalsOut.main_0.TimeSeries,signalsOut.aux_0.TimeSeries);
        corrRF = corrRF./max(corrRF);
        tRf = [-(signalsOut.main_0.TimeSamples(end:-1:2)), signalsOut.main_0.TimeSamples];
        x = signalsOut.main_0.I + 1i.* signalsOut.main_0.Q;
        y = signalsOut.aux_0.I + 1i.* signalsOut.aux_0.Q;
        corrIQ = xcorr(x,y);
        corrIQ = corrIQ./max(corrIQ);
        tIQ = [-(signalsOut.main_0.TimeSamplesIQ(end:-1:2)), signalsOut.main_0.TimeSamplesIQ];
       
        figure(10111);
        hold on
            plot(tRf, corrRF)
            plot(tIQ, corrIQ)

            grid on
            grid minor
            

        hold off
    end
end

