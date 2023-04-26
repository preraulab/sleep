% function pinkNoiseFromData()
ccc
hold on
invfreq = .5;
scalefact = 4;

Fs = 200;
N = 60*10;

cn = dsp.ColoredNoise('InverseFrequencyPower',invfreq,'SamplesPerFrame',Fs*N);
y = cn()*scalefact;

% function [inv_power, scaling_factor] = estimate_colored_noise_parameters(y, Fs)
    % y: observed colored noise signal
    % Fs: sampling frequency of the observed signal
    
    N = length(y);
    f = (1:N/2) * Fs / N; % frequency vector
    
    % Compute the power spectral density (PSD) estimate of the observed signal
    [psd, ~] = pwelch(y, [], [], N, Fs);
    
%     % Estimate inv_power using linear regression in the log-log space
%     x = log(f)';
%     y = log(pxx(1:N/2));
%     b = x \ y;
%     inv_power = -b(1)
%     
%     % Compute scaling_factor using the maximum likelihood estimator
%      S = f.^(-inv_power);
%     w = 1 ./ pxx(1:N/2)';
%     scaling_factor = sqrt(mean(w .* y'.^2 ./ S))
% end
% Compute the slope of the linear regression of the log-log PSD
 [psd,f] = periodogram(y,rectwin(length(y)),length(y),Fs);

    log_f = log10(f(2:end)); % exclude f=0
    log_psd = log10(psd(2:end));
    p = polyfit(log_f,log_psd,1);

    % Extract the inverse frequency power and scaling factor
    inv_power = p(1)
    correction_factor = sqrt((1 - 2*inv_power)/(1 - inv_power));
    scaling_factor = 10^(p(2)) * correction_factor



% 
%  
%     N = length(y);
%     f = (0:N/2-1) * Fs / N; % frequency vector
%     
%     % Compute the power spectral density (PSD) estimate of the observed signal
%     [pxx, ~] = pwelch(y, [], [], [], Fs);
%     
%     % Define the negative log-likelihood function for inv_power
%     function nll = neg_log_likelihood_inv_power(inv_power)
%         S = f.^(-inv_power);
%         nll = -sum(log(1 ./ (sqrt(2*pi) * sqrt(S)) .* pxx));
%     end
%     
%     % Use fminsearch to maximize the likelihood function and estimate inv_power
%     inv_power = fminsearch(@neg_log_likelihood_inv_power, 1);
%     
%     % Define the maximum likelihood estimator for scaling_factor
%     S = f.^(-inv_power);
%     scaling_factor = sqrt(mean(y.^2 ./ S));
% end
