classdef SleepEEGSim < handle
    %SLEEPEEGSIM Simulate EEG data with multiple components including slow waves, spindles, and noise.
    %
    %   simObj = SleepEEGSim(Fs); %Run for demo
    %   simObj = SleepEEGSim('demo'); %Run for demo
    %
    %   Inputs (default values in parentheses):
    %       Fs: Sampling frequency in Hz (Default: 128)
    %
    %   Outputs:
    %       simObj: SleepEEGSim object containing the simulated data and settings.
    %
    %   Properties:
    %       Fs: double - Sampling frequency in Hz (Default: 128)
    %       Aperiodic: AperiodicEEG object - Component for aperiodic EEG noise
    %       Slow_Waves: SlowWaves object - Component for slow wave activity
    %       BandSets: array of BandEEG objects - Sets of frequency bands
    %       SpindleSets: array of Spindles objects - Sets of spindles
    %       LineNoiseSets: array of LineNoise objects - Sets of line noise
    %       Artifacts: MotionArtifacts object - Component for motion artifacts
    %       Signal: array - Simulated EEG signal
    %       t: array - Time vector for the simulated signal
    %       SO_EEG: array - Signal for slow oscillations
    %       SO_phase: array - Phase of slow oscillations
    %
    %   Methods:
    %       SleepEEGSim: Constructor for the SleepEEGSim class
    %           Usage:
    %               simObj = SleepEEGSim('demo');
    %           Description:
    %               Initializes a SleepEEGSim object with demo data. Simulates 2 hours of EEG data
    %               at 128 Hz sampling rate, including spindles, line noise, and artifacts.
    %               If no input arguments are provided, the default values are used.
    %
    %       addAperiodic: Add aperiodic EEG component
    %           Usage:
    %               obj = addAperiodic(obj, ap);
    %           Inputs:
    %               ap: AperiodicEEG object (Default: new instance of AperiodicEEG)
    %
    %       addLineNoise: Add line noise component
    %           Usage:
    %               obj = addLineNoise(obj, ln);
    %           Inputs:
    %               ln: LineNoise object (Default: new instance of LineNoise)
    %
    %       addSpindles: Add spindle component
    %           Usage:
    %               obj = addSpindles(obj, ss);
    %           Inputs:
    %               ss: Spindles object (Default: new instance of Spindles)
    %
    %       addBand: Add frequency band component
    %           Usage:
    %               obj = addBand(obj, bb);
    %           Inputs:
    %               bb: BandEEG object (Default: new instance of BandEEG)
    %
    %       addArtifacts: Add motion artifacts component
    %           Usage:
    %               obj = addArtifacts(obj, arts);
    %           Inputs:
    %               arts: MotionArtifacts object (Default: new instance of MotionArtifacts)
    %
    %       addSlowWaves: Add slow waves component
    %           Usage:
    %               obj = addSlowWaves(obj, sws);
    %           Inputs:
    %               sws: SlowWaves object (Default: new instance of SlowWaves)
    %
    %       sim: Simulate EEG data
    %           Usage:
    %               obj = sim(obj, T);
    %           Inputs:
    %               T: Duration of simulation in seconds (Default: 3600)
    %
    %       genSignal: Generate the final simulated EEG signal
    %           Usage:
    %               signal = genSignal(obj);
    %           Outputs:
    %               signal: array - Final simulated EEG signal
    %
    %       plot: Plot the simulated EEG data
    %           Usage:
    %               obj.plot();
    %           Description:
    %               Plots the simulated EEG signal, spectrogram, and additional components
    %               such as spindles and phase histograms.
    %
    %   Example:
    %       %Run 
    %
    %       % Simulate 2 hours of EEG data at 128 Hz sampling rate.
    %       Fs = 128;
    %       T = 3600 * 2; % Duration of simulation in seconds
    %
    %       % Define spindle parameters (frequency and phase preferences)
    %       freq_mean_fast = 15;
    %       phase_pref_fast = 0;
    %       freq_mean_slow = 11;
    %       phase_pref_slow = -pi/3;
    %
    %       % Define control points and spline parameters
    %       ctrl_pts_fast = [ -3, 0, 3, 4.5, 8, 9, 12, 15, 18, 45, 50, 55, 65, 85 ];
    %       theta_spline_fast = log([ 1e-5, 1e-2, 1, 2, 1, 1, 1, 1, 1, 1, 1.5, 1, 1, 1 ]);
    %       ctrl_pts_slow = [ -3, 0, 4, 6, 8, 9, 12, 15, 18, 40, 45, 55, 65, 85 ];
    %       theta_spline_slow = log([ 1e-5, 1e-2, 1, 3, 1, 1, 1, 1, 1, 1, 1.2, 1, 1, 1 ]);
    %
    %       % Create spindle objects
    %       fast_spindles = Spindles('Freq_mean', freq_mean_fast, 'Phase_pref', phase_pref_fast, 'Ctrl_pts', ctrl_pts_fast, 'Theta_spline', theta_spline_fast);
    %       slow_spindles = Spindles('Freq_mean', freq_mean_slow, 'Phase_pref', phase_pref_slow, 'Ctrl_pts', ctrl_pts_slow, 'Theta_spline', theta_spline_slow);
    %
    %       % Create band components
    %       slow_power = BandEEG([1 1.5], 10);
    %       delta_power = BandEEG([1 5], 15);
    %
    %       % Create simulation object
    %       simObj = SleepEEGSim('Fs', Fs);
    %       simObj.addAperiodic;
    %       simObj.addSlowWaves;
    %       simObj.addBand(slow_power);
    %       simObj.addBand(delta_power);
    %       simObj.addSpindles(fast_spindles);
    %       simObj.addSpindles(slow_spindles);
    %       simObj.addLineNoise(LineNoise('sin', 60, 5));
    %       simObj.addLineNoise(LineNoise('sawtooth', 18, 3));
    %       simObj.addArtifacts;
    %
    %       % Run the simulation
    %       simObj.sim(T);
    %
    %       % Plot the results
    %       simObj.plot;
    %
    %    Copyright 2024 Michael J. Prerau Laboratory. - http://www.sleepEEG.org
    % *********************************************************************

    properties
        Fs = 128;
        Aperiodic = [];
        Slow_Waves = [];
        BandSets = [];
        SpindleSets = [];
        LineNoiseSets = [];
        Artifacts = [];

        Signal = [];
        t = [];
        SO_EEG = [];
        SO_phase = [];
    end

    methods
        function obj = SleepEEGSim(varargin)
            if nargin==1 && strcmpi(varargin{1},'demo')
                %Simulate 2 hours of data at 128Hz
                Fs = 128;
                T = 3600*2;

                %Fast and slow spindle frequencies and phase preferences
                freq_mean_fast = 15;
                phase_pref_fast = 0;

                freq_mean_slow = 11;
                phase_pref_slow = -pi/3;

                %Define different history dependencies for each spindle set
                ctrl_pts_fast =         [    -3,     0, 3, 4.5, 8, 9, 12, 15, 18  45,  50, 55, 65, 85];
                theta_spline_fast = log([  1e-5,  1e-2, 1, 2, 1, 1,  1,  1,  1,  1, 1.5, 1,  1,  1]);

                ctrl_pts_slow =        [    -3,     0,  4, 6, 8, 9, 12, 15, 18  40,  45, 55, 65, 85];
                theta_spline_slow = log([  1e-5,  1e-2, 1, 3, 1, 1,  1,  1,  1,  1, 1.2, 1,  1,  1]);

                fast_spindles = Spindles('Freq_mean', freq_mean_fast, 'Phase_pref', phase_pref_fast, 'Ctrl_pts', ctrl_pts_fast, 'Theta_spline', theta_spline_fast);
                slow_spindles = Spindles('Freq_mean', freq_mean_slow, 'Phase_pref', phase_pref_slow, 'Ctrl_pts', ctrl_pts_slow, 'Theta_spline', theta_spline_slow);

                %Create slow and delta power
                slow_power = BandEEG([1. 1.5], 10);
                delta_power = BandEEG([1 5], 15);

                simObj = SleepEEGSim('Fs',Fs);

                simObj.addAperiodic;
                simObj.addSlowWaves;
                simObj.addBand(slow_power);
                simObj.addBand(delta_power);
                simObj.addSpindles(fast_spindles);
                simObj.addSpindles(slow_spindles);
                simObj.addLineNoise(LineNoise('sin',60,5));
                simObj.addLineNoise(LineNoise('sawtooth',18,3));
                simObj.addArtifacts;

                %Simulate the data
                simObj.sim(T);
                %Plot the results
                simObj.plot;

                obj = simObj;
                return;
            else

                % Create an input parser object
                p = inputParser;

                % Define the parameters and their default values
                addOptional(p, 'Fs', obj.Fs, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));

                % Parse the inputs
                parse(p, varargin{:});

                % Assign parsed values to object propertiesobj.Total_time =
                obj.Fs = p.Results.Fs;

            end
        end

        function obj = addAperiodic(obj,ap)
            if nargin==1
                ap = AperiodicEEG;
            end

            assert(isa(ap,'AperiodicEEG'),'Must be an object of class AperiodicEEG');
            obj.Aperiodic = ap;
        end

        function obj = addLineNoise(obj,ln)
            if nargin==1
                ln = LineNoise;
            end

            assert(isa(ln,'LineNoise'),'Must be an object of class LineNoise');

            if isempty(obj.LineNoiseSets)
                obj.LineNoiseSets = ln;
            else
                obj.LineNoiseSets(end+1) = ln;
            end
        end

        function obj = addSpindles(obj,ss)
            if nargin==1
                ss = Spindles;
            end

            assert(isa(ss,'Spindles'),'Must be an object of class Spindles');

            if isempty(obj.SpindleSets)
                obj.SpindleSets = ss;
            else
                obj.SpindleSets(end+1) = ss;
            end
        end

        function obj = addBand(obj,bb)
            if nargin==1
                bb = BandEEG;
            end

            assert(isa(bb,'BandEEG'),'Must be an object of class BandEEG');

            if isempty(obj.BandSets)
                obj.BandSets = bb;
            else
                obj.BandSets(end+1) = bb;
            end
        end

        function obj = addArtifacts(obj,arts)
            if nargin==1
                arts = MotionArtifacts;
            end

            assert(isa(arts,'MotionArtifacts'),'Must be an object of class MotionArtifacts');
            obj.Artifacts = arts;
        end

        function obj = addSlowWaves(obj,sws)
            if nargin==1
                sws = SlowWaves;
            end

            assert(isa(sws,'SlowWaves'),'Must be an object of class SlowWaves');
            obj.Slow_Waves = sws;
        end

        function sim(obj,T)
            if nargin == 1
                T = 3600;
            end

            %Set time vector
            obj.t = 0:1/obj.Fs:T;

            %Simulate baseline components
            obj.Aperiodic.sim(obj.t);
            obj.Slow_Waves.sim(obj.t);

            for ii = 1:length(obj.BandSets)
                obj.BandSets(ii).sim(obj.t);
            end

            %Create SO from slow waves, bands, and aperiodic
            SO_signal = obj.Aperiodic.Signal+obj.Slow_Waves.Signal;

            for ii = 1:length(obj.BandSets)
                SO_signal = SO_signal + obj.BandSets(ii).Signal;
            end

            %Compute SO EEG and phase
            [obj.SO_phase, obj.SO_EEG] = obj.computeSOPhase(SO_signal);

            %Simulate spindles
            for ii = 1:length(obj.SpindleSets)
                obj.SpindleSets(ii).sim(obj.t,obj.SO_phase);
            end

            %Simulate noise and artifacts
            for ii = 1:length(obj.LineNoiseSets)
                obj.LineNoiseSets(ii).sim(obj.t);
            end

            obj.Artifacts.sim(obj.t);

            %Generate the signal
            obj.Signal = obj.genSignal;
        end

        function signal = genSignal(obj)
            if isempty(obj.t)
                error('Simulation must be run first');
            end

            signal = zeros(size(obj.t));
            if obj.Aperiodic.isActive
                signal = signal + obj.Aperiodic.Signal;
            end

            if obj.Slow_Waves.isActive
                signal = signal + obj.Slow_Waves.Signal;
            end

            if obj.Artifacts.isActive
                signal = signal + obj.Artifacts.Signal;
            end

            for ii = 1:length(obj.BandSets)
                if obj.BandSets(ii).isActive
                    signal = signal + obj.BandSets(ii).Signal;
                end
            end

            for ii = 1:length(obj.SpindleSets)
                if obj.SpindleSets(ii).isActive
                    signal = signal + obj.SpindleSets(ii).Signal;
                end
            end


            for ii = 1:length(obj.LineNoiseSets)
                if obj.LineNoiseSets(ii).isActive
                    signal = signal + obj.LineNoiseSets(ii).Signal;
                end
            end
        end

        function plot(obj)
            if isempty(obj.Signal)
                obj.sim;
            end

            plot_colors = ...
                [     0    0.4470    0.7410;
                0.8500    0.3250    0.0980;
                0.9290    0.6940    0.1250;
                0.4940    0.1840    0.5560;
                0.4660    0.6740    0.1880;
                0.3010    0.7450    0.9330;
                0.6350    0.0780    0.1840];

            warning('off')
            [spect, stimes, sfreqs] = multitaper_spectrogram_mex(obj.Signal, obj.Fs, [.5 obj.Fs/2], [2 3], [1 .05], 2^10,'constant','plot_on',false,'verbose',false);
            warning('on')
            if ~isempty(obj.SpindleSets)
                [t_sp, b, yhat, dylo, dyhi] = obj.fit_ppsplines(obj.t, obj.SO_phase, obj.SpindleSets);
            end

            fh=figure;
            %Plot simulated signal
            ax = figdesign(1,1,'orient','landscape','margin',[.1 .1 .05, .33  .03]);
            set(fh,"Position",[ 0.2948    0.1951    0.5866    0.5979]);

            ax_split = split_axis(ax,[.7 .15 .15], 1);

            %Plot spectrogram
            axes(ax_split(1))
            imagesc(stimes,sfreqs,pow2db(spect));
            axis xy;
            climscale;
            colorbar_noresize;
            colormap(rainbow4);

            if ~isempty(obj.SpindleSets)
                hold on
                s = scatter(cat(2,obj.SpindleSets.Times),cat(2,obj.SpindleSets.Freqs),40,'k','filled');
                %Add informative datatips to each spindle
                dtRows = [dataTipTextRow("Time",cat(2,obj.SpindleSets.Times)),...
                    dataTipTextRow("Freq.",cat(2,obj.SpindleSets.Freqs)),...
                    dataTipTextRow("Amp.",cat(2,obj.SpindleSets.Amps)),...
                    dataTipTextRow("Dur.",cat(2,obj.SpindleSets.Durations)),...
                    dataTipTextRow("Phase",cat(2,obj.SpindleSets.Phase))];
                s.DataTipTemplate.DataTipRows = dtRows;
                s.DataTipTemplate.FontSize = 16;
            end

            set(gca,'fontsize',15,'xtick',[]);
            ylabel('Frequency (Hz)');
            title('Simulated EEG','FontSize',30);
            axis tight
            linkaxes(ax_split,'x')

            %Plot Signal
            axes(ax_split(2))
            hold all
            plot(obj.t,obj.Signal)

            set(gca,'fontsize',15);
            xlabel('Time (s)');
            ylabel('mV');
            ylim([-55 55])

            %Plot SO and Phase on the same axis
            %SO
            axes(ax_split(3))
            yyaxis left;
            plot(obj.t,obj.SO_EEG,'linewidth',2);
            ylabel('SO (mV)')
            set(gca,'fontsize',15);
            ylim(gca,[-65 65])

            %Phase
            yyaxis right;
            plot(obj.t, obj.SO_phase,'color','r')
            set(gca,'ytick',[-1 -1/2 0 1/2 1]*pi,'yticklabel',{'-\pi' '-\pi/2' '0' '\pi/2' '\pi'});
            ylabel('SO Phase (rad)');
            ylim([-pi pi])

            xlabel('Time (s)')
            set(gca,'fontsize',15);

            xlim([min(obj.t) max(obj.t)])

            if ~isempty(obj.SpindleSets)
                hist_ax = axes('Position',[  0.7552    0.1290    0.2346    0.3415]);
                hold on

                for ss = 1:length(obj.SpindleSets)
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
                for ss = 1:length(obj.SpindleSets)
                    b1 = (b{ss}(end-1));
                    b2 = (b{ss}(end));

                    theta_mod(ss) = atan2(b1,b2);
                    rho_mod(ss) = sqrt(b1.^2+b2.^2);

                    %Compute the mean population vector
                    vect_mean = mean(exp(1i*obj.SpindleSets(ss).Phase));

                    %Get the mean magnitude and angle
                    rho_samp(ss) = abs(vect_mean);
                    theta_samp(ss) = angle(vect_mean);

                    %Plot histogram
                    h_phist = polarhistogram(obj.SpindleSets(ss).Phase,'Normalization','pdf');
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
            end
            axes(ax_split(1))
            scrollzoompan(ax_split(1));
        end
    end

    methods (Access = protected)
        function [SO_phase, SO_EEG] = computeSOPhase(obj, baseline_signal)
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
                'SampleRate',obj.Fs);
            %% Create baseline signal
            SO_EEG = filtfilt(d,baseline_signal);
            %Extract SO-phase
            SO_phase = angle(hilbert(SO_EEG));
        end
    end

    methods (Static)
        %Helper function to fit the splines using a point process model
        function [t_sp, b, yhat, dylo, dyhi] = fit_ppsplines(t, SO_phase, spindle_sets)
            %Construct spline within .25s bins
            dt = .25;
            t_train = t(1):dt:t(end);

            for ss = 1:length(spindle_sets)
                %Remove spindles where more than one falls in a bin
                st_inds = find(diff([0 spindle_sets(ss).Times])>=dt);

                times_valid = spindle_sets(ss).Times(st_inds);
                phases_valid = spindle_sets(ss).Phase(st_inds);

                %Interpolate to dt
                spindle_train = histcounts(times_valid, [t_train inf]);
                t_sp{ss} = 0:dt:spindle_sets(ss).Spline_tmax;
                SO_int = interp1(t,SO_phase, t_train);
                SO_int(logical(spindle_train)) = phases_valid;

                ctrl_pts = spindle_sets(ss).Ctrl_pts/dt;
                numknots = length(ctrl_pts);
                tension = spindle_sets(ss).Tension;

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

                [b{ss}, ~, glm_STATS] = glmfit(X, y, 'poisson');
                S_fit = S;
                S_fit(1,size(X,2)) = 0;
                [yhat{ss}, dylo{ss}, dyhi{ss}] = glmval(b{ss}, S_fit, 'log', glm_STATS); %#ok<*AGROW>
            end
        end
    end
end
