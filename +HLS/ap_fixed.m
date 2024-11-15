function [decVal, intVal, error, binStr] = ap_fixed(x, bits, m, options)
arguments
    x 
    bits = 16; %use 16 bits for quantization
    m = 16; %default all bits to max if not specified
    options.OverrideToDouble = 0;
end

    if options.OverrideToDouble
        % just return all values and dont quantize
        decVal = x;
        intVal = 0;
        error = 0;
        binStr = "";
        return
    end


% use Qm.n format for signed values
    n = bits - m;
    val = x.*(2.^n);
    maxVal =  (2.^(m+n-1) - 1);
    minVal =  -(2.^(m+n-1));

    for i = 1:numel(x)
        if floor(val(i)) < minVal
            val(i) = -(2.^(m+n-1));
        elseif floor(val(i)) > maxVal
            val(i) = (2.^(m+n-1)-1);
        end
    end

    decVal = floor(val)./(2.^n);
    intVal = floor(val);

    binStr = nan(numel(x), bits);
    for i = 1:numel(x)
        dummyStr = dec2bin(real(intVal(i)), m+n);
        if numel(dummyStr) ~= (m+n)
            % error("Converting to bin with %d bits failed. Actual bits: %d", m+n, numel(binStr(i,:)))
        end
        binStr(i,:) = dummyStr((end-bits+1):end);
    end

    error = x - decVal;

end

