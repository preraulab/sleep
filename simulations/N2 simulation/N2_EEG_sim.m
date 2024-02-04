function [signal, spindle_stats] = N2_EEG_sim(Fs, total_time, baseline_time, spindle_opts, noise_opts, plot_on)
%N2_EEG_SIM Simulates N2 sleep stage EEG signals with spindle and K-complex events
%
% [signal, spindle_stats] = N2_EEG_sim(Fs, total_time, spindle_opts, noise_opts,  plot_on)
%
% Inputs:
% - Fs: Sampling frequency in Hz
% - total_time: Total time of the signal to be simulated in seconds
% - baseline_time: Amount of the signal without peaks to act as a detection baseline
% - spindle_opts: A array of spindle options structures (one for each spindle set) from N2_EEG_sim_spindle_opts()
% - noise_opts: A spindle options structure from N2_EEG_sim_noise_opts()
% - plot_on: Boolean flag to plot the generated signal or not (default: true)
%
% Outputs:
% - signal: Simulated N2 sleep stage EEG signal with spindle and K-complex events
% - spindle_stats: An array of stats strutures with times, amplitudes, durations, and phases
%
% Example usage:
%       %Create 1 hour of data
%       Fs = 200;
%       total_time = 3600;
%       phase_pref = -3*pi/4;
%       signal = N2_EEG_sim(Fs, total_time);
%
%    Copyright 2024 Michael J. Prerau Laboratory. - http://www.sleepEEG.org
%    Authors: Michael J. Prerau, Ph.D.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Create a sample to run as default
if nargin == 0
    %Create 1 hour of data
    Fs = 200;
    total_time = 3600;
    baseline_time = 60*5; %Set first 5 minutes to be baseline

    spindle_opts(1) =  N2_EEG_sim_spindle_opts('spindle_freq_mean',15,'spindle_freq_std',.25,'phase_pref',0);
    spindle_opts(2) =  N2_EEG_sim_spindle_opts('spindle_freq_mean',12,'spindle_freq_std',.25,'phase_pref',pi/2);

    noise_opts = N2_EEG_sim_noise_opts;

    signal = N2_EEG_sim(Fs, total_time, baseline_time, spindle_opts, noise_opts);

    return;
end

assert(Fs>0, 'Must have positive sampling frequency');
assert(total_time>0, 'Must have positive total time');

if nargin<3
    baseline_time = 0;
end

%Set phase pref and max prob
if nargin<4 || isempty(spindle_opts)
    spindle_opts = N2_EEG_sim_spindle_opts;
end

if nargin<5 || isempty(noise_opts)
    noise_opts = N2_EEG_sim_noise_opts;
end

%Turn plot on/off
if nargin<6
    plot_on = true;
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

        kc = (sin(.75*2*pi*kc_t) + sin(.5*kc_t-pi)) .* hanning(length(kc_t))'*kc_amp;

        %Add KC to time series
        inds = kc_times(ii):min((kc_times(ii)+length(kc)-1), N);
        K_complexes(inds) = K_complexes(inds) + kc(1:length(inds));
    end
end

%% Generate "slow" and "delta" waveforms by spline interpolation

% %Create low-res random ~1Hz noise
% slow_rnd = randn(1,round(N/60/Fs*120))*2;
% slow_rnd([1 end]) = 0; %Keep spline well-behaved
% 
% %Interpolate the noise to make a slow component
% slow = interp1(linspace(1,N,length(slow_rnd)),slow_rnd,1:N,'spline');
% 
% %Create low-res random ~5Hz noise
% delta_rnd = randn(1,round(N/60/Fs*120*5))*1;
% delta_rnd([1 end]) = 0; %Keep spline well-behaved
% 
% %Interpolate the noise to make a slow component
% delta = interp1(linspace(1,N,length(delta_rnd)),delta_rnd,1:N,'spline');

