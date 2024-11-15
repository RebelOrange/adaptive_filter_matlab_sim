function [e, y, w] = NLMF(d, x, options)
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
    mu = HLS.ap_fixed( options.mu , wBits, wM, "OverrideToDouble", HLSDoubleFlag);
    mu = mu;

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
        %quantize multipliers
        w_i = HLS.ap_fixed( w_i , wBits, wM, "OverrideToDouble", HLSDoubleFlag);

        alpha = 0.5;
        norm = (1-alpha).*u'*u + alpha.* conj(e(i)).*e(i);
        % norm = (w_i'*w_i).^2;
        w(:,i+1) = w_i + 2 .* mu./norm .* (conj(e(i)).*(e(i)).*conj(e(i))) .* u;
        w(:,i+1) = HLS.ap_fixed( w(:,i+1) , wBits, wM, "OverrideToDouble", HLSDoubleFlag);
    end

    e = HLS.ap_fixed( e , sigBits, sigM, "OverrideToDouble", HLSDoubleFlag); % quantize final output
end

