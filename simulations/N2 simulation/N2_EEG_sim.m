function [signal, spindle_stats, slow_waves, spindles, slow, delta, noise] = N2_EEG_sim(Fs, total_time, baseline_time, spindle_opts, noise_opts, plot_on)
%N2_EEG_SIM Simulates N2 sleep stage EEG signals with spindle and K-complex events
%
% [signal, spindle_stats] = N2_EEG_sim(Fs, total_time, baseline_time, spindle_opts, noise_opts,  plot_on)
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
%       Fs = 100;
%       total_time = 3600;
%       baseline_time = 60; %Set first 1 minute to be baseline
%
%       %Create two kinds of spindles with different properties
%       spindle_opts(1) =  N2_EEG_sim_spindle_opts('spindle_freq_mean',15,'spindle_freq_std',.125,'phase_pref',0,'modulation_factor',.3);
%       spindle_opts(2) =  N2_EEG_sim_spindle_opts('spindle_freq_mean',13,'spindle_freq_std',.125,'phase_pref',pi/4,'modulation_factor',.4);
%
%       %Use default noise
%       noise_opts = N2_EEG_sim_noise_opts;
%
%       %Generate the signal
%       signal = N2_EEG_sim(Fs, total_time, baseline_time, spindle_opts, noise_opts);
%
%    Copyright 2024 Prerau Laboratory. - http://www.sleepEEG.org
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Create a sample to run as default
if nargin == 0
    %Create 2 hours of data
    Fs = 100;
    total_time = 3600*4;
    baseline_time = 60; %Set first 1 minute to be baseline

    %Create different history dependencies for each spindle set
    ctrl_pts1 =         [    -3,     0, 3, 4.5, 8, 9, 12, 15, 18  45,  50, 55, 65, 85];
    theta_spline1 = log([  1e-5,  1e-2, 1, 2, 1, 1,  1,  1,  1,  1, 1.5, 1,  1,  1]);

    ctrl_pts2 =        [    -3,     0,  4, 6, 8, 9, 12, 15, 18  40,  45, 55, 65, 85];
    theta_spline2 = log([  1e-5,  1e-2, 1, 3, 1, 1,  1,  1,  1,  1, 1.2, 1,  1,  1]);


    spindle_opts(1) =  N2_EEG_sim_spindle_opts('spindle_freq_mean',15,'spindle_freq_std',.125,...
        'phase_pref',0,'modulation_factor',.7,'ctrl_pts',ctrl_pts1,'theta_spline',theta_spline1);

    spindle_opts(2) =  N2_EEG_sim_spindle_opts('spindle_freq_mean',10,'spindle_freq_std',.125,...
        'phase_pref',pi/4,'modulation_factor',.6,'ctrl_pts',ctrl_pts2,'theta_spline',theta_spline2);

    noise_opts = N2_EEG_sim_noise_opts;

    [signal, spindle_stats, slow_waves, spindles, slow, delta, noise] = N2_EEG_sim(Fs, total_time, baseline_time, spindle_opts, noise_opts);

    return;
end

%Force reasonable frequencies
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

%% Generate Slow Waves
slow_waves = zeros(1,N);

%Set SW rate (events/minute) to be lambda of a Poisson process
SW_rate = 40;

%Generate Poisson events
SW_times = find(poissrnd(SW_rate/60/Fs, 1, N));

%Loop through all events and generate SWs
for ii = 1:length(SW_times)

    %Simulate KC waveform
    SW_duration = 1.5+rand/5;
    SW_amp = 10*(rand + .5);
    SW_t = linspace(0,SW_duration,SW_duration*Fs);

    %Generate a parametric slow wave
    SW = (sin(.75*2*pi*SW_t) + sin(.5*SW_t-pi)) .* hanning(length(SW_t))'*SW_amp;

    %Add SW to time series
    inds = round(SW_t*Fs+SW_times(ii)-SW_duration*Fs/2);

    if all(inds>1 & inds<N)
        slow_waves(inds) = SW;
    end