%Compute SO-power
SO_freqrange = [0.11 2];
d = designfilt('bandpassiir', ...       % Response type
    'StopbandFrequency1',SO_freqrange(1)-0.1, ...    % Frequency constraints
    'PassbandFrequency1',SO_freqrange(1), ...
    'PassbandFrequency2',SO_freqrange(2), ...
    'StopbandFrequency2',SO_freqrange(2)+0.1, ...
    'StopbandAttenuation1',60, ...   % Magnitude constraints
    'PassbandRipple',1, ...
    'StopbandAttenuation2',60, ...
    'DesignMethod','ellip', ...      % Design method
    'MatchExactly','passband', ...   % Design method options
    'SampleRate',Fs);

slow = filtfilt(d,randn(1,N));

%Compute SO-power
SO_freqrange = [1.5 5];
d = designfilt('bandpassiir', ...       % Response type
    'StopbandFrequency1',SO_freqrange(1)-1, ...    % Frequency constraints
    'PassbandFrequency1',SO_freqrange(1), ...
    'PassbandFrequency2',SO_freqrange(2), ...
    'StopbandFrequency2',SO_freqrange(2)+8, ...
    'StopbandAttenuation1',60, ...   % Magnitude constraints
    'PassbandRipple',1, ...
    'StopbandAttenuation2',60, ...
    'DesignMethod','ellip', ...      % Design method
    'MatchExactly','passband', ...   % Design method options
    'SampleRate',Fs);

delta = filtfilt(d,randn(1,N));


%% Generate colored noise
%1/f^alpha

cn = dsp.ColoredNoise('SamplesPerFrame', N, 'InverseFrequencyPower', noise_opts.alpha_exp);
noise = cn()*noise_opts.noise_factor;

%% Create baseline signal and compute slow oscillation
%Create signal and zero mean
signal = K_complexes + slow + 10*delta + noise';

%Compute SO-power
SO_freqrange = [.3 1.5];
d = designfilt('bandpassiir', ...       % Response type
    'StopbandFrequency1',SO_freqrange(1)-0.1, ...    % Frequency constraints
    'PassbandFrequency1',SO_freqrange(1), ...
    'PassbandFrequency2',SO_freqrange(2), ...
    'StopbandFrequency2',SO_freqrange(2)+0.1, ...
    'StopbandAttenuation1',60, ...   % Magnitude constraints
    'PassbandRipple',1, ...
    'StopbandAttenuation2',60, ...
    'DesignMethod','ellip', ...      % Design method
    'MatchExactly','passband', ...   % Design method options
    'SampleRate',Fs);

SO_power = filtfilt(d,double(signal));

%Extract SO-phase
SO_phase = angle(hilbert(SO_power));


