function [SDR] = GetSDRStruct(options)
    arguments
        options.ClockFreq double = 200e6;
        options.IQRate double = 3.125e6;
    end

    SDR.ClockFreq = options.ClockFreq;
    SDR.IQRate = options.IQRate;
end

