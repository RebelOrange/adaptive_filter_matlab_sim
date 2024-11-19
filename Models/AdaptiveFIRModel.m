function [signalsOut] = AdaptiveFIRModel(signalsIn, options)
arguments
    signalsIn 
    options.Type string = "LMS";
    options.LearningRate double = 0.4;
    options.DataType = "double"
    options.FilterOrder = 10;

end
    signalsOut = signalsIn;

    switch options.Type
        case "LMS"
            main_in = signalsIn.main_0.I + 1i.*signalsIn.main_0.Q;
            aux_in = signalsIn.aux_0.I + 1i.*signalsIn.aux_0.Q;
            [e, y, W] = LMS(main_in, aux_in, "FilterOrder",options.FilterOrder, "mu", options.LearningRate,"Datatype",options.DataType, "WeightDecBits",32, "WeightIntBits", 16);
            signalsOut.main_0.I = real(e);
            signalsOut.main_0.Q = imag(e);
            signalsOut.main_0.Weights = W;
            signalsOut.aux_0.I = real(y);
            signalsOut.aux_0.Q = imag(y);
            signalsOut.main_0.Name = "Matlab LMS";
            signalsOut.main_0.Antenna = "Output";
            signalsOut.aux_0.Name = "Matlab Aux";
            signalsOut.aux_0.Antenna = "Interference Estimate";
        case "NLMS"
            main_in = signalsIn.main_0.I + 1i.*signalsIn.main_0.Q;
            aux_in = signalsIn.aux_0.I + 1i.*signalsIn.aux_0.Q;
            [e, y, W] = NLMS(main_in, aux_in, "FilterOrder",options.FilterOrder, "mu", options.LearningRate,"Datatype",options.DataType, "WeightDecBits",32, "WeightIntBits", 16);
            % lms = dsp.LMSFilter(options.FilterOrder,"Method","Normalized LMS");
            % [y, e, W] = lms(aux_in.', main_in.');
            signalsOut.main_0.I = real(e);
            signalsOut.main_0.Q = imag(e);
            signalsOut.main_0.Weights = W;
            signalsOut.aux_0.I = real(y);
            signalsOut.aux_0.Q = imag(y);
            signalsOut.main_0.Name = "Matlab NLMS";
            signalsOut.main_0.Antenna = "Output";
            signalsOut.aux_0.Name = "Matlab NLMS";
            signalsOut.aux_0.Antenna = "Interference Estimate";
        case "LMF"
            main_in = signalsIn.main_0.I + 1i.*signalsIn.main_0.Q;
            aux_in = signalsIn.aux_0.I + 1i.*signalsIn.aux_0.Q;
            [e, y, W] = LMF(main_in, aux_in, "FilterOrder",options.FilterOrder, "mu", options.LearningRate,"Datatype",options.DataType, "WeightDecBits",32, "WeightIntBits", 16);
            signalsOut.main_0.I = real(e);
            signalsOut.main_0.Q = imag(e);
            signalsOut.main_0.Weights = W;
            signalsOut.aux_0.I = real(y);
            signalsOut.aux_0.Q = imag(y);
            signalsOut.main_0.Name = " LMF Main ";
            signalsOut.aux_0.Name = " LMF Aux ";
        case "NLMF"
            main_in = signalsIn.main_0.I + 1i.*signalsIn.main_0.Q;
            aux_in = signalsIn.aux_0.I + 1i.*signalsIn.aux_0.Q;
            [e, y, W] = LMF(main_in, aux_in, "FilterOrder",options.FilterOrder, "mu", options.LearningRate,"Datatype",options.DataType, "WeightDecBits",32, "WeightIntBits", 16);
            signalsOut.main_0.I = real(e);
            signalsOut.main_0.Q = imag(e);
            signalsOut.main_0.Weights = W;
            signalsOut.aux_0.I = real(y);
            signalsOut.aux_0.Q = imag(y);
            signalsOut.main_0.Name = " NLMF Main ";
            signalsOut.aux_0.Name = " NLMF Aux ";
        case "MOLS"
            main_in = signalsIn.main_0.I + 1i.*signalsIn.main_0.Q;
            aux_in = signalsIn.aux_0.I + 1i.*signalsIn.aux_0.Q;
            [e, y, W] = MOLS(main_in, aux_in, "FilterOrder",options.FilterOrder, "Datatype",options.DataType, "WindowSize",200);
            signalsOut.main_0.I = real(e);
            signalsOut.main_0.Q = imag(e);
            signalsOut.main_0.Weights = W;
            signalsOut.aux_0.I = real(y);
            signalsOut.aux_0.Q = imag(y);
            signalsOut.main_0.Name = " MOLS Main ";
            signalsOut.aux_0.Name = " MOLS Aux ";

        case "Wiener"
            main_in = signalsIn.main_0.I + 1i.*signalsIn.main_0.Q;
            aux_in = signalsIn.aux_0.I + 1i.*signalsIn.aux_0.Q;
            [e, y, W] = Wiener(main_in, aux_in, "FilterOrder",options.FilterOrder, "mu", options.LearningRate,"Datatype",options.DataType);
            signalsOut.main_0.I = real(e);
            signalsOut.main_0.Q = imag(e);
            signalsOut.main_0.Weights = W;
            signalsOut.aux_0.I = real(y);
            signalsOut.aux_0.Q = imag(y);
            signalsOut.main_0.Name = "Wiener";
            signalsOut.main_0.Antenna = "Output";
            signalsOut.aux_0.Name = "Wiener";
            signalsOut.aux_0.Antenna = "Interference Estimate";
        otherwise

    end


end

