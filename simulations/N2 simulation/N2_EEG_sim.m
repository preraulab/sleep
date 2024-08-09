function [signal, spindle_stats, slow_waves, spindles, slow, delta, noise, artifacts] = N2_EEG_sim(varargin)
%N2_EEG_SIM Simulates NREM Stage 2 sleep EEG with spindles
%
%   Usage:
%       [signal, spindle_stats, slow_waves, spindles, slow, delta, noise, artifacts] = N2_EEG_sim('ParameterName', ParameterValue, ...)
%
%   Input:
%       'ParameterName', ParameterValue - Name-value pairs specifying options for simulating N2 EEG
%           'Fs': Sampling frequency in Hz (default: 50)
%           'total_time': Total time of the signal to be simulated in seconds (default: 3600)
%           'baseline_time': Amount of the signal without peaks to act as a detection baseline (default: 30)
%           'spindle_opts': An array of spindle options structures (one for each spindle set) from N2_EEG_sim_spindle_opts() (default: N2_EEG_sim_spindle_opts())
%           'noise_opts': A noise options structure from N2_EEG_sim_noise_opts() (default: N2_EEG_sim_noise_opts())
%           'plot_on': Boolean flag to plot the generated signal or not (default: true)
%
%   Output:
%       signal: Simulated N2 sleep stage EEG signal with spindle and slow wave events
%       spindle_stats: An array of stats structures with times, amplitudes, durations, and phases
%       slow_waves: Slow wave component
%       spindles: Spindle component
%       slow: Slow oscillation component
%       delta: Delta oscillation component
%       noise: 1/f noise component
%       artifacts: Motion artifact component
%
%   Example:
%     % Run: N2_EEG_sim('demo') to execute the following demo code
%       
%     % Create 2 hours of data at 50Hz sampling rate
%     Fs = 50;
%     total_time = 3600*2;
%     baseline_time = 60; % Set first 1 minute to be baseline
% 
%     % Create two different types of spindle classes
%     % Define different history dependencies for each spindle set
%     ctrl_pts1 = [ -3, 0, 3, 4.5, 8, 9, 12, 15, 18, 45, 50, 55, 65, 85];
%     theta_spline1 = log([ 1e-5, 1e-2, 1, 2, 1, 1, 1, 1, 1, 1, 1.5, 1, 1, 1]);
% 
%     ctrl_pts2 = [ -3, 0, 4, 6, 8, 9, 12, 15, 18, 40, 45, 55, 65, 85];
%     theta_spline2 = log([ 1e-5, 1e-2, 1, 3, 1, 1, 1, 1, 1, 1, 1.2, 1, 1, 1]);
% 
%     % Create the spindle options
%     spindle_opts(1) = N2_EEG_sim_spindle_opts('spindle_freq_mean', 15, 'spindle_freq_std', 0.125, ...
%         'phase_pref', 0, 'modulation_factor', 0.7, 'ctrl_pts', ctrl_pts1, 'theta_spline', theta_spline1);
% 
%     spindle_opts(2) = N2_EEG_sim_spindle_opts('spindle_freq_mean', 11, 'spindle_freq_std', 0.125, ...
%         'phase_pref', pi/4, 'modulation_factor', 0.6, 'ctrl_pts', ctrl_pts2, 'theta_spline', theta_spline2);
% 
%     % Set noise level
%     noise_opts = N2_EEG_sim_noise_opts('noise_factor', 5);
% 
%     % Generate simulation
%     [signal, spindle_stats, slow_waves, spindles, slow, delta, noise, artifacts] = N2_EEG_sim('Fs', Fs, 'total_time', total_time, ...
%         'baseline_time', baseline_time, 'spindle_opts', spindle_opts, 'noise_opts', noise_opts);
%
%    Copyright 2024 Prerau Laboratory. - http://www.sleepEEG.org

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Create a sample to run as default
if nargin == 1 & strcmpi(varargin{1},'demo')
    %Create 2 hours of data at 50Hz sampling rate
    Fs = 50;
    total_time = 3600*2;
    baseline_time = 60; %Set first 1 minute to be baseline

    %Create two different types of spindle classes
    %Define different history dependencies for each spindle set
    ctrl_pts1 =         [    -3,     0, 3, 4.5, 8, 9, 12, 15, 18  45,  50, 55, 65, 85];
    theta_spline1 = log([  1e-5,  1e-2, 1, 2, 1, 1,  1,  1,  1,  1, 1.5, 1,  1,  1]);

    ctrl_pts2 =        [    -3,     0,  4, 6, 8, 9, 12, 15, 18  40,  45, 55, 65, 85];
    theta_spline2 = log([  1e-5,  1e-2, 1, 3, 1, 1,  1,  1,  1,  1, 1.2, 1,  1,  1]);

    %Create the spindle options
    spindle_opts(1) =  N2_EEG_sim_spindle_opts('spindle_freq_mean',15,'spindle_freq_std',.125,...
        'phase_pref',0,'modulation_factor',.7,'ctrl_pts',ctrl_pts1,'theta_spline',theta_spline1);

    spindle_opts(2) =  N2_EEG_sim_spindle_opts('spindle_freq_mean',11,'spindle_freq_std',.125,...
        'phase_pref',pi/4,'modulation_factor',.6,'ctrl_pts',ctrl_pts2,'theta_spline',theta_spline2);

    %Set noise level
    noise_opts = N2_EEG_sim_noise_opts('noise_factor',5,'artifact_rate',20/3600);
    
    %Generate simulation
    [signal, spindle_stats, slow_waves, spindles, slow, delta, noise] = N2_EEG_sim(Fs, total_time, baseline_time, spindle_opts, noise_opts);

    return;
