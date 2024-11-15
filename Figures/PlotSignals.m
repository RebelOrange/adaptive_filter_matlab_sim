function [signalsIn] = PlotSignals(varargin)

    for i = 1:nargin
        signalsIn = varargin{i};
        names = fieldnames(signalsIn);
    
        for name = 1:numel(names)
            signal = signalsIn.(names{name});
            switch signal.Source
                case "SDR DDC"
                    % plot Figures for IQ analysis
                    PlotIQ(signal)
    
                case "Freespace"
                    PlotFreespace(signal)
    
                case "Antenna"
                    PlotAntenna(signal)
    
                case "Reciever"
                    PlotRx(signal)

                case "FixedSignal"
                    PlotRx(signal)
            end
    
    
        end
    end
end