end

%% Generate "slow" and "delta" waveforms through filtered white noise

%Compute slow data
SO_freqrange = [0.3 1.5];
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

%Compute delta data
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

delta = filtfilt(d,randn(1,N))*10;

%% Generate colored noise
%1/f^alpha

cn = dsp.ColoredNoise('SamplesPerFrame', N, 'InverseFrequencyPower', noise_opts.alpha_exp);
noise = cn()*noise_opts.noise_factor;
noise = noise';

%% Create baseline signal
baseline_signal = double(slow_waves + slow + delta + noise);

%% Compute SO

%Compute SO band filter
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

SO_EEG = filtfilt(d,baseline_signal);

%Extract SO-phase
SO_phase = angle(hilbert(SO_EEG));

spindles = zeros(length(spindle_opts),N);

%% Generate spindles
for ss = 1:length(spindle_opts)
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
    ctrl_pts = spindle_opts(ss).ctrl_pts;
    spline_tmax = spindle_opts(ss).spline_tmax;
    theta_spline = spindle_opts(ss).theta_spline;
    tension = spindle_opts(ss).tension;

    Fs_sp = Fs;

    %Set spindle density
    spindle_times = ...
        spindle_pptimes(Fs, Fs_sp, spindle_baseline_rate, SO_phase, modulation_factor, phase_pref, ctrl_pts, theta_spline, tension, spline_tmax);

    spindle_times = spindle_times(spindle_times>baseline_time);

    spindle_durations = nan(1,length(spindle_times));
    spindle_amps = nan(1,length(spindle_times));
    spindle_freqs = nan(1,length(spindle_times));

    for ii = 1:length(spindle_times)
        spindle_durations(ii) = max(spindle_dur_mean + randn*spindle_dur_std,0);
        spindle_amps(ii) = max(spindle_amp_mean + randn*spindle_amp_std, 0);
        spindle_freqs(ii) = max(spindle_freq_mean + randn*spindle_freq_std,0);

        sp_t = linspace(0,spindle_durations(ii),round(spindle_durations(ii)*Fs));
        spindle = sin(2*pi*sp_t*spindle_freqs(ii)) .* hanning(length(sp_t))'*spindle_amps(ii);
        sp_inds = round((sp_t+spindle_times(ii)-spindle_durations(ii)/2)*Fs);

        if all(sp_inds>1 & sp_inds<N)
            spindles(ss,sp_inds) = spindle;
        end
    end

    spindle_stats(ss).spindle_times = spindle_times; %#ok<*AGROW>
    spindle_stats(ss).spindle_freqs = spindle_freqs;
    spindle_stats(ss).spindle_amps = spindle_amps;
    spindle_stats(ss).spindle_durations = spindle_durations;
    spindle_stats(ss).spindle_phase = SO_phase(round(spindle_times*Fs));
end

%Add spindles to the signal
signal = baseline_signal + sum(spindles,1);