end

% Input parser setup
p = inputParser;

% Default values
default_Fs = 50;
default_total_time = 3600;
default_baseline_time = 30;
default_spindle_opts = N2_EEG_sim_spindle_opts();
default_noise_opts = N2_EEG_sim_noise_opts();
default_plot_on = true;

% Add parameters to parser
addOptional(p, 'Fs', default_Fs, @(x) validateattributes(x, {'numeric'}, {'positive', 'scalar'}));
addOptional(p, 'total_time', default_total_time, @(x) validateattributes(x, {'numeric'}, {'positive', 'scalar'}));
addOptional(p, 'baseline_time', default_baseline_time, @(x) validateattributes(x, {'numeric'}, {'positive', 'scalar'}));
addOptional(p, 'spindle_opts', default_spindle_opts, @(x) validateattributes(x, {'struct', 'cell'}, {}));
addOptional(p, 'noise_opts', default_noise_opts, @(x) validateattributes(x, {'struct'}, {}));
addOptional(p, 'plot_on', default_plot_on, @(x) validateattributes(x, {'logical'}, {'scalar'}));

% Parse inputs
parse(p, varargin{:});

% Extract values from the parsed input
Fs = p.Results.Fs;
total_time = p.Results.total_time;
baseline_time = p.Results.baseline_time;
spindle_opts = p.Results.spindle_opts;
noise_opts = p.Results.noise_opts;
plot_on = p.Results.plot_on;

% Validate sampling frequency and total time
assert(Fs > 0, 'Sampling frequency must be positive.');
assert(total_time > 0, 'Total time must be positive.');

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
    [spindle_times, ~, S{ss}, t_spline{ss}] = ...
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

%Create motion artifacts
artifacts = zeros(size(signal));
if noise_opts.artifact_rate>0
    %Generate Poisson events
    artifacts = min(poissrnd(noise_opts.artifact_rate/Fs*ones(size(signal)), 1, N),1);
    N_art = sum(artifacts);
    
    %Set the values of the events to be the amplitude
    artifacts(artifacts>0) = randn(1,N_art)*noise_opts.artifact_amp_std + noise_opts.artifact_amp_mean;

    %Use the sinc as the basis for the artifact shape
    t_art=0:(1/Fs):10;
    art = [-sinc(max(t_art)-t_art) sinc(t_art)*2];
    art = art./max(art);

    %Convolve the shape with the train to make the artifacts
    artifacts = convn(artifacts,art,'same');
end

