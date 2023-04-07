function [signal, spindle_times, spindle_phase] = N2_EEG_sim(Fs, total_time, phase_pref, spindle_freq, spindle_std, spindle_baseline_rate, modulation_factor, spindle_min_separation, alpha_exp, plot_on)
%Create a sample to run as default
if nargin == 0
    Fs = 200;
    total_time = 3600*.5;
    phase_pref = pi/2;
    signal = N2_EEG_sim(Fs, total_time, phase_pref);
    return;
end

%Set phase pref and max prob
if nargin<3 || isempty(phase_pref)
    phase_pref = pi;
end

if nargin<4 || isempty(spindle_freq)
    spindle_freq = 15;
end

%Modulation factor for cosine tuning
if nargin<5 || isempty(spindle_std)
    spindle_std = .5;
end

if nargin<6 || isempty(spindle_baseline_rate)
    spindle_baseline_rate = 10;
end

%Modulation factor for cosine tuning
if nargin<7 || isempty(modulation_factor)
    modulation_factor = 40;
end

%Set min spacing between events
if nargin<8 || isempty(spindle_min_separation)
    spindle_min_separation = 0.5;
end

%Set 1/f^alpha
if nargin<9 || isempty(alpha_exp)
    alpha_exp = 1.5;
end

if nargin<10
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

%Create low-res random ~1Hz noise
slow_rnd = randn(1,round(N/60/Fs*120))*2;
slow_rnd([1 end]) = 0; %Keep spline well-behaved

%Interpolate the noise to make a slow component
slow = interp1(linspace(1,N,length(slow_rnd)),slow_rnd,1:N,'spline');

%Create low-res random ~5Hz noise
delta_rnd = randn(1,round(N/60/Fs*120*5))*1;
delta_rnd([1 end]) = 0; %Keep spline well-behaved

%Interpolate the noise to make a slow component
delta = interp1(linspace(1,N,length(delta_rnd)),delta_rnd,1:N,'spline');

%% Generate colored noise
%1/f^alpha

cn = dsp.ColoredNoise('SamplesPerFrame', N, 'InverseFrequencyPower', alpha_exp);
noise = cn()*3;

%% Create baseline signal and compute slow oscillation
%Create signal and zero mean
signal = K_complexes + slow + delta + noise';

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
spindles = zeros(1,N);

%Set spindle density
lambda_peak = modulation_factor*cos(SO_phase-phase_pref);

%Generate Poisson events
spindle_inds = poissrnd((lambda_peak + spindle_baseline_rate)/Fs/60,1,N)>0;
spindle_inds = find(spindle_inds);

%Loop through all events and generate spindles
last_spindle_time = spindle_inds(1);
for ii = 1:length(spindle_inds)
    %Check for overlap
    if ii>1 && (spindle_inds(ii) - last_spindle_time)/Fs > spindle_min_separation
        %Simulate spindle waveform
        spindle_duration = rand*1.5 + .5;
        spindle_amp = rand*5 + 5;
        spindle_freq = spindle_freq + randn*spindle_std;

        sp_t = linspace(0,spindle_duration,spindle_duration*Fs);
        spindle = sin(2*pi*sp_t*spindle_freq) .* hanning(length(sp_t))'*spindle_amp;

        %Add spindle to time series
        start_ind = max(spindle_inds(ii) - round(spindle_duration/2)*Fs,1);
        inds = start_ind:min((start_ind+length(spindle)-1), N);
        spindles(inds) = spindles(inds) + spindle(1:length(inds));
        last_spindle_time = spindle_inds(ii);
    elseif ii>1
        spindle_inds(ii) = nan;
    end
end

spindle_inds = spindle_inds(~isnan(spindle_inds));
spindle_phase = SO_phase(spindle_inds);

%Add spindles to the signal
signal = signal + spindles;

%Convert spindle inds into times 
spindle_times = spindle_inds/Fs;

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
    [theta_mean, ~, ~, h_pax, ~] = phasehistogram(spindle_phase,1);
    set(h_pax,'position',[0.7256    0.3159    0.2967    0.3840]);
    title(['Theta: ' num2str(theta_mean)])

    ax = figdesign(1,1,'orient','landscape','margin',[.1 .1 .05, .3  .03]);
    ax_split = split_axis(ax,[.2 .2 .6],1);
    axes(ax_split(3))
    multitaper_spectrogram_mex(signal, Fs, [.5 35],[2 3], [1.5 .05], 2^10,'constant');climscale; colormap(jet);
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