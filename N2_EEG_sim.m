function signal = N2_EEG_sim(Fs, total_time, phase_pref, spindle_baseline, modulation_factor, spindle_min_separation, alpha_exp)
if nargin == 0
    Fs = 200;
    total_time = 3600*2;
    phase_pref = pi/2;
    signal = N2_EEG_sim(Fs, total_time, phase_pref);
    return;
end

%Set phase pref and max prob
if nargin<3 || isempty(phase_pref)
    phase_pref = pi;
end

if nargin<4 || isempty(spindle_baseline)
    spindle_baseline = 1;
end

%Modulation factor for cosine tuning
if nargin<5 || isempty(modulation_factor)
    modulation_factor = 20;
end

%Set min spacing between events
if nargin<6 || isempty(spindle_min_separation)
spindle_min_separation = 1;
end

%Set 1/f^alpha
if nargin<7 || isempty(alpha_exp)
    alpha_exp = 1.5;
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

%Create low-res random ~5Hz noise
delta_rnd = randn(1,N/60/Fs*120*5)*1;
delta_rnd([1 end]) = 0; %Keep spline well-behaved

%Interpolate the noise to make a slow component
delta = interp1(linspace(1,N,length(delta_rnd)),delta_rnd,1:N,'spline');

%% Generate colored noise
%1/f^alpha
alpha_exp = 1.5;

cn = dsp.ColoredNoise('SamplesPerFrame', N, 'InverseFrequencyPower', alpha_exp);
noise = cn();

%% Create baseline signal and compute slow oscillation
%Create signal and zero mean
signal = K_complexes + slow + delta + noise';

%Set random SO-pow by filtering white noise at SO range
SO_power = quickbandpass(signal,Fs,[.3 1.5]);


%% Generate spindles
spindles = zeros(1,N);

%Extract SO-phase
SO_phase = angle(hilbert(SO_power));

%Set spindle density
prob_peak =  modulation_factor*cos(SO_phase-phase_pref);

%Generate Poisson events
spindle_inds = poissrnd(prob_peak/Fs/60 + spindle_baseline/Fs/60,1,N)>0;
spindle_times = find(spindle_inds);

last_good_spindle = -inf;

%Loop through all events and generate spindles
for ii = 1:length(spindle_times)
    %Check for overlap
    if ii>1 && (spindle_times(ii) - last_good_spindle)/Fs > spindle_min_separation

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

        last_good_spindle = spindle_times(ii);
    else
        spindle_times(ii) = nan;
    end
end

spindle_times = spindle_times(~isnan(spindle_times));
spindle_phase = SO_phase(spindle_times);

signal = signal + spindles;
signal = signal - mean(signal);

%% Plot signal
close all;
figure
[theta_mean, ~, ~, h_pax, ~] = phasehistogram(spindle_phase,1);
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