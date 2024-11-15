function [signalOut] = GenerateSignal(options)
    arguments
        options.CenterFreq double = 1e9;
        options.SampleRate double = 0;
        options.PulseWidth double = 100e-6;
        options.Bandwidth double = 1e6;
        options.TransmitPower double = 1000; % Watt
        options.Range double = 10000; % meters
        options.Azimuth double = 0; % offset from boresite, deg
        options.AzPoints double = linspace(0,360,4096);
        options.Type string = "Cos";
        options.Antenna string = "Main";
        options.Source string = "Model";
        options.Destination string = "Freespace";
        options.Name string = "Model Signal";
    end

    if options.SampleRate == 0
        options.SampleRate = 10.* options.CenterFreq;
    end
    signalOut.CenterFreq = options.CenterFreq;
    signalOut.Lambda = physconst("LightSpeed")./options.CenterFreq;
    signalOut.SampleRate = options.SampleRate;
    signalOut.PulseWidth = options.PulseWidth;
    signalOut.Bandwidth = options.Bandwidth;
    signalOut.TransmitPower = options.TransmitPower;
    signalOut.Range = options.Range;
    signalOut.Azimuth = options.Azimuth;
    signalOut.AzPoints = options.AzPoints;
    signalOut.Type = options.Type;
    signalOut.Antenna = options.Antenna;
    signalOut.Source = options.Source;
    signalOut.Destination = options.Destination;
    signalOut.Name = options.Name;

    switch options.Type
        case "LFM"
            signalOut = GenerateLFM(signalOut);

        case "Noise"
            signalOut = GenerateNoise(signalOut);

        case "Cos"
            signalOut = GenerateCos(signalOut);

        otherwise
            signalOut = GenerateCos(signalOut);
    end
end

