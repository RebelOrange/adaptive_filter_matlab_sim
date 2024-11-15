function [signalOut] = Digitize(signalIn, options)
arguments
    signalIn 
    options.FullscaleVoltage = 1;
    options.ENOB = 13;

end
    disp(sprintf("Minimum voltage: %d (Peak: %d, signed ENOB: %d)", options.FullscaleVoltage./(2.^(options.ENOB-1)-1), options.FullscaleVoltage, options.ENOB-1))

    signalOut = HLS.ap_fixed(signalIn./options.FullscaleVoltage .* (2.^(options.ENOB-1) -1));
    


end

