function [] = PlotRx(signalIn)
    figure("Name","Reciever Signals")
    clf
    tiledlayout(2,1)    
        PlotRF(signalIn)

end

