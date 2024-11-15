function [signalsOut] = FreespaceModel(signalsIn)
    %Passthrough
    signalsOut = signalsIn;
    names = fieldnames(signalsOut);
    
    for name = 1:numel(names)
        signal = signalsIn.(names{name});
        % apply oneway friis transmission equation using range from signal struct
        % assume signal is unity power
        % signal units will be in power density W/m^2?
        signal.TimeSeries = signal.TransmitPower ./(4.*pi.*signal.Range.^2) .* signal.TimeSeries; 

        signal.Source = "Freespace";
        signal.Destination = "Antenna";
        signal.Name = "Freespace";

        signalsOut.(names{name}) = signal;
    end
end