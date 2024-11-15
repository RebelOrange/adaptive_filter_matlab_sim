function [h] = FIRdesign(wl, wu, N, FIGURES)
arguments
    wl = 0
    wu =0.5.*pi
    N = 50
    FIGURES = 0
end
% the inverse discrete forier transform response of a filter from 0-wc
    % is sin(n*wc)/n/pi, where n = -N/2 - N/2
    w_lower = wl;
    w_upper = wu;
    w_width = w_upper-w_lower;
    w_shift = w_lower+w_width./2;

    if mod(N,2)
        N = N+1;
    end
    n = -N/2:N/2;

    % h_lp = sin(n.*w_upper)./n./pi;
    % h_hp = sin(n.*w_lower)./n./pi;
    % zero_n = find(n==0);
    % h_lp(zero_n) = w_upper./pi; %l'hopitals rule
    % h_hp(zero_n) = w_lower./pi; %l'hopitals rule
    % h = conv(h_lp,h_hp);
    % return;


    wc = w_width./2;
    h_d = sin(n.*wc)./n./pi;
    zero_n = find(n==0);
    h_d(zero_n) = wc./pi; %l'hopitals rule

    if (wl ~= 0)
        h = h_d.*exp(j.*w_shift.*n);
    else
        h = h_d;
    end


    if FIGURES
        figure
        clf
        hold on
            stem(n, h_d);
            stem(n,h)
        hold off
    
        figure
        clf
        hold on
            x = linspace(-pi,pi, 512)./pi;
            y = mag2db(abs(fftshift(fft(h_d,512))));
            plot(x,y)
    
            x = linspace(-pi,pi, 512)./pi;
            y2 = mag2db(abs(fftshift(fft(h,512))));
    
            plot(x,y2)
            legend("Original (DC)", "Shifted")
            grid on; grid minor
        hold off
    end
end