%% Generate spindles
for ss = 1:length(spindle_opts)
    spindles = zeros(1,N);

    %Extract info from structure
    phase_pref = spindle_opts(ss).phase_pref;
    spindle_freq_mean = spindle_opts(ss).spindle_freq_mean;
    spindle_freq_std = spindle_opts(ss).spindle_freq_std;
    spindle_amp_mean = spindle_opts(ss).spindle_amp_mean;
    spindle_amp_std = spindle_opts(ss).spindle_amp_std;
    spindle_dur_mean = spindle_opts(ss).spindle_dur_mean;
    spindle_dur_std = spindle_opts(ss).spindle_dur_std;
    spindle_baseline_rate = spindle_opts(ss).spindle_baseline_rate;
    modulation_factor = spindle_opts(ss).modulation_factor;
    spindle_min_separation = spindle_opts(ss).spindle_min_separation;

    %Set spindle density
    phase_modulation = (modulation_factor*cos(SO_phase-phase_pref) + modulation_factor)/2;
    lambda = phase_modulation .* spindle_baseline_rate;

    %Generate Poisson events
    spindle_inds = poissrnd(lambda/Fs/60,1,N)>0;
    spindle_inds(1:baseline_time*Fs) = 0; %Remove all peaks during baseline time
    spindle_inds = find(spindle_inds);

    spindle_durations = nan(1,length(spindle_inds));
    spindle_amps = nan(1,length(spindle_inds));
    spindle_freqs = nan(1,length(spindle_inds));

    %Loop through all events and generate spindles
    valid_inds = true(1, length(spindle_inds));
    last_spindle_time = spindle_inds(1);

    for ii = 1:length(spindle_inds)
        %Check for overlap
        if ii>1 && (spindle_inds(ii) - last_spindle_time)/Fs > spindle_min_separation
            %Simulate spindle waveform
            spindle_duration = max(spindle_dur_mean + randn*spindle_dur_std,0);
            spindle_amp = max(spindle_amp_mean + randn*spindle_amp_std, 0);
            spindle_freq = max(spindle_freq_mean + randn*spindle_freq_std,0);

            sp_t = linspace(0,spindle_duration,spindle_duration*Fs);
            spindle = sin(2*pi*sp_t*spindle_freq) .* hanning(length(sp_t))'*spindle_amp;

            %Add spindle to time series
            start_ind = max(spindle_inds(ii) - round(spindle_duration/2)*Fs,1);
            inds = start_ind:min((start_ind+length(spindle)-1), N);
            spindles(inds) = spindles(inds) + spindle(1:length(inds));
            last_spindle_time = spindle_inds(ii);

            spindle_durations(ii) = spindle_duration;
            spindle_amps(ii) = spindle_amp;
            spindle_freqs(ii) = spindle_freq;

        elseif ii>1
            valid_inds(ii) = false;
        end
    end

    spindle_stats(ss).spindle_times = spindle_inds(valid_inds)/Fs;
    spindle_stats(ss).spindle_freqs = spindle_freqs(valid_inds);
    spindle_stats(ss).spindle_amps = spindle_amps(valid_inds);
    spindle_stats(ss).spindle_durations = spindle_durations(valid_inds);
    spindle_stats(ss).spindle_phase = SO_phase(spindle_inds(valid_inds));


    %Add spindles to the signal
    signal = signal + spindles;
end

%Convert spindle inds into times
%% Plot signal
%Create standard visualization filter
SO_freqrange = [.3 35];
d = designfilt('bandpassiir', ...       % Response type
    'StopbandFrequency1',.01, ...    % Frequency constraints
    'PassbandFrequency1',SO_freqrange(1), ...
    'PassbandFrequency2',SO_freqrange(2), ...
    'StopbandFrequency2',SO_freqrange(2)+2, ...
    'StopbandAttenuation1',60, ...   % Magnitude constraints
    'PassbandRipple',1, ...
    'StopbandAttenuation2',60, ...
    'DesignMethod','ellip', ...      % Design method
    'MatchExactly','passband', ...   % Design method options
    'SampleRate',Fs);

vis_sig = filtfilt(d,double(signal));

if plot_on
    close all;
    figure
    for ss = 1:length(spindle_opts)
        [theta_mean, ~, h_phist, h_pax, ~] = phasehistogram(spindle_stats(ss).spindle_phase,1);
        h_phist.NumBins = 25;
        hold on
        set(h_pax,'position',[0.7256    0.3159    0.2967    0.3840]);
    end
    title(['Theta: ' num2str(theta_mean)])

    ax = figdesign(1,1,'orient','landscape','margin',[.1 .1 .05, .3  .03]);
    ax_split = split_axis(ax,[.2 .2 .6], 1);
    axes(ax_split(3))
    [spect, stimes, sfreqs] = multitaper_spectrogram_mex(signal, Fs, [.5 25], [2 3], [1 .05], 2^10,'constant');
    climscale; 
    colormap(rainbow4);
    axes(ax_split(2))
    hold all
    plot(t,vis_sig)
    plot(t,SO_power);

    axes(ax_split(1))
    yyaxis left;
    plot(t,SO_power);

    yyaxis right;
    plot(t, SO_phase)
    set(gca,'ytick',[-1 -1/2 0 1/2 1]*pi,'yticklabel',{'-\pi' '-\pi/2' '0' '\pi/2' '\pi'});
    linkaxes(ax_split,'x')

    scrollzoompan(ax_split(2));

    set(gcf,'units','normalized','position',[0 0 1 1]);
end
end