function signal = N2_EEG_sim(Fs, total_time, phase_pref)
if nargin == 0
    Fs = 200;
    total_time = 60*60*5;
    N2_EEG_sim(Fs, total_time, 0);
    return;
end

%Total number of time points
N = total_time*Fs;
t = (1:N)/Fs;


%% Generate K-Complexes
K_complexes = zeros(1,N);

%Set KC rate (events/minute) to be lambda of a Poisson process
kc_rate = 30;

%Generate Poisson events
kc_times = find(poissrnd(kc_rate/60/Fs, 1, N));
%Set min spacing between events
kc_min_separation = 2;

%Loop through all events and generate KCs
for ii = 1:length(kc_times)

    %Check for overlap
    if ii>1 && (kc_times(ii) - kc_times(ii-1))/Fs > kc_min_separation

        %Simulate KC waveform
        kc_duration = 2;
        kc_amp = 10*(rand + .5);
        kc_t = linspace(0,kc_duration,kc_duration*Fs);

        kc = sin(.75*2*pi*kc_t) .* hanning(length(kc_t))'*kc_amp;

        %Add KC to time series
        inds = kc_times(ii):min((kc_times(ii)+length(kc)-1), N);
        K_complexes(inds) = K_complexes(inds) + kc(1:length(inds));
    end
end

%% Generate "slow" and "delta" waveforms by spline interpolation

%Create low-res random ~1Hz noise
slow_rnd = randn(1,N/60/Fs*120)*2;
slow_rnd([1 end]) = 0; %Keep spline well-behaved

%Interpolate the noise to make a slow component
slow = interp1(linspace(1,N,length(slow_rnd)),slow_rnd,1:N,'spline');


%Create low-res random ~1Hz noise
delta_rnd = randn(1,N/60/Fs*120*5)*1;
delta_rnd([1 end]) = 0; %Keep spline well-behaved

%Interpolate the noise to make a slow component
delta = interp1(linspace(1,N,length(delta_rnd)),delta_rnd,1:N,'spline');

%% Generate colored noise
%1/f^alpha
alpha_exp = 1.5;

cn = dsp.ColoredNoise('SamplesPerFrame',N, 'InverseFrequencyPower', alpha_exp);
noise = cn();

%Create signal and zero mean
signal = K_complexes + slow + delta + noise';


%% Generate spindles
spindles = zeros(1,N);

%Set phase pref and max prob
if nargin<3 || isempty(phase_pref)
phase_pref = pi;
end

%Set spindle rate (events/minute) to be lambda of a Poisson process
spindle_density = 15;

%Set random SO-pow by filtering white noise at SO range
SO_power = quickbandpass(signal,Fs,[.3 1.5]);

%Extract SO-phase
SO_phase = angle(hilbert(SO_power));

%Set peak probability
prob_peak = cos(SO_phase-phase_pref)/2 + .5;

%Generate Poisson events
spindle_inds = poissrnd(prob_peak/Fs/60*spindle_density*2,1,N)>0;
spindle_times = find(spindle_inds);
spindle_phase = SO_phase(spindle_inds);

%Set min spacing between events
spindle_min_separation = 3;

%Loop through all events and generate spindles
for ii = 1:length(spindle_times)
    %Check for overlap
    if ii>1 && (spindle_times(ii) - spindle_times(ii-1))/Fs > spindle_min_separation

        %Simulate spindle waveform
        spindle_duration = rand*1.5 + .5;
        spindle_amp = rand + 5;
        spindle_freq = 15 + randn*.3;

        sp_t = linspace(0,spindle_duration,spindle_duration*Fs);
        spindle = sin(2*pi*sp_t*spindle_freq) .* hanning(length(sp_t))'*spindle_amp;

        %Add spindle to time series
        start_ind = max(spindle_times(ii) - round(spindle_duration/2)*Fs,1);
        inds = start_ind:min((start_ind+length(spindle)-1), N);
        spindles(inds) = spindles(inds) + spindle(1:length(inds));
    end
end

signal = signal + spindles;
signal = signal - mean(signal);

%% Plot signal
close all;
figure
[theta_mean, rho_mean, h_phist, h_pax, h_ml] = phasehistogram(spindle_phase,1,'NumBins',25);
set(h_pax,'position',[0.7256    0.3159    0.2967    0.3840]);
title(['Theta: ' num2str(theta_mean)])

ax = figdesign(1,1,'orient','landscape','margin',[.1 .1 .05, .3  .03]);
ax_split = split_axis(ax,[.2 .2 .6],1);
axes(ax_split(3))
multitaper_spectrogram_mex(signal, Fs, [.5 35],[2 3], [1.5 .05], 2^10,'constant');climscale; colormap(jet);
axes(ax_split(2))
plot(t,signal)
axes(ax_split(1))
plot(t,SO_power)
linkaxes(ax_split,'x')



scrollzoompan(ax_split(2));

set(gcf,'units','normalized','position',[0 0 1 1]);
end