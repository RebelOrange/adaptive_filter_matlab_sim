function [signalsOut, BeamPatterns] = BeamPatternModel(signalsIn, options)
arguments
    signalsIn 
    options.GainOffsetdB = 10; 
end
    signalsOut = signalsIn;
    names = fieldnames(signalsOut);
    
    
    for name = 1:numel(names)
        signal = signalsIn.(names{name});
        
        %generic beam pattern, need to adjust later
        if contains(names{name}, "main")
            bp = abs(fft(ones([10, 1]), length(signal.AzPoints)))+db2mag(options.GainOffsetdB);
        elseif contains(names{name}, "aux")
            bp = abs(fft(ones([2, 1]), length(signal.AzPoints)))+db2mag(options.GainOffsetdB);
        else
            bp = abs(fft(ones([1, 1]), length(signal.AzPoints)))+db2mag(options.GainOffsetdB);
        end

        superPos = 0;
        for antenna = 1:numel(names)
            [az, azInd] = FindNearest(signalsIn.(names{antenna}).Azimuth, signal.AzPoints);
            gain = bp(azInd);
    
            % finish friis equation with gain
            superPos = superPos + gain.* (signal.Lambda.^2 ./ (4.*pi))  .* signalsIn.(names{antenna}).TimeSeries;
        end
        signal.TimeSeries = superPos;

        BeamPatterns.(names{name}).Pattern = bp;
        BeamPatterns.(names{name}).AzPoints = signal.AzPoints;
        BeamPatterns.(names{name}).Source = "plot_pattern";

        signal.Source = "Antenna";
        signal.Destination = "Reciever";
        signal.Name = "Beampattern";
        signal.Patterns = BeamPatterns;

        signalsOut.(names{name}) = signal;
    end
end