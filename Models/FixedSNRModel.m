function [signalsOut] = FixedSNRModel(signalsIn, options)
arguments
    signalsIn 
    
    options.SNR = 10;
    options.SIR = 20;
    options.SINR = 0;
    options.Leakage = 40;
    options.PhaseAngle = 0;

    options.NoiseAmplitude = 10;
end
    signalsOut = signalsIn;
    names = fieldnames(signalsIn);

    % define antenna gains
    G_m = abs(fft(ones([10, 1]), length(signalsIn.(names{1}).AzPoints)));
    G_a = abs(fft(ones([2, 1]), length(signalsIn.(names{1}).AzPoints)));

    [az, azIndMain] = FindNearest(signalsIn.main_0.Azimuth, signalsIn.main_0.AzPoints);
    [az, azIndAux] = FindNearest(signalsIn.aux_0.Azimuth, signalsIn.aux_0.AzPoints);

    gain_m_main = G_m(azIndMain);
    gain_m_aux = G_m(azIndAux);
    gain_a_main = G_m(azIndMain);
    gain_a_aux = G_m(azIndAux);

    disp(sprintf("Main Antenna Gains: desired %d, interference %d", mag2db(gain_m_main), mag2db(gain_m_aux)));
    disp(sprintf("Aux Antenna Gains: desired %d, interference %d", mag2db(gain_a_main), mag2db(gain_a_aux)));

    noise_gain = options.NoiseAmplitude;
    A = db2pow(options.SNR).*options.NoiseAmplitude;
    B = A./db2pow(options.SIR);
    D = A/db2pow(options.Leakage);

    A0 = A./gain_m_main;
    B0 = B./gain_m_aux;
    D0 = A0;
    E0 = B0;
    E = E0.*gain_a_aux;
    
    disp(sprintf("Main Channel Powers: \n   A (main) %d \n  B (aux): %d", mag2db(A), mag2db(B)));
    disp(sprintf("Aux Channel Powers: \n   D (main) %d \n  E (aux): %d", mag2db(D), mag2db(E)));


    % perform linear combination
    % TODO: Make automatic?
    signalsOut.main_0.TimeSeries = (gain_m_main.*A0).*signalsIn.main_0.TimeSeries + ...
                        (gain_m_aux.*B0).*signalsIn.aux_0.TimeSeries + ...
                        (noise_gain).*randn(size(signalsIn.main_0.TimeSeries));


    signalsOut.aux_0.TimeSeries = (D).*signalsIn.main_0.TimeSeries + ...
                        (gain_a_aux.*E0).*signalsIn.aux_0.TimeSeries + ...
                        (noise_gain).*randn(size(signalsIn.main_0.TimeSeries));

    % phase shift by theta degrees
    d = signalsIn.main_0.Lambda./2;
    aoa = options.PhaseAngle;
    aoa_rad = aoa.*pi./180;
    t_phase = (d.*sin(aoa_rad)./physconst("LightSpeed"));
    n_0 = t_phase.*signalsIn.main_0.SampleRate;

    % use FFT property to do phase shift in fourier domain
    N = length(signalsOut.aux_0.TimeSeries);
    omega = 2.*pi./N .*(0:N-1);
    y = signalsOut.aux_0.TimeSeries;
    Y_aux = fft(signalsOut.aux_0.TimeSeries);
    Y_aux_shift = exp(-1i.*(omega).*n_0).*Y_aux;
    new_y = ifft(Y_aux_shift, "symmetric");
    disp(sprintf("Delaying Aux channel by fractional samples: %d", n_0));
    signalsOut.aux_0.TimeSeries = real(new_y);


    signalsOut.main_0.Source = "FixedSignal";
    signalsOut.aux_0.Source = "FixedSignal";

end

