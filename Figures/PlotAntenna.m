function [] = PlotAntenna(signalIn)
    fig = figure(Name = signalIn.Source + signalIn.Name + signalIn.Type);
    clf
    tiledlayout(2,1);
    PlotRF(signalIn)

    
end

