function [e, y, w] = NLMS(d, x, options)
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

    % all multiply operations must have ap_fixed after 
    % initial filter conditions
    u = zeros([options.FilterOrder,1]);
    w = zeros([options.FilterOrder, numel(d)]);
    d = HLS.ap_fixed(d, sigBits, sigM, "OverrideToDouble",HLSDoubleFlag);
    x = HLS.ap_fixed(x, sigBits, sigM, "OverrideToDouble",HLSDoubleFlag);

    for i = 1:numel(d)
        % pushback new x sample
        % for n = 1:options.FilterOrder-1
        %     u(n+1) = u(n);
            u(2:end) = u(1:(options.FilterOrder-1));
        % end
        u(1) = x(i);

        w_i = w(:,i);
        % filter implementation
        % inner product
        y(i) = w_i'*u; % hermitian inner product
        y(i) = HLS.ap_fixed( y(i) ,wBits, wM, "OverrideToDouble", HLSDoubleFlag); 

        % TODO:Direct Form MAC

        % TODO:systolic
        
        % subtract y to generate error
        e(i) = d(i) - y(i);
        e(i) = HLS.ap_fixed( e(i) , wBits, wM, "OverrideToDouble", HLSDoubleFlag); % hermitian inner product

        % update weight loop
        norm = 1./(eps + u'*u);
        norm =  HLS.ap_fixed( norm , wBits, wM, "OverrideToDouble", HLSDoubleFlag);
        w(:,i+1) = w_i + 2 .* options.mu .*norm .* conj(e(i)).* u;
        w(:,i+1) = HLS.ap_fixed( w(:,i+1) , wBits, wM, "OverrideToDouble", HLSDoubleFlag);
    end

    e = HLS.ap_fixed( e , sigBits, sigM, "OverrideToDouble", HLSDoubleFlag); % quantize final output
end