%Add the artifacts to the spindle
signal = signal + artifacts;

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
    [t_sp, b, yhat, dylo, dyhi] = fit_ppsplines(t, SO_phase, spindle_stats, spindle_opts);

    fh=figure;
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
    s.DataTipTemplate.FontSize = 16;

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
        hold on
        c = exp(b{ss}(1));
        fill([t_sp{ss}, fliplr(t_sp{ss})], [yhat{ss} / c - dylo{ss} / c; flipud(yhat{ss} / c + dyhi{ss} / c)],  plot_colors(ss,:), 'FaceAlpha', 0.2, 'EdgeColor', 'none');
        plot(t_sp{ss}, yhat{ss} / c,  'color', plot_colors(ss,:), 'linewidth', 2);
        axis tight;
        xlabel('Lag (s)');
        ylabel('Modulation');

        xlabel("Time Since Last Spindle (s)")
        ylabel('Modulation Factor')
        title('History Modulation Curve')
        set(hist_ax,'fontsize',15)
    end
    axis tight;
    ylim([0 min(max(ylim(gca)),10)]);


    h_pax = polaraxes('position',[0.7636    0.5732    0.2087    0.3507]);
    %Plot phase histogram
    for ss = 1:length(spindle_opts)
        b1 = (b{ss}(end-1));
        b2 = (b{ss}(end));

        theta_mod(ss) = atan2(b1,b2);
        rho_mod(ss) = sqrt(b1.^2+b2.^2);

        %Compute the mean population vector
        vect_mean = mean(exp(1i*spindle_stats(ss).spindle_phase));

        %Get the mean magnitude and angle
        rho_samp(ss) = abs(vect_mean);
        theta_samp(ss) = angle(vect_mean);

        %Plot histogram
        h_phist = polarhistogram(spindle_stats(ss).spindle_phase,'Normalization','pdf');
        h_pax.ThetaAxisUnits = 'radians';
        h_pax.ThetaTick = 0:pi/4:2*pi;
        h_pax.ThetaTickLabel = {'0','\pi/4','\pi/2','3\pi/4' '\pm\pi','-3\pi/4', '-\pi/2','-\pi/4'};
        h_pax.FontSize = 14;

        %Add mean arrow
        hold on
        polarplot([theta_mod(ss) theta_mod(ss)],[0 rho_mod(ss)],'linestyle','-','color',plot_colors(ss,:),'linewidth',3);
        polarplot([theta_samp(ss) theta_samp(ss)],[0 rho_samp(ss)],'linestyle','--','color',plot_colors(ss,:),'linewidth',2);

        h_phist.FaceColor = plot_colors(ss,:);
        h_phist.FaceAlpha = .4;
        h_phist.NumBins = 50;
        hold on
    end
    title(['Theta: ' num2str(theta_mod)])

    axes(ax_split(1))
    scrollzoompan(ax_split(1));
end
end

function [t_sp, b, yhat, dylo, dyhi] = fit_ppsplines(t, SO_phase, spindle_stats,spindle_opts)
%Downsample to 1s bins
dt = .25;
t_train = t(1):dt:t(end);

for ss = 1:length(spindle_stats)
    %Remove spindles where more than one falls in a bin
    st_inds = find(diff([0 spindle_stats(ss).spindle_times])>=dt);
    spindle_stats(ss).spindle_times = spindle_stats(ss).spindle_times(st_inds);
    spindle_stats(ss).spindle_phase = spindle_stats(ss).spindle_phase(st_inds);

    %Interpolate to dt
    spindle_train = histcounts(spindle_stats(ss).spindle_times, [t_train inf]);
    t_sp{ss} = 0:dt:spindle_opts(ss).spline_tmax;
    SO_int = interp1(t,SO_phase, t_train);
    SO_int(logical(spindle_train)) = spindle_stats(ss).spindle_phase;

    ctrl_pts = spindle_opts(ss).ctrl_pts/dt;
    numknots = length(ctrl_pts);
    tension = spindle_opts(ss).tension;

    % Construct spline matrix
    S = zeros(length(t_sp{ss}), numknots);

    for i = 1:length(t_sp{ss})
        % Find the nearest control point indices
        nearest_c_pt_index = find(ctrl_pts < i, 1, 'last');

        % Boundary checks for control points
        if nearest_c_pt_index < 2 || nearest_c_pt_index > numknots - 2
            continue;
        end

        nearest_c_pt_time = ctrl_pts(nearest_c_pt_index);
        next_c_pt_time = ctrl_pts(nearest_c_pt_index + 1);
        prev_c_pt_time = ctrl_pts(nearest_c_pt_index - 1);
        next2 = ctrl_pts(nearest_c_pt_index + 2);

        % Compute the normalized parameter u
        u = (i - nearest_c_pt_time) / (next_c_pt_time - nearest_c_pt_time);

        % Calculate the lengths for tension parameter l1 and l2
        l1 = (next_c_pt_time - prev_c_pt_time) / (next_c_pt_time - nearest_c_pt_time);
        l2 = (next2 - nearest_c_pt_time) / (next_c_pt_time - nearest_c_pt_time);

        % Calculate spline coefficients p
        p = [u^3, u^2, u, 1] * [-tension / l1, 2 - tension / l2, tension / l1 - 2, tension / l2;
            2 * tension / l1, tension / l2 - 3, 3 - 2 * tension / l1, -tension / l2;
            -tension / l1, 0, tension / l1, 0;
            0, 1, 0, 0];

        % Assign the spline coefficients to the spline matrix S
        S(i, nearest_c_pt_index - 1:nearest_c_pt_index + 2) = p;
    end

    hist_length = length(t_sp{ss});
    Hist = zeros(length(spindle_train),hist_length);
    for i = 1:hist_length
        Hist(:,i) = circshift(spindle_train,i);
    end
    X = Hist * S;
    X = [X sin(SO_int') cos(SO_int')];
    y = spindle_train;

    [b{ss}, ~, stats] = glmfit(X, y, 'poisson');
    S_fit = S;
    S_fit(1,size(X,2)) = 0;
    [yhat{ss}, dylo{ss}, dyhi{ss}] = glmval(b{ss}, S_fit, 'log', stats);
end
end