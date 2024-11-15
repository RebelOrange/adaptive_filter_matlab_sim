function [nearestValue, index] = FindNearest(value, vector)
    %find when the square error is minimized
    errorSq = (value - vector).^2;
    index = find(min(errorSq)==errorSq, 1);
    nearestValue = vector(index);

end

