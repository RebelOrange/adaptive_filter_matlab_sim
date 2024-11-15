function [signalsOut] = RecieverModel(signalsIn, options)
arguments
    signalsIn 
    options.GaindB = 0; %db 
end

    % Rx TODO: LNA -> Mixer -> image rejection -> ...
    names = fieldnames(signalsIn);

    signalsOut = signalsIn;

    % receiver noise and bandwidth, kTB
    k = physconst("Boltzmann");
    T = 290; %K, standard temp of antenna
    B = 1e6; 

    disp(sprintf("Noise Power: %d dB", pow2db(k.*T.*B)));
    
    %override and set minimum noise floor:
    noise_pow = pow2db(k.*T.*B);
    noise_floor_min = -40;
    delta_gain = noise_floor_min - noise_pow;

    % generate bandlimited kTB at Center freq


    % Mixer model
    % TODO: downconversion
    IFFreq = 30e6;
    LOFreq = signalsIn.(names{1}).CenterFreq - IFFreq;
    for name = 1:numel(names)
        signal = signalsIn.(names{name});

        noise_freq = signal.CenterFreq;
        noise_bw = B;
        noise_FS = signal.SampleRate;
        noiseMult = sqrt(k.*T.*B.*50); % P*R = V^2
        noise = randn(size(signal.TimeSeries));
        noiseFilter = FIRDesigner((noise_freq - noise_bw./2)./noise_FS.*pi, (noise_freq + noise_bw./2)./noise_FS.*pi, 500);
        bandLimitedNoise = real(noiseMult .* filter(noiseFilter.Coefs, 1, noise));

        t = signal.TimeSamples;
        signal.TimeSeries = db2mag(delta_gain).*(signal.TimeSeries + bandLimitedNoise);
        signal.TimeSeries = signal.TimeSeries .* cos(2.*pi.*LOFreq .* t);

        fracCenterFreq = 2.0;
        normalizedPassband = fracCenterFreq .* signal.CenterFreq./signal.SampleRate.*pi;
        firStruct = FIRDesigner(0, normalizedPassband, 500);
        signal.TimeSeries = db2mag(options.GaindB) .* filter(firStruct.Coefs, 1, signal.TimeSeries);

        % assign new parameters
        signal.CenterFreq = LOFreq;
        
        signalsOut.(names{name}) = signal;
    
        signalsOut.(names{name}).Source = "Reciever";
        signalsOut.(names{name}).Destination = "SDR";
        signalsOut.(names{name}).Name = "Reciever";

        %debug figure
        if false
            figure(1000)
            hold on
            Npoint = 4096;
                x = linspace(-signal.SampleRate./1e9, signal.SampleRate./1e9, Npoint);
                y = fftshift(fft(signal.TimeSeries, Npoint)./Npoint);
                y = mag2db(abs(y));
                plot(x,y)

                y = fftshift(fft(firStruct.Coefs, Npoint)./Npoint);
                y = mag2db(abs(y));
                plot(x,y);

                grid on; grid minor;
            hold off

        end
    end

end