%Convert spindle inds into times
%% Plot signal
if plot_on
    plot_colors = ...
        [     0    0.4470    0.7410;
        0.8500    0.3250    0.0980;
        0.9290    0.6940    0.1250;
        0.4940    0.1840    0.5560;
        0.4660    0.6740    0.1880;
        0.3010    0.7450    0.9330;
        0.6350    0.0780    0.1840];

    [spect, stimes, sfreqs] = multitaper_spectrogram_mex(signal, Fs, [.5 25], [2 3], [1 .05], 2^10,'constant','plot_on',false);

    close all;
    figure
    %Plot phase histogram
    for ss = 1:length(spindle_opts)
        [theta_mean(ss), ~, h_phist, h_pax, ~] = phasehistogram(spindle_stats(ss).spindle_phase,1);
        h_phist.FaceColor = plot_colors(ss,:);
        h_phist.FaceAlpha = .4;
        h_phist.NumBins = 50;
        hold on
    end
    title(['Theta: ' num2str(theta_mean)])
    set(h_pax,'position',[0.7636    0.5732    0.2087    0.3507]);

    %Plot simulated signal
    ax = figdesign(1,1,'orient','landscape','margin',[.1 .1 .05, .33  .03]);
    set(gcf,"Position",[ 0.2948    0.1951    0.5866    0.5979]);

    ax_split = split_axis(ax,[.7 .15 .15], 1);

    %Plot spectrogram
    axes(ax_split(1))

    imagesc(stimes,sfreqs,pow2db(spect));
    axis xy;
    climscale;
    colorbar_noresize;
    colormap(rainbow4);

    hold on
    s = scatter(cat(2,spindle_stats.spindle_times),cat(2,spindle_stats.spindle_freqs),40,'k','filled');
    %Add informative datatips to each spindle
    dtRows = [dataTipTextRow("Time",cat(2,spindle_stats.spindle_times)),...
        dataTipTextRow("Freq.",cat(2,spindle_stats.spindle_freqs)),...
        dataTipTextRow("Amp.",cat(2,spindle_stats.spindle_amps)),...
        dataTipTextRow("Dur.",cat(2,spindle_stats.spindle_durations)),...
        dataTipTextRow("Phase",cat(2,spindle_stats.spindle_phase))];
    s.DataTipTemplate.DataTipRows = dtRows;

    set(gca,'fontsize',15,'xtick',[]);
    ylabel('Frequency (Hz)');
    title('Simulated N2 EEG','FontSize',30);
    axis tight
    linkaxes(ax_split,'x')

    %Plot Signal
    axes(ax_split(2))
    hold all
    plot(t,signal)

    set(gca,'fontsize',15);
    xlabel('Time (s)');
    ylabel('mV');
    ylim([-55 55])

    %Plot SO and Phase on the same axis
    %SO
    axes(ax_split(3))
    yyaxis left;
    plot(t,SO_EEG,'linewidth',2);
    ylabel('SO (mV)')
    set(gca,'fontsize',15);
    ylim(gca,[-55 55])

    %Phase
    yyaxis right;
    plot(t, SO_phase,'color','r')
    set(gca,'ytick',[-1 -1/2 0 1/2 1]*pi,'yticklabel',{'-\pi' '-\pi/2' '0' '\pi/2' '\pi'});
    ylabel('SO Phase (rad)');
    ylim([-pi pi])

    xlabel('Time (s)')
    set(gca,'fontsize',15);

    xlim([min(t) max(t)])

    hist_ax = axes('Position',[  0.7552    0.1290    0.2346    0.3415]);
    hold on
    for ss = 1:length(spindle_stats)
        spindle_train = histcounts(spindle_stats(ss).spindle_times, 1:max(spindle_stats(ss).spindle_times));
        hist_length = 60;
        Hist = zeros(length(spindle_train),hist_length);
        for i = 1:hist_length
            Hist(:,i) = circshift(spindle_train,i);
        end

        y = spindle_train;

        % Fit point process GLM
        [b2, ~, stats2] = glmfit(Hist, y, 'poisson');
        [yhat2, dylo2, dyhi2] = glmval(b2, eye(length(b2) - 1), 'log', stats2);


        t_spline=1:hist_length;
        c = exp(b2(1));
        hold on;
        plot(t_spline,(yhat2)/c,'color',plot_colors(ss,:),'linewidth',3)
        fill([t_spline, fliplr(t_spline)], [yhat2 / c - dylo2 / c; flipud(yhat2 / c + dyhi2 / c)], plot_colors(ss,:), 'FaceAlpha', 0.4, 'EdgeColor', 'none');
    end
    xlabel("Time Since Last Spindle (s)")
    ylabel('Modulation Factor')
    title('History Modulation Curve')
    set(hist_ax,'fontsize',15)

    axes(ax_split(1))
    scrollzoompan(ax_split(1));
end


