function [filterStruct] = FIRDesigner(wl, wu, N)
    arguments
        wl = 0
        wu =0.5.* pi
        N = 50
    end
    % the inverse discrete forier transform response of a filter from 0 - wc
    % is sin (n * wc )/ n/pi , where n = -N /2 - N /2
    % setup shift bounds based on lowpass filter width
    w_lower = wl ;
    w_upper = wu ;
    w_width = w_upper - w_lower ;
    w_shift = w_lower + w_width ./2;
    % set the filter order to even
    if mod (N ,2)
        N = N +1;
    end
    n = -N /2: N /2;
    wc = w_width ./2;
    h_d = sin (n .* wc )./ n ./ pi ;
    zero_n = find ( n ==0);
    h_d ( zero_n ) = wc ./ pi ; %l ’ hopitals rule
    % only frequency shift if the lower bound is not 0
    if ( wl ~= 0)
        h = h_d .* exp (j .* w_shift .* n );
    else 
        h = h_d;
    end

    filterStruct.Coefs = h;
    filterStruct.LowerBoundNorm = wl./pi;
    filterStruct.UpperBoundNorm = wu./pi;
    filterStruct.Order = N;
    
end

