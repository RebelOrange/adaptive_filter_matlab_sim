function [e, y, w] = LMS(d, x, options)
arguments
    d 
    x 
    options.FilterOrder = 10;
    options.mu double = 0.4;
    options.Datatype string = "double"

    options.WeightIntBits = 32;
    options.WeightDecBits = 32;
    options.InputIntBits = 16;
    options.InputDecBits = 0;
end
    % flag for overriding HLS.ap_fixed to be double type
    if options.Datatype == "double"
        HLSDoubleFlag = 1;
    else
        HLSDoubleFlag = 0;
    end
    
    wBits = options.WeightDecBits + options.WeightIntBits;
    wM = options.WeightIntBits;
    sigBits = options.InputDecBits + options.InputIntBits;
    sigM = options.InputIntBits;
    % d = d.';
    % x = x.';


    % all multiply operations must have ap_fixed after
    p = toeplitz(x)*d';
    p = p(1:options.FilterOrder);
    xDataMatrix = DataMatrix(x,options.FilterOrder);
    Rref = xDataMatrix*xDataMatrix';
    RpsuedoInv = inv(conj(Rref)*Rref)*conj(Rref);
    w = (RpsuedoInv*p);
    % disp(Rref);

    y = filter(w,1,x);
    e = d-y;

    function [dataMatrix] = DataMatrix(x,lags)
        dataMatrix = zeros([lags, numel(x)+lags-1]);
        for i=1:lags
            dataMatrix(i,i:numel(x)+i-1) = x;
        end
    end
    
end

