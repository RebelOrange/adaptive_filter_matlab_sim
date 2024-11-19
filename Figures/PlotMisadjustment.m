function [] = PlotMisadjustment(varargin)

    Wiener = varargin{1}.main_0.I + 1i.*  varargin{1}.main_0.Q ;
    for i = 2:nargin
        signalsIn = varargin{i};
        names = fieldnames(signalsIn);
        
        sig = signalsIn.main_0.I + 1i.* signalsIn.main_0.Q;

        misAd = abs(sig).^2./(abs(Wiener(1:length(sig))).^2);

        figure("Name",signalsIn.main_0.Name + signalsIn.main_0.Antenna + "Misadjustment")
        hold on
            title(signalsIn.main_0.Name + " Misadjustment")
            plot(mag2db(misAd));

            xlabel("Sample Index")
            ylabel("Misadjustment (dB)")
            grid on; grid minor;
        hold off
    end
end

