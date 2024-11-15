function [e, y, w] = MOLS(d, x, options)

arguments
    d = randn([1,1000]);
    x = d;
    options.FilterOrder = 10;
    options.WindowSize = 50;
    options.Datatype string = "double"
    
end

    winSize = options.WindowSize;
    N = options.WindowSize; %+options.FilterOrder;
    
    M = options.FilterOrder;
    nIteration = floor(length(d)./N);
    A_H = zeros([M, N-M]);
    w = zeros(M,length(d));
    % pad X so it has zeros at the input at the end of the filter
    xx = [x, zeros([1,M])];
    y = zeros(size(d));
    y = zeros(size(d));
    w_hat = zeros([M,1]);

    for i = 1:nIteration
        n = ((i-1)*winSize+1):(i*winSize);
        w(:,n) = w_hat.*ones(size(w(1:M,n)));

        % least squares estimate
        % input data matrices
        for nn = n
            indx = (M+nn-1):-1:(1+nn-1);
            u_m = xx(indx).';
            A_H(1:M, nn-((i-1).*N)) = conj(u_m);
        end
        % for l = 1:M
        %     indx = n(1) + [(M-(l)):(N-l-1)];
        %     A_H(l,1:numel(indx)) = conj(x(indx));
        % end
        A = (A_H)';
        d_vec = d(n).';
        R = A_H*A;

        % filter data window with current weights
        y(n) = filter(w(:,n(1)),1,x(n));
        e(n) = d(n) - y(n);

        % update weights with LS solution
        % LS solution
        w_hat = flip(inv(A_H*A)*A_H*d_vec);

    end

    % clean up with final weights
    n = n(end):length(d);
    y(n) = filter(w(:,i),1,x(n));
    e(n) = d(n) - y(n);
    w(:,n) = w_hat.*ones(size(w(1:M,n)));
end

