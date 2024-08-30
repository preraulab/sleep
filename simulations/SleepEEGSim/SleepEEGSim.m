classdef SleepEEGSim < handle
    %SLEEPEEGSIM Simulate EEG data with multiple components including slow waves, spindles, and noise.
    %
    %   simObj = SleepEEGSim(Fs); % Create a SleepEEGSim object with specified sampling frequency
    %   simObj = SleepEEGSim('demo'); % Run the demo simulation
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
    %       OscillatorSets: array of Oscillator objects - Sets of frequency bands
    %       SpindleSets: array of Spindles objects - Sets of spindles
    %       LineNoiseSets: array of LineNoise objects - Sets of line noise
    %       Artifacts: MotionArtifacts object - Component for motion artifacts
    %       Signal: array - Simulated EEG signal
    %       t: array - Time vector for the simulated signal
    %       SO_EEG: array - Signal for slow oscillations
    %       SO_phase: array - Phase of slow oscillations
    %
    %   Constructor:
    %       SleepEEGSim: Constructor for the SleepEEGSim class
    %           Usage:
    %               simObj = SleepEEGSim('demo');
    %           Description:
    %               Initializes a SleepEEGSim object. If 'demo' is passed, simulates 1 hour of EEG data
    %               at 128 Hz sampling rate, including spindles, line noise, and artifacts.
    %               If no input arguments are provided, the default values are used.
    %
    %  Methods: (use help for more info, e.g. 'help SleepEEGSim.plotSpect', or 'doc SleepEEGSim' for all methods)
    %       addBand         componentNames  getComponents   plotSpect
    %       activateAll     addLineNoise    deactivateAll   numComponents   setActive
    %       addAperiodic    addSlowWaves    genSignal       plot            sim
    %       addArtifacts    addSpindles     getActive       plotComponents
    %
    %
    %   Example:
    %       %-------------------------
    %       % Simulation Parameters
    %       %-------------------------
    %       % Simulate 2 hours of EEG data at 128 Hz sampling rate.
    %       Fs = 128;
    %       T = 3600 * 2; % Duration of simulation in seconds
    %
    %       %-------------------------
    %       % Create Spindles objects
    %       %-------------------------
    %       % Define spindle parameters (frequency and phase preferences)
    %       freq_mean_fast = 15;
    %       phase_pref_fast = 0;
    %       freq_mean_slow = 11;
    %       phase_pref_slow = -pi/3;
    %
    %       % Define control points and spline parameters
    %       ctrl_pts_fast = [ -3, 0, 3, 4.5, 8, 9, 12, 15, 18, 45, 50, 55, 65, 85 ];
    %       theta_spline_fast = [ 1e-5, 1e-2, 1, 2, 1, 1, 1, 1, 1, 1, 1.5, 1, 1, 1 ];
    %       ctrl_pts_slow = [ -3, 0, 4, 6, 8, 9, 12, 15, 18, 40, 45, 55, 65, 85 ];
    %       theta_spline_slow = [ 1e-5, 1e-2, 1, 3, 1, 1, 1, 1, 1, 1, 1.2, 1, 1, 1 ];
    %
    %       fast_spindles = Spindles('Freq_mean', freq_mean_fast, 'Phase_pref', phase_pref_fast, 'Ctrl_pts', ctrl_pts_fast, 'Theta_spline', theta_spline_fast);
    %       slow_spindles = Spindles('Freq_mean', freq_mean_slow, 'Phase_pref', phase_pref_slow, 'Ctrl_pts', ctrl_pts_slow, 'Theta_spline', theta_spline_slow);
    %
    %       %-------------------------
    %       % Create Oscillator objects
    %       %-------------------------
    %       slow_power = Oscillator([1 1.5], 10);
    %       delta_power = Oscillator([1 5], 15);
    %
    %       %-------------------------
    %       % Create LineNoise objects
    %       %-------------------------
    %       sixtyHz = LineNoise('sin', 60, 5);
    %       harmonic_noise = LineNoise('sawtooth', 18, 3);
    %
    %       %-------------------------
    %       % Create SleepEEGSim object
    %       %-------------------------
    %       simObj = SleepEEGSim('Fs', Fs);
    %
    %       %Add components
    %       simObj.addAperiodic; %Use defaults
    %       simObj.addSlowWaves; %Use defaults
    %       simObj.addBand(slow_power);
    %       simObj.addBand(delta_power);
    %       simObj.addSpindles(fast_spindles);
    %       simObj.addSpindles(slow_spindles);
    %       simObj.addLineNoise(sixtyHz);
    %       simObj.addLineNoise(harmonic_noise);
    %       simObj.addArtifacts; %Use defaults
    %
    %       % Run the simulation and plot
    %       simObj.sim;
    %
    %       %-------------------------
    %       % Plotting
    %       %-------------------------
    %       %Plot
    %       simObj.plot;
    %       %Set active components interactively
    %       simObj.setActive();
    %
    %       %Plot the spectrum
    %       simObj.plotSpect
    %       %Plot the components
    %       simObj.plotComponents
    %
    %       %-------------------------
    %       % Modifications
    %       %-------------------------
    %       %Change some parameters
    %       simObj.Aperiodic.Magnitude = 8;
    %       simObj.Artifacts.Rate = 20/3600;
    %       simObj.SpindleSets(1).Freq_mean = 14;
    %
    %       %Rerun the simulation and plot
    %       simObj.sim
    %       simObj.plot
    %
    %       %Modify some components and verify
    %       simObj.setActive([1 1 0 0 1 1 0 0 0]);
    %       disp(simObj.getActive);
    %       simObj.deactivateAll; %Deactivate all
    %       disp(simObj.getActive);
    %       simObj.activateAll; %Reactivate all
    %       disp(simObj.getActive);
    %
    %       %Plot and limit spectrum range
    %       simObj.plot(true, [.5 25]);
    %
    %
    %    Copyright 2024 Michael J. Prerau Laboratory. - http://www.sleepEEG.org
    % *********************************************************************

    properties
        Fs = 128;  % Sampling frequency in Hz
        Aperiodic = [];  % Aperiodic EEG noise component
        Slow_Waves = [];  % Slow wave activity component
        OscillatorSets = [];  % Array of frequency band components
        SpindleSets = [];  % Array of spindle components
        LineNoiseSets = [];  % Array of line noise components
        Artifacts = [];  % Motion artifacts component

        Signal = [];  % Final simulated EEG signal
        t = [];  % Time vector for the simulated signal
        SO_EEG = [];  % Signal for slow oscillations
        SO_phase = [];  % Phase of slow oscillations
    end

    properties (Access = private)
        %Main plot items
        mainplot_fig = [];
        history_ax = [];
        phasehist_ax = [];
        signal_ax = [];
        zslider = [];
        pslider = [];
        zedit = [];
        pedit = [];

        %Active figure
        setactive_fig = []

        %Component figure
        component_fig = [];
        comp_ax = [];
    end

    methods
        function obj = SleepEEGSim(varargin)
            %SLEEP_EEG_SIM Constructor for the SleepEEGSim class
            %
            %   This constructor initializes the SleepEEGSim object. If 'demo' is passed
            %   as an argument, it simulates 2 hours of EEG data at a sampling frequency
            %   of 128Hz with predefined spindle parameters and various noise and artifact
            %   components.
            %
            %   Inputs:
            %       varargin: Optional arguments. If 'demo' is passed, a demo simulation is run.
            %   Outputs:
            %       obj: An instance of the SleepEEGSim class with the simulated data.

            if nargin == 1 && strcmpi(varargin{1}, 'demo')
                % If 'demo' is specified, simulate a demo dataset
                Fs = 128; % Sampling frequency in Hz
                T = 3600; % Duration of simulation in seconds (2 hours)

                % Parameters for fast and slow spindles
                freq_mean_fast = 14; % Mean frequency of fast spindles
                phase_pref_fast = 0; % Phase preference for fast spindles

                freq_mean_slow = 11; % Mean frequency of slow spindles
                phase_pref_slow = -pi/3; % Phase preference for slow spindles

                % Define control points and spline parameters for fast and slow spindles
                ctrl_pts_fast = [ -3, 0, 3, 4.5, 8, 9, 12, 15, 18  45, 50, 55, 65, 85 ];
                theta_spline_fast = [ 1e-5, 1e-2, 1, 2, 1, 1, 1, 1, 1, 1, 1.5, 1, 1, 1 ];

                ctrl_pts_slow = [ -3, 0, 4, 6, 8, 9, 12, 15, 18  40, 45, 55, 65, 85 ];
                theta_spline_slow = [ 1e-5, 1e-2, 1, 3, 1, 1, 1, 1, 1, 1, 1.2, 1, 1, 1 ];

                % Create Spindles objects for fast and slow spindles
                fast_spindles = Spindles('Freq_mean', freq_mean_fast, 'Phase_pref', phase_pref_fast, 'Ctrl_pts', ctrl_pts_fast, 'Theta_spline', theta_spline_fast);
                slow_spindles = Spindles('Freq_mean', freq_mean_slow, 'Phase_pref', phase_pref_slow, 'Ctrl_pts', ctrl_pts_slow, 'Theta_spline', theta_spline_slow);

                % Create an instance of SleepEEGSim
                simObj = SleepEEGSim('Fs', Fs);

                % Add components to the simulation
                simObj.addAperiodic;
                simObj.addSlowWaves;
                simObj.addSpindles(fast_spindles);
                simObj.addSpindles(slow_spindles);
                simObj.addOscillator(Oscillator('Freq', 5, 'StateNoise', 3)); %Added delta power
                simObj.addLineNoise(LineNoise('sin', 60, 15));
                simObj.addLineNoise(LineNoise('sawtooth', 18, 10));
                simObj.addArtifacts;

                % Run the simulation and plot results
                simObj.sim(T);
                simObj.plot;
                simObj.setActive;

                obj = simObj; % Return the simulated object
                return;
            else
                % If not 'demo', initialize with user-defined or default parameters
                p = inputParser; % Create an input parser object

                % Define the parameter and its default value
                addOptional(p, 'Fs', obj.Fs, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));

                % Parse the input arguments
                parse(p, varargin{:});

                % Assign parsed values to the object's properties
                obj.Fs = p.Results.Fs;
            end
        end

        function obj = addAperiodic(obj, ap)
            %ADDAPERIODIC Add an aperiodic EEG component to the simulation
            %
            %   This method adds an AperiodicEEG object to the simulation. If no object is
            %   provided, a default AperiodicEEG object is created.
            %
            %   Inputs:
            %       ap: Optional AperiodicEEG object. If not provided, a default object is used.
            %   Outputs:
            %       obj: Updated SleepEEGSim object with the aperiodic component added.

            if nargin == 1
                ap = AperiodicEEG; % Create default AperiodicEEG object
            end

            % Check if ap is an instance of AperiodicEEG
            assert(isa(ap, 'AperiodicEEG'), 'Must be an object of class AperiodicEEG');
            obj.Aperiodic = ap; % Assign the aperiodic component to the object
        end

        function obj = addLineNoise(obj, ln)
            %ADDLINENOISE Add line noise components to the simulation
            %
            %   This method adds a LineNoise object to the simulation. If no object is
            %   provided, a default LineNoise object is created.
            %
            %   Inputs:
            %       ln: Optional LineNoise object. If not provided, a default object is used.
            %   Outputs:
            %       obj: Updated SleepEEGSim object with the line noise component added.

            if nargin == 1
                ln = LineNoise; % Create default LineNoise object
            end

            % Check if ln is an instance of LineNoise
            assert(isa(ln, 'LineNoise'), 'Must be an object of class LineNoise');

            % Add the line noise object to the list of line noise components
            if isempty(obj.LineNoiseSets)
                obj.LineNoiseSets = ln;
            else
                obj.LineNoiseSets(end+1) = ln;
            end
        end

        function obj = addSpindles(obj, ss)
            %ADDSPINDLES Add spindle components to the simulation
            %
            %   This method adds a Spindles object to the simulation. If no object is
            %   provided, a default Spindles object is created.
            %
            %   Inputs:
            %       ss: Optional Spindles object. If not provided, a default object is used.
            %   Outputs:
            %       obj: Updated SleepEEGSim object with the spindle component added.

            if nargin == 1
                ss = Spindles; % Create default Spindles object
            end

            % Check if ss is an instance of Spindles
            assert(isa(ss, 'Spindles'), 'Must be an object of class Spindles');

            % Add the spindle object to the list of spindle components
            if isempty(obj.SpindleSets)
                obj.SpindleSets = ss;
            else
                obj.SpindleSets(end+1) = ss;
            end
        end

        function obj = addOscillator(obj, oo)
            %ADDOSCILLATOR Add Noisy OscillatorEEG components to the simulation
            %
            %   This method adds a Oscillator object to the simulation. If no object is
            %   provided, a default Oscillator object is created.
            %
            %   Inputs:
            %       oo: Optional Oscillator object. If not provided, a default object is used.
            %   Outputs:
            %       obj: Updated SleepEEGSim object with the band-specific component added.

            if nargin == 1
                oo = Oscillator; % Create default Oscillator object
            end

            % Check if bb is an instance of Oscillator
            assert(isa(oo, 'Oscillator'), 'Must be an object of class Oscillator');

            % Add the band EEG object to the list of band-specific components
            if isempty(obj.OscillatorSets)
                obj.OscillatorSets = oo;
            else
                obj.OscillatorSets(end+1) = oo;
            end
        end

        function obj = addArtifacts(obj, arts)
            %ADDARTIFACTS Add motion artifacts to the simulation
            %
            %   This method adds a MotionArtifacts object to the simulation. If no object is
            %   provided, a default MotionArtifacts object is created.
            %
            %   Inputs:
            %       arts: Optional MotionArtifacts object. If not provided, a default object is used.
            %   Outputs:
            %       obj: Updated SleepEEGSim object with the artifacts component added.

            if nargin == 1
                arts = MotionArtifacts; % Create default MotionArtifacts object
            end

            % Check if arts is an instance of MotionArtifacts
            assert(isa(arts, 'MotionArtifacts'), 'Must be an object of class MotionArtifacts');
            obj.Artifacts = arts; % Assign the artifacts component to the object
        end

        function obj = addSlowWaves(obj, sws)
            %ADDSLOWWAVES Add slow waves component to the simulation
            %
            %   This method adds a SlowWaves object to the simulation. If no object is
            %   provided, a default SlowWaves object is created.
            %
            %   Inputs:
            %       sws: Optional SlowWaves object. If not provided, a default object is used.
            %   Outputs:
            %       obj: Updated SleepEEGSim object with the slow waves component added.

            if nargin == 1
                sws = SlowWaves; % Create default SlowWaves object
            end

            % Check if sws is an instance of SlowWaves
            assert(isa(sws, 'SlowWaves'), 'Must be an object of class SlowWaves');
            obj.Slow_Waves = sws; % Assign the slow waves component to the object
        end

        function obj = sim(obj, T)
            %SIM Simulate EEG data based on the configured components
            %
            %   This method generates simulated EEG data based on the properties and
            %   components added to the SleepEEGSim object. It combines contributions
            %   from aperiodic signals, spindles, slow waves, line noise, and artifacts
            %   into a single data array. The data is generated for the specified duration
            %   T and is sampled at the object's sampling frequency.
            %
            %   Inputs:
            %       T: double - Duration of the simulation in seconds. The length of
            %       the output data will be T seconds.
            %
            %   Outputs:
            %       data: array - Simulated EEG data. A vector of length equal to
            %       the sampling frequency (Fs) multiplied by the duration (T).
            %       t: array - Time vector corresponding to the data array. A vector
            %       of length equal to the data vector.
            %
            %   Example:
            %       % Simulate EEG data for 2 hours
            %       T = 3600 * 2; % 2 hours in seconds
            %       [data, t] = sim(simObj, T);
            %       % Plot the first 10 seconds of the simulated data
            %       plot(t(1:1280), data(1:1280));
            %       xlabel('Time (s)');
            %       ylabel('EEG Data');
            %
            %   Notes:
            %       - The function generates data at the object's sampling frequency
            %       (Fs) and the length of the output data will be T seconds.
            %       - The output data includes contributions from all added components.
            %       - The time vector t is generated based on the sampling frequency
            %       and the duration of the simulation.
            %
            if nargin == 1
                T = 3600;
            end

            %Set time vector
            obj.t = 0:1/obj.Fs:T;

            SO_signal = zeros(size(obj.t));

            %Simulate baseline components
            if ~isempty(obj.Aperiodic)
                obj.Aperiodic.sim(obj.t);
                SO_signal = SO_signal + obj.Aperiodic.Signal;
            end

            if ~isempty(obj.Slow_Waves)
                obj.Slow_Waves.sim(obj.t);
                SO_signal = SO_signal + obj.Slow_Waves.Signal;
            end

            if ~isempty(obj.OscillatorSets)
                for ii = 1:length(obj.OscillatorSets)
                    obj.OscillatorSets(ii).sim(obj.t);
                    SO_signal = SO_signal + obj.OscillatorSets(ii).Signal;
                end
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
            obj.genSignal;
        end

        function obj = deactivateAll(obj)
            %DEACTIVATEALL Deactivate all components of the SleepEEGSim object
            %
            %   This method deactivates all components of the SleepEEGSim object by setting
            %   their 'isActive' property to false. This includes Aperiodic, Slow_Waves,
            %   Artifacts, OscillatorSets, SpindleSets, and LineNoiseSets.
            %
            %   Inputs:
            %       obj: SleepEEGSim object - instance of the SleepEEGSim class
            %
            %   Outputs:
            %       obj: Updated SleepEEGSim object with all components deactivated.

            obj.Aperiodic.isActive = false;
            obj.Slow_Waves.isActive = false;
            obj.Artifacts.isActive = false;

            for ii = 1:length(obj.OscillatorSets)
                obj.OscillatorSets(ii).isActive = false;
            end

            for ii = 1:length(obj.SpindleSets)
                obj.SpindleSets(ii).isActive = false;
            end

            for ii = 1:length(obj.LineNoiseSets)
                obj.LineNoiseSets(ii).isActive = false;
            end
        end

        function obj = activateAll(obj)
            %ACTIVATEALL Activate all components of the SleepEEGSim object
            %
            %   This method activates all components of the SleepEEGSim object by setting
            %   their 'isActive' property to true. This includes Aperiodic, Slow_Waves,
            %   Artifacts, OscillatorSets, SpindleSets, and LineNoiseSets.
            %
            %   Inputs:
            %       obj: SleepEEGSim object - instance of the SleepEEGSim class
            %
            %   Outputs:
            %       obj: Updated SleepEEGSim object with all components activated.


            obj.Aperiodic.isActive = true;
            obj.Slow_Waves.isActive = true;
            obj.Artifacts.isActive = true;

            for ii = 1:length(obj.OscillatorSets)
                obj.OscillatorSets(ii).isActive = true;
            end

            for ii = 1:length(obj.SpindleSets)
                obj.SpindleSets(ii).isActive = true;
            end

            for ii = 1:length(obj.LineNoiseSets)
                obj.LineNoiseSets(ii).isActive = true;
            end
        end

        function obj = genSignal(obj)
            %GENSIGNAL Generate the composite signal based on active components
            %
            %   This method generates a composite signal by summing the signals from all
            %   active components of the SleepEEGSim object. Components are considered active
            %   based on their 'isActive' property. If no components are active, the signal
            %   will be zero.
            %
            %   Inputs:
            %       obj: SleepEEGSim object - instance of the SleepEEGSim class
            %
            %   Outputs:
            %       obj: Updated SleepEEGSim object with the generated signal stored in the 'Signal' property.


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

            for ii = 1:length(obj.OscillatorSets)
                if obj.OscillatorSets(ii).isActive
                    signal = signal + obj.OscillatorSets(ii).Signal;
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

            obj.Signal = signal;
        end

        function plotSpect(obj)
            %PLOTSPECT Plot the spectrogram of the generated signal
            %
            %   This method generates the signal using the genSignal method and then
            %   computes and plots its spectrogram using the multitaper_spectrogram_mex function.
            %   The plot displays the mean power spectral density in decibels.
            %
            %   Inputs:
            %       obj: SleepEEGSim object - instance of the SleepEEGSim class
            %
            %   Outputs:
            %       None. This method generates a plot of the spectrogram.
            %
            %   Example:
            %       % Create an instance of SleepEEGSim and generate the signal
            %       eeg_sim = SleepEEGSim();
            %       % Plot the spectrogram
            %       eeg_sim.plotSpect();

            figure;

            obj.genSignal;
            [spect, ~, sfreqs] = multitaper_spectrogram_mex(obj.Signal, obj.Fs, [.1 obj.Fs/2], [15 29], [30 5], 'plot_on', false);

            plot(sfreqs, pow2db(mean(spect, 2)));
            axis tight;
            xlabel('Frequency (Hz)')
            ylabel('Power (dB)')
            grid on

            title("Simulation Power Spectrum")
        end

        function plot(obj, visual_filter, spect_range)
            %PLOT Generate plots for the simulated EEG signal and its components
            %
            %   This method generates several plots related to the simulated EEG signal.
            %   If the signal has not been generated yet, it will first call the simulation
            %   function. The plots include the spectrogram of the signal, the simulated
            %   signal itself, individual spindle components, slow waves, and phase information.
            %   Additionally, it plots the modulation history and phase histogram of spindles if
            %   spindle data is present.
            %
            %   Inputs:
            %       obj: SleepEEGSim object - instance of the SleepEEGSim class
            %       visual_filter: logical - Filter the display of the EEG time
            %           series between .3 and 35Hz (default: true)
            %       spect_range: double 1x2 - frequency range of the
            %                       spectrogram (default: 0.1 Hz - Nyquist)
            %
            %   Outputs:
            %       None. This method generates and displays multiple plots, including:
            %       - Spectrogram of the simulated EEG signal
            %       - Time series of the simulated EEG signal
            %       - Individual spindle components
            %       - Slow waves and phase information
            %       - Modulation history curve and phase histogram of spindles (if spindle data are present)
            %
            %   Example:
            %       SS = SleepEEGSim('demo');
            %       SS.plot(true,[.5 25])

            if isempty(obj.Signal)
                obj.sim;
            end

            if nargin<2
                visual_filter = true;
            end

            if nargin<3
                spect_range = [.1 obj.Fs/2];
            end

            %Set consistent plot colors for each spindle set
            plot_colors = ...
                [     0    0.4470    0.7410;
                0.8500    0.3250    0.0980;
                0.9290    0.6940    0.1250;
                0.4940    0.1840    0.5560;
                0.4660    0.6740    0.1880;
                0.3010    0.7450    0.9330;
                0.6350    0.0780    0.1840];

            %Compute MTS
            warning('off')
            [spect, stimes, sfreqs] = multitaper_spectrogram_mex(obj.Signal, obj.Fs, spect_range, [2 3], [1 .05], 2^10,'constant','plot_on',false,'verbose',false);
            warning('on')

            %Estimate history for each spindle set
            if ~isempty(obj.SpindleSets)
                [t_sp, b, yhat, dylo, dyhi] = obj.fit_ppsplines(obj.t, obj.SO_phase, obj.SpindleSets);
            end

            if isempty(obj.mainplot_fig) | ~ishandle(obj.mainplot_fig)
                obj.mainplot_fig=figure;

                %Plot simulated signal
                ax = figdesign(1,1,'orient','landscape','margin',[.1 .1 .05, .33  .03]);
                set(obj.mainplot_fig,"Position",[0.0270    0.0701    0.8710    0.8576]);

                obj.signal_ax = split_axis(ax,[.7 .1 .1 .1], 1);
                set(obj.signal_ax,'nextplot','replacechildren');

                %Create history and spike histogram axes
                obj.phasehist_ax = polaraxes('position',[0.7636    0.5732    0.2087    0.3507]);
                obj.history_ax = axes('Position',[0.7336    0.1    0.2346    0.3415]);

                %Add scroll zoom pan first time
                addszp = true;

                %Remove figdesign menu
                delete(findobj(obj.mainplot_fig,'type','uimenu'))


                f = uimenu('Label','SleepEEGSim');
                uimenu(f,'Label','Set Active Components...','Callback',@(src,evnt)obj.setActive);
                uimenu(f,'Label','Replot','Callback',@(src,evnt)obj.plot);
                uimenu(f,'Label','Simulate Again','Callback',@(src,evnt)obj.sim);
                uimenu(f,'Label','Plot Components','Callback',@(src,evnt)obj.plotComponents);
                uimenu(f,'Label','Plot Spectrum','Callback',@(src,evnt)obj.plotSpect);

            else
                figure(obj.mainplot_fig);
                addszp = false;
            end
            %Plot spectrogram
            axes(obj.signal_ax(1))
            hold off;
            imagesc(stimes,sfreqs,pow2db(spect));
            axis xy;
            climscale;
            colorbar_noresize;
            colormap(rainbow4);

            if ~isempty(obj.SpindleSets) & any([obj.SpindleSets.isActive])
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
            linkaxes(obj.signal_ax,'x')
            linkaxes(obj.signal_ax([2,3]),'y')

            %Apply visual filter if needed
            if visual_filter
                ts_plot = obj.visfilt_EEG;
            else
                ts_plot = obj.Signal;
            end

            %Plot filtered EEG signal
            axes(obj.signal_ax(2))
            hold off;
            plot(obj.t,ts_plot,'k')

            set(gca,'xtick',[],'fontsize',15);
            xlabel('Time (s)');
            ylabel('mV');
            pt = prctile(abs(ts_plot),99)+10;
            ylim(obj.signal_ax(2),[-pt pt])

            %Plot spindle components
            axes(obj.signal_ax(3))
            hold off;
            if ~isempty(obj.SpindleSets)
                hold all
                for ii = 1:length(obj.SpindleSets)
                    if obj.SpindleSets(ii).isActive
                        plot(obj.t,obj.SpindleSets(ii).Signal,'color',plot_colors(ii,:));
                    end
                end
            end

            ylim(obj.signal_ax(3),[-pt pt])
            ylabel('mV');
            set(gca,'xtick',[],'fontsize',15);

            %Plot SO and Phase on the same axis
            %SO
            axes(obj.signal_ax(4))
            hold off;
            yyaxis left;
            plot(obj.t,obj.SO_EEG,'linewidth',2);
            ylabel('SO (mV)')
            set(gca,'fontsize',15);
            ylim(obj.signal_ax(4),[-pt pt])
            set(gca,'fontsize',15);

            %Phase
            yyaxis right;
            plot(obj.t, obj.SO_phase,'color','r')
            set(gca,'ytick',[-1 -1/2 0 1/2 1]*pi,'yticklabel',{'-\pi' '-\pi/2' '0' '\pi/2' '\pi'});
            ylabel('SO Phase (rad)');
            ylim([-pi pi])

            xlabel('Time (s)')
            set(gca,'fontsize',15);

            %Plot the history modulation curves
            if ~isempty(obj.SpindleSets)
                axes(obj.history_ax)
                leg_str = {};
                hold off

                for ss = 1:length(obj.SpindleSets)
                    if obj.SpindleSets(ss).isActive
                        c = exp(b{ss}(1));

                        plot(t_sp{ss}, yhat{ss} / c,  'color', plot_colors(ss,:), 'linewidth', 2);
                        hold on
                        %Plot true curve dashed
                        obj.SpindleSets(ss).plot_spline('linewidth',1,'linestyle','--','color', plot_colors(ss,:));
                        fill([t_sp{ss}, fliplr(t_sp{ss})], [yhat{ss} / c - dylo{ss} / c; flipud(yhat{ss} / c + dyhi{ss} / c)],  plot_colors(ss,:), 'FaceAlpha', 0.2, 'EdgeColor', 'none');
                        sfreq = [num2str(obj.SpindleSets(ss).Freq_mean) 'Hz'];
                        leg_str = [leg_str(:)' {[sfreq '_{true}'],[sfreq '_{est}'], '95%CI'}];
                    end
                end

                l = legend('Location','northeast');
                l.String = leg_str;

                axis tight;

                xlabel("Time Since Last Spindle (s)")
                ylabel('Modulation Factor')

                set(obj.history_ax,'fontsize',15)
                ylim([0 min(max(ylim(gca)),10)]);
                if any([obj.SpindleSets.isActive])
                    title('History Modulation Curve')
                else
                    title('No Active Spindles')
                end

                polaraxes(obj.phasehist_ax);
                hold off;

                leg_str = {};
                %Plot phase histogram
                for ss = 1:length(obj.SpindleSets)
                    if obj.SpindleSets(ss).isActive
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
                        h_phist(ss) = polarhistogram(obj.SpindleSets(ss).Phase,'Normalization','pdf');
                        obj.phasehist_ax.ThetaAxisUnits = 'radians';
                        obj.phasehist_ax.ThetaTick = 0:pi/4:2*pi;
                        % obj.phasehist_ax.ThetaTickLabel = {'0','\pi/4','\pi/2','3\pi/4' '\pm\pi','-3\pi/4', '-\pi/2','-\pi/4'};
                        obj.phasehist_ax.FontSize = 15;

                        %Add mean arrow
                        hold on
                        pref_model(ss) = polarplot([theta_mod(ss) theta_mod(ss)],[0 rho_mod(ss)],'linestyle','-','color',plot_colors(ss,:),'linewidth',3);
                        pref_est(ss) = polarplot([theta_samp(ss) theta_samp(ss)],[0 rho_samp(ss)],'linestyle','--','color',plot_colors(ss,:),'linewidth',2);

                        h_phist(ss).FaceColor = plot_colors(ss,:);
                        h_phist(ss).FaceAlpha = .4;
                        h_phist(ss).NumBins = 50;

                        sfreq = [num2str(obj.SpindleSets(ss).Freq_mean) 'Hz'];
                        leg_str = [leg_str(:)' {[sfreq ' Phase']}, {'\theta_{true}'},{'\theta_{est}'}];
                    end
                end
                l = legend('Location',"northeastoutside");
                l.String = leg_str;

                if any([obj.SpindleSets.isActive])
                    title('Spindle Phase');
                    % xlabel(['$\hat{\theta}$_{pref}: ' num2str(theta_mod,3)],'interpreter','latexl'));
                else
                    title('No Active Spindles')
                end
            end

            axes(obj.signal_ax(1));

            if addszp
                %Add scrollbars and adjust axes
                axes(obj.signal_ax(1))
                xlim([min(obj.t) max(obj.t)])

                [obj.zslider, obj.pslider, obj.zedit, obj.pedit, zlabel, plabel] = scrollzoompan(obj.signal_ax(1));
                obj.pedit.FontSize = 15;
                obj.zedit.FontSize = 15;
                zlabel.FontSize = 20;
                plabel.FontSize = 20;
            end

            mid = mean(xlim(obj.signal_ax(1)));
            xlim(obj.signal_ax(1), mid + [-15 15]);
            obj.zslider.Value = 30;
            obj.zedit.String = '30';
            obj.pslider.Value = mid;
            obj.pedit.String = mid;

        end

        function [components, names]= getComponents(obj)
            %GETCOMPONENTS Get a matrix of signal components and associated names
            %
            %   This method returns the signal components and names
            %
            %   Inputs:
            %       obj: SleepEEGSim object - instance of the SleepEEGSim class
            %
            %   Outputs:
            %       components: N x T A matrix of signal components
            %       names: 1 x N cell of chars of signal names

            assert(~isempty(obj.Signal), 'Must have valid signal generated. Run simulation');

            N = obj.numComponents;
            T = length(obj.Signal);

            %Check for empty object
            if N == 0
                components = nan;
                return;
            end

            components = zeros(N,T);
            cc = 1;

            if ~isempty(obj.Aperiodic)
                components(cc,:) = obj.Aperiodic.Signal;
                cc = cc + 1;
            end

            if ~isempty(obj.Slow_Waves)
                components(cc,:) = obj.Slow_Waves.Signal;
                cc = cc + 1;
            end

            if ~isempty(obj.OscillatorSets)
                for ii = 1:length(obj.OscillatorSets)
                    band = obj.OscillatorSets(ii);
                    components(cc,:) = band.Signal;
                    cc = cc + 1;
                end
            end

            if ~isempty(obj.SpindleSets)
                for ii = 1:length(obj.SpindleSets)
                    spindle = obj.SpindleSets(ii);
                    components(cc,:) = spindle.Signal;
                    cc = cc + 1;
                end
            end

            if ~isempty(obj.LineNoiseSets)
                for ii = 1:length(obj.LineNoiseSets)
                    ln = obj.LineNoiseSets(ii);
                    components(cc,:) = ln.Signal;
                    cc = cc + 1;
                end
            end

            if ~isempty(obj.Artifacts)
                components(cc,:) = obj.Artifacts.Signal;
            end

            if nargout == 2
                names = obj.componentNames;
            end
        end

        function isActive = getActive(obj)
            %ISACTIVE Show the activation of each componentn
            %
            %   This method return a vector of isActive properties of the
            %   model components
            %
            %   Inputs:
            %       obj: SleepEEGSim object - instance of the SleepEEGSim class
            %
            %   Outputs:
            %       isActive: 1 x N A logical vector of activation states

            isActive = false(1, obj.numComponents);

            cc = 1;
            if ~isempty(obj.Aperiodic)
                isActive(cc) = obj.Aperiodic.isActive;
                cc = cc+1;
            end

            if ~isempty(obj.Slow_Waves)
                isActive(cc) =  obj.Slow_Waves.isActive;
                cc = cc+1;
            end

            if ~isempty(obj.OscillatorSets)
                for ii = 1:length(obj.OscillatorSets)
                    band = obj.OscillatorSets(ii);
                    isActive(cc) =  band.isActive;
                    cc = cc+1;
                end
            end

            if ~isempty(obj.SpindleSets)
                for ii = 1:length(obj.SpindleSets)
                    spindle = obj.SpindleSets(ii);
                    isActive(cc) =  spindle.isActive;
                    cc = cc+1;
                end
            end

            if ~isempty(obj.LineNoiseSets)
                for ii = 1:length(obj.LineNoiseSets)
                    ln = obj.LineNoiseSets(ii);
                    isActive(cc) =  ln.isActive;
                    cc = cc+1;
                end
            end

            if ~isempty(obj.Artifacts)
                isActive(cc) =  obj.Artifacts.isActive;
            end
        end

        function setActive(obj, isActive)
            %ISACTIVE Shows the activation state of each component
            %
            %   This method sets the isActive properties of the model
            %   components. Runs interactively with no input
            %
            %   Inputs:
            %       obj: SleepEEGSim object - instance of the SleepEEGSim class
            %       isActive: 1 x N (number of components) logical vector
            %       to set the isActive state of each component
            %
            %   Outputs:
            %       isActive: 1 x N A logical vector of activation states

            %Do interactive
            if nargin == 1 | isempty(isActive)
                obj.makeSelectTree;
                return;
            end

            %Check the correct number of components
            assert(length(isActive) == obj.numComponents, ['Number of active components must be ' num2str(obj.numComponents)]);

            cc = 1;
            if ~isempty(obj.Aperiodic)
                obj.Aperiodic.isActive = isActive(cc);
                cc = cc+1;
            end

            if ~isempty(obj.Slow_Waves)
                obj.Slow_Waves.isActive = isActive(cc);
                cc = cc+1;
            end


            if ~isempty(obj.OscillatorSets)
                for ii = 1:length(obj.OscillatorSets)
                    band = obj.OscillatorSets(ii);
                    band.isActive = isActive(cc);
                    cc = cc+1;
                end
            end

            if ~isempty(obj.SpindleSets)
                for ii = 1:length(obj.SpindleSets)
                    spindle = obj.SpindleSets(ii);
                    spindle.isActive = isActive(cc);
                    cc = cc+1;
                end
            end

            if ~isempty(obj.LineNoiseSets)
                for ii = 1:length(obj.LineNoiseSets)
                    ln = obj.LineNoiseSets(ii);
                    ln.isActive = isActive(cc);
                    cc = cc+1;
                end
            end

            if ~isempty(obj.Artifacts)
                obj.Artifacts.isActive = isActive(cc);
            end

            %Generate the updated signal
            obj.genSignal;
        end


        function N = numComponents(obj)
            %NUMCOMPONENTS Return the number of components
            %
            %   This method computes the number of model components
            %
            %   Inputs:
            %       obj: SleepEEGSim object - instance of the SleepEEGSim class
            %
            %   Outputs:
            %       N: The number of components

            N = 0;

            if ~isempty(obj.Aperiodic)
                N = N+1;
            end

            if ~isempty(obj.Slow_Waves)
                N = N+1;
            end

            if ~isempty(obj.OscillatorSets)
                N = N + length(obj.OscillatorSets);
            end

            if ~isempty(obj.SpindleSets)
                N = N + length(obj.SpindleSets);
            end

            if ~isempty(obj.LineNoiseSets)
                N = N + length(obj.LineNoiseSets);
            end

            if ~isempty(obj.Artifacts)
                N = N + 1;
            end
        end

        function component_names = componentNames(obj)
            %COMPONENTNAMES Gets the name of each component
            %
            %   This method returns the component names of all components
            %
            %   Inputs:
            %       obj: SleepEEGSim object - instance of the SleepEEGSim class
            %
            %   Outputs:
            %       component_names: 1 x N A string vector of component
            %       names

            component_names = {};

            if ~isempty(obj.Aperiodic)
                component_names{end+1} = 'Aperiodic';
            end

            if ~isempty(obj.Slow_Waves)
                component_names{end+1} = 'Slow Waves';
            end

            if ~isempty(obj.OscillatorSets)
                for ii = 1:length(obj.OscillatorSets)
                    osc = obj.OscillatorSets(ii);
                    component_names{end+1} = ['OscillatorSet ' num2str(osc.Freq)];
                end
            end

            if ~isempty(obj.SpindleSets)
                for ii = 1:length(obj.SpindleSets)
                    spindle = obj.SpindleSets(ii);
                    component_names{end+1} = ['Spindles ' num2str(spindle.Freq_mean) 'Hz'];
                end
            end

            if ~isempty(obj.LineNoiseSets)
                for ii = 1:length(obj.LineNoiseSets)
                    ln = obj.LineNoiseSets(ii);
                    component_names{end+1} = ['Line Noise ' ln.Waveform ' ' num2str(ln.Freq) 'Hz'];
                end
            end

            if ~isempty(obj.Artifacts)
                component_names{end+1} = 'Artifacts';
            end
        end

        function plotComponents(obj)
            %PLOTCOMPONENTS Plot all signal components
            %
            %   This method plots each of the components on a large plot in
            %   separate axes
            %
            %   Inputs:
            %       obj: SleepEEGSim object - instance of the SleepEEGSim class
            %
            %   Outputs:
            %       None. This method generates a plot of the spectrogram.
            %
            %   Example:
            %       % Create an instance of SleepEEGSim and generate the signal
            %       eeg_sim = SleepEEGSim('demo');
            %       % Plot the spectrogram
            %       eeg_sim.plotComponents();

            [comps, names] = obj.getComponents;
            N = obj.numComponents;

            if isempty(obj.component_fig) | ~ishandle(obj.component_fig)
                obj.component_fig = figure;
            end

            obj.comp_ax = figdesign(N,1,'type','usletter','orient','landscape','margins',[.05 .1 .1 .025 .03]);
            set(obj.component_fig,'Position',[0.0619    0.0861    0.6395    0.8333]);


            outerlabels(obj.comp_ax,'Time (s)','Components')

            for ii = 1:N
                axes(obj.comp_ax(ii)) %#ok<*LAXES>
                plot(obj.t, comps(ii,:))
                axis tight
                title(names{ii})
            end
            linkaxes(obj.comp_ax,'x');
            set(obj.comp_ax,'fontsize',15)
            set(obj.comp_ax(1:end-1),'xtick',[]);

            scrollzoompan(obj.comp_ax)
        end

        function editSimulation(obj)
            %Create basic figure components
            [UIFigure, TabGroup]  = createFigureComponents(obj);

            % Create AperiodicEEGTab
            if ~isempty(obj.Aperiodic)
               createAperiodicTab(TabGroup, obj);
            end


            % Create SlowWavesTab
            if ~isempty(obj.Slow_Waves)
                    createSlowWavesTab(TabGroup, obj);
            end

            % Create SpindleTab
            if ~isempty(obj.SpindleSets)
                for ss = 1:length(obj.SpindleSets)
                        createSpindlesTab(TabGroup, obj, ss);
                end
            end

            % Create OscillatorTab
            if ~isempty(obj.OscillatorSets)
                for osc_num = 1:length(obj.OscillatorSets)
                        createOscillatorTab(TabGroup, obj, osc_num);
                end
            end

            % Create LineNoiseTab
            if ~isempty(obj.LineNoiseSets)
                for ln_num = 1:length(obj.LineNoiseSets)
                        createLineNoiseTab(TabGroup, obj, ln_num);
                end
            end

            % Create ArtifactsTab
            if ~isempty(obj.Artifacts)
                createArtifactsTab(TabGroup, obj);
            end


            % Show the figure after aln_num components are created
            UIFigure.Visible = 'on';

            function updateAperiodic(~,~,obj, Aperiodic_AlphaEditField, Aperiodic_MagnitudeEditField, Aperiodic_UIAxes)
                obj.Aperiodic.Alpha = Aperiodic_AlphaEditField.Value;
                obj.Aperiodic.Magnitude = Aperiodic_MagnitudeEditField.Value;

                f = linspace(0,60);
                p = Aperiodic_MagnitudeEditField.Value./(f.^Aperiodic_AlphaEditField.Value);
                plot(Aperiodic_UIAxes,f,pow2db(p),'linewidth',2)
            end

            function updateSlowWaves(~,~,obj, ratefield, ampmeanfield, ampsdfield, durmeanfield, dursdfield)
                obj.Slow_Waves.Rate = ratefield.Value;
                obj.Slow_Waves.Amp_mean = ampmeanfield.Value;
                obj.Slow_Waves.Amp_sd = ampsdfield.Value;
                obj.Slow_Waves.Dur_mean = durmeanfield.Value;
                obj.Slow_Waves.Dur_sd = dursdfield.Value;
            end

            function updateArtifacts(~,~,obj, ratefield, ampmeanfield, ampsdfield, ampminfield)
                obj.Artifacts.Rate = ratefield.Value;
                obj.Artifacts.Amp_mean = ampmeanfield.Value;
                obj.Artifacts.Amp_sd = ampsdfield.Value;
                obj.Artifacts.Amp_min = ampminfield.Value;
            end

            function updateSpindles(~,~,obj, ss, SpindlesTab,...
                    Spindles_UIAxes, Spindles_FreqSDEditField, Spindles_AmpMeanEditField, ...
                    Spindles_AmpSDEditField, Spindles_FreqMeanEditField, Spindles_DurMeanEditField, ...
                    Spindles_DurSDEditField, Spindles_BaselineRateEditField, Spindles_StartTimeEditField, ...
                    Spindles_ModulationFactEditField, Spindles_PhasePrefEditField, Spindles_MaxTimeEditField, ...
                    Spindles_TensionEditField, Spindles_ControlPointsEditField, Spindles_SplineValueEditField, ...
                    Spindles_AmpMinEditField, Spindles_DurMinEditField)

                obj.SpindleSets(ss).Freq_sd = Spindles_FreqSDEditField.Value;
                obj.SpindleSets(ss).Amp_mean = Spindles_AmpMeanEditField.Value;
                obj.SpindleSets(ss).Amp_sd = Spindles_AmpSDEditField.Value;
                obj.SpindleSets(ss).Freq_mean = Spindles_FreqMeanEditField.Value;
                obj.SpindleSets(ss).Dur_mean = Spindles_DurMeanEditField.Value;
                obj.SpindleSets(ss).Dur_sd = Spindles_DurSDEditField.Value;
                obj.SpindleSets(ss).Baseline_rate = Spindles_BaselineRateEditField.Value;
                obj.SpindleSets(ss).Start_time = Spindles_StartTimeEditField.Value;
                obj.SpindleSets(ss).Modulation_factor = Spindles_ModulationFactEditField.Value;
                obj.SpindleSets(ss).Phase_pref = eval(Spindles_PhasePrefEditField.Value);
                obj.SpindleSets(ss).Spline_tmax = Spindles_MaxTimeEditField.Value;
                obj.SpindleSets(ss).Tension = Spindles_TensionEditField.Value;
                obj.SpindleSets(ss).Ctrl_pts = eval(Spindles_ControlPointsEditField.Value);
                obj.SpindleSets(ss).Theta_spline = eval(Spindles_SplineValueEditField.Value);
                obj.SpindleSets(ss).Amp_min = Spindles_AmpMinEditField.Value;
                obj.SpindleSets(ss).Dur_min = Spindles_DurMinEditField.Value;

                obj.SpindleSets(ss).genS;
                obj.SpindleSets(ss).plot_spline(Spindles_UIAxes,'linewidth',2);
                SpindlesTab.Title = ['Spindles ' num2str(obj.SpindleSets(ss).Freq_mean) 'Hz'];
            end

            function updateLineNoise(~,~,obj, ln_num, LineNoiseTab, LineNoise_FreqEditField, LineNoise_AmpEditField, LineNoise_WaveformDropDown, LineNoise_UIAxes)
                obj.LineNoiseSets(ln_num).Freq = LineNoise_FreqEditField.Value;
                obj.LineNoiseSets(ln_num).Amp = LineNoise_AmpEditField.Value;
                obj.LineNoiseSets(ln_num).Waveform = LineNoise_WaveformDropDown.Value;

                LineNoiseTab.Title = ['Line Noise ' obj.LineNoiseSets(ln_num).Waveform ' ' num2str(obj.LineNoiseSets(ln_num).Freq) 'Hz' ];

                f  = obj.LineNoiseSets(ln_num).Freq;
                a = obj.LineNoiseSets(ln_num).Amp ;

                Fs = max(500, f*2);
                t = 0:(1/Fs):1; %Plot 1s of data

                switch obj.LineNoiseSets(ln_num).Waveform
                    case 'sin'
                        ln_fun = @sin;
                    case 'sawtooth'
                        ln_fun = @sawtooth;
                    case 'square'
                        ln_fun = @square;
                    otherwise
                        error('Invalid line noise function type. Options are sin, square, and sawtooth');
                end

                y  = a * ln_fun(2 * pi * t * f);

                plot(LineNoise_UIAxes, t, y);
            end

            function updateOscillator(~,~,obj, o_num, OscillatorTab, Oscillator_FreqEditField, Oscillator_StateNoiseEditField, Oscillator_ObsNoiseEditField, Oscillator_DampingFactorEditField, Oscillator_AmpMultEditField, Oscillator_UIAxes)
                obj.OscillatorSets(o_num).Freq= Oscillator_FreqEditField.Value;
                obj.OscillatorSets(o_num).StateNoise= Oscillator_StateNoiseEditField.Value;
                obj.OscillatorSets(o_num).ObsNoise= Oscillator_ObsNoiseEditField.Value;
                obj.OscillatorSets(o_num).DampingFactor= Oscillator_DampingFactorEditField.Value;
                obj.OscillatorSets(o_num).AmpMult= Oscillator_AmpMultEditField.Value;

                OscillatorTab.Title = ['Oscillator ' num2str(obj.OscillatorSets(o_num).Freq) 'Hz' ];

                f  = obj.OscillatorSets(o_num).Freq;

                Fs = max(500, f*2);

                t = 0:(1/Fs):1; %Plot 1s of data

                %Save signal
                o_sig = obj.OscillatorSets(o_num).Signal;

                %Simulate a short signal
                y = obj.OscillatorSets(o_num).sim(t);

                %Restore old signal
                obj.OscillatorSets(o_num).Signal = o_sig;

                %Plot
                plot(Oscillator_UIAxes, t, y);
            end


            function [AperiodicEEGTab, Aperiodic_MagnitudeEditField, Aperiodic_AlphaEditField, Aperiodic_UIAxes] = createAperiodicTab(TabGroup, obj)
                AperiodicEEGTab = uitab(TabGroup);
                AperiodicEEGTab.Title = 'Aperiodic EEG';

                % Create MagnitudeEditFieldLabel
                Aperiodic_MagnitudeEditFieldLabel = uilabel(AperiodicEEGTab);
                Aperiodic_MagnitudeEditFieldLabel.HorizontalAlignment = 'right';
                Aperiodic_MagnitudeEditFieldLabel.Position = [20 345 62 22];
                Aperiodic_MagnitudeEditFieldLabel.Text = 'Magnitude';

                % Create Aperiodic_MagnitudeEditField
                Aperiodic_MagnitudeEditField = uieditfield(AperiodicEEGTab, 'numeric');
                Aperiodic_MagnitudeEditField.Position = [123 345 103 22];

                % Create AlphaEditFieldLabel
                Aperiodic_AlphaEditFieldLabel = uilabel(AperiodicEEGTab);
                Aperiodic_AlphaEditFieldLabel.HorizontalAlignment = 'right';
                Aperiodic_AlphaEditFieldLabel.Position = [18 377 64 22];
                Aperiodic_AlphaEditFieldLabel.Text = 'Alpha';

                % Create Aperiodic_AlphaEditField
                Aperiodic_AlphaEditField = uieditfield(AperiodicEEGTab, 'numeric');
                Aperiodic_AlphaEditField.Position = [123 377 103 22];

                % Create Aperiodic_UIAxes
                Aperiodic_UIAxes = uiaxes(AperiodicEEGTab);
                title(Aperiodic_UIAxes, 'Aperiodic EEG')
                xlabel(Aperiodic_UIAxes, 'Frequency (Hz)')
                ylabel(Aperiodic_UIAxes, 'Power (dB)')
                Aperiodic_UIAxes.Position = [250 12 680 412];

                [Aperiodic_AlphaEditField, Aperiodic_MagnitudeEditField] = fillAperiodic(Aperiodic_AlphaEditField, Aperiodic_MagnitudeEditField, Aperiodic_UIAxes, obj);

                aperiodicCallback =  {@updateAperiodic, obj, Aperiodic_AlphaEditField, Aperiodic_MagnitudeEditField, Aperiodic_UIAxes};
                Aperiodic_AlphaEditField.ValueChangedFcn = aperiodicCallback;
                Aperiodic_MagnitudeEditField.ValueChangedFcn = aperiodicCallback;
            end

            function [SlowWavesTab, SlowWaves_AmpMeanEditField, SlowWaves_AmpSDEditField, SlowWaves_DurMeanEditField, ...
                    SlowWaves_DurSDEditField, SlowWaves_RateEditField] = createSlowWavesTab(TabGroup, obj)
                SlowWavesTab = uitab(TabGroup);
                SlowWavesTab.Title = 'Slow Waves';

                % Create AmpMeanEditFieldLabel
                SlowWaves_AmpMeanEditFieldLabel = uilabel(SlowWavesTab);
                SlowWaves_AmpMeanEditFieldLabel.HorizontalAlignment = 'right';
                SlowWaves_AmpMeanEditFieldLabel.Position = [15 345 67 22];
                SlowWaves_AmpMeanEditFieldLabel.Text = 'Amp. Mean';

                % Create SlowWaves_AmpMeanEditField
                SlowWaves_AmpMeanEditField = uieditfield(SlowWavesTab, 'numeric');
                SlowWaves_AmpMeanEditField.Position = [123 345 103 22];

                % Create AmpSDEditFieldLabel
                SlowWaves_AmpSDEditFieldLabel = uilabel(SlowWavesTab);
                SlowWaves_AmpSDEditFieldLabel.HorizontalAlignment = 'right';
                SlowWaves_AmpSDEditFieldLabel.Position = [29 313 53 22];
                SlowWaves_AmpSDEditFieldLabel.Text = 'Amp. SD';

                % Create SlowWaves_AmpSDEditField
                SlowWaves_AmpSDEditField = uieditfield(SlowWavesTab, 'numeric');
                SlowWaves_AmpSDEditField.Position = [123 313 103 22];

                % Create DurMeanEditFieldLabel
                SlowWaves_DurMeanEditFieldLabel = uilabel(SlowWavesTab);
                SlowWaves_DurMeanEditFieldLabel.HorizontalAlignment = 'right';
                SlowWaves_DurMeanEditFieldLabel.Position = [22 278 60 22];
                SlowWaves_DurMeanEditFieldLabel.Text = 'Dur. Mean';

                % Create SlowWaves_DurMeanEditField
                SlowWaves_DurMeanEditField = uieditfield(SlowWavesTab, 'numeric');
                SlowWaves_DurMeanEditField.Position = [123 278 103 22];

                % Create DurSDEditFieldLabel
                SlowWaves_DurSDEditFieldLabel = uilabel(SlowWavesTab);
                SlowWaves_DurSDEditFieldLabel.HorizontalAlignment = 'right';
                SlowWaves_DurSDEditFieldLabel.Position = [36 246 46 22];
                SlowWaves_DurSDEditFieldLabel.Text = 'Dur. SD';

                % Create SlowWaves_DurSDEditField
                SlowWaves_DurSDEditField = uieditfield(SlowWavesTab, 'numeric');
                SlowWaves_DurSDEditField.Position = [123 246 103 22];

                % Create RateEditFieldLabel
                SlowWaves_RateEditFieldLabel = uilabel(SlowWavesTab);
                SlowWaves_RateEditFieldLabel.HorizontalAlignment = 'right';
                SlowWaves_RateEditFieldLabel.Position = [18 377 64 22];
                SlowWaves_RateEditFieldLabel.Text = 'Rate';

                % Create SlowWaves_RateEditField
                SlowWaves_RateEditField = uieditfield(SlowWavesTab, 'numeric');
                SlowWaves_RateEditField.Position = [123 377 103 22];


                [SlowWaves_RateEditField, SlowWaves_AmpMeanEditField, SlowWaves_AmpSDEditField, SlowWaves_DurMeanEditField, SlowWaves_DurSDEditField] = fillSlowWaves(SlowWaves_RateEditField, SlowWaves_AmpMeanEditField, SlowWaves_AmpSDEditField, SlowWaves_DurMeanEditField, SlowWaves_DurSDEditField, obj);


                SWCallback = {@updateSlowWaves, obj, SlowWaves_RateEditField, SlowWaves_AmpMeanEditField, SlowWaves_AmpSDEditField, SlowWaves_DurMeanEditField, SlowWaves_DurSDEditField};

                SlowWaves_RateEditField.ValueChangedFcn = SWCallback;
                SlowWaves_AmpSDEditField.ValueChangedFcn = SWCallback;
                SlowWaves_AmpMeanEditField.ValueChangedFcn = SWCallback;
                SlowWaves_DurSDEditField.ValueChangedFcn = SWCallback;
                SlowWaves_DurMeanEditField.ValueChangedFcn = SWCallback;
            end

            function [SpindlesTab, Spindles_UIAxes, Spindles_FreqSDEditField, Spindles_AmpMeanEditField, Spindles_AmpSDEditField, ...
                    Spindles_FreqMeanEditField, Spindles_DurMeanEditField, Spindles_DurSDEditField,Spindles_DurMinEditField, Spindles_BaselineRateEditField, ...
                    Spindles_StartTimeEditField, Spindles_ModulationFactEditField, Spindles_PhasePrefEditField, Spindles_MaxTimeEditField,...
                    Spindles_TensionEditField, Spindles_ControlPointsEditField, Spindles_SplineValueEditField, Spindles_AmpMinEditField] = createSpindlesTab(TabGroup, obj,ss)
                % Create SpindlesTab
                SpindlesTab = uitab(TabGroup);

                % Create Spindles_UIAxes
                Spindles_UIAxes = uiaxes(SpindlesTab);
                title(Spindles_UIAxes, 'History Modulation Curve')
                xlabel(Spindles_UIAxes, 'Time Since Last Spindle (s)')
                ylabel(Spindles_UIAxes, 'Modulation Factor')
                Spindles_UIAxes.Position = [295 97 625 332];

                % Create Spindles_FreqSDEditFieldLabel
                Spindles_FreqSDEditFieldLabel = uilabel(SpindlesTab);
                Spindles_FreqSDEditFieldLabel.HorizontalAlignment = 'right';
                Spindles_FreqSDEditFieldLabel.Position = [47 378 52 22];
                Spindles_FreqSDEditFieldLabel.Text = 'Freq. SD';

                % Create Spindles_FreqSDEditField
                Spindles_FreqSDEditField = uieditfield(SpindlesTab, 'numeric');
                Spindles_FreqSDEditField.Position = [140 378 103 22];

                % Create Spindles_AmpMeanEditFieldLabel
                Spindles_AmpMeanEditFieldLabel = uilabel(SpindlesTab);
                Spindles_AmpMeanEditFieldLabel.HorizontalAlignment = 'right';
                Spindles_AmpMeanEditFieldLabel.Position = [32 346 67 22];
                Spindles_AmpMeanEditFieldLabel.Text = 'Amp. Mean';

                % Create Spindles_AmpMeanEditField
                Spindles_AmpMeanEditField = uieditfield(SpindlesTab, 'numeric');
                Spindles_AmpMeanEditField.Position = [140 346 103 22];

                % Create Spindles_AmpSDEditFieldLabel
                Spindles_AmpSDEditFieldLabel = uilabel(SpindlesTab);
                Spindles_AmpSDEditFieldLabel.HorizontalAlignment = 'right';
                Spindles_AmpSDEditFieldLabel.Position = [46 311 53 22];
                Spindles_AmpSDEditFieldLabel.Text = 'Amp. SD';

                % Create Spindles_AmpSDEditField
                Spindles_AmpSDEditField = uieditfield(SpindlesTab, 'numeric');
                Spindles_AmpSDEditField.Position = [140 311 103 22];

                % Create Spindles_FreqMeanEditFieldLabel
                Spindles_FreqMeanEditFieldLabel = uilabel(SpindlesTab);
                Spindles_FreqMeanEditFieldLabel.HorizontalAlignment = 'right';
                Spindles_FreqMeanEditFieldLabel.Position = [33 410 66 22];
                Spindles_FreqMeanEditFieldLabel.Text = 'Freq. Mean';

                % Create Spindles_FreqMeanEditField
                Spindles_FreqMeanEditField = uieditfield(SpindlesTab, 'numeric');
                Spindles_FreqMeanEditField.Position = [140 410 103 22];

                % Create Spindles_DurMeanEditFieldLabel
                Spindles_DurMeanEditFieldLabel = uilabel(SpindlesTab);
                Spindles_DurMeanEditFieldLabel.HorizontalAlignment = 'right';
                Spindles_DurMeanEditFieldLabel.Position = [40 244 60 22];
                Spindles_DurMeanEditFieldLabel.Text = 'Dur. Mean';

                % Create Spindles_DurMeanEditField
                Spindles_DurMeanEditField = uieditfield(SpindlesTab, 'numeric');
                Spindles_DurMeanEditField.Position = [141 244 103 22];

                % Create Spindles_DurSDEditFieldLabel
                Spindles_DurSDEditFieldLabel = uilabel(SpindlesTab);
                Spindles_DurSDEditFieldLabel.HorizontalAlignment = 'right';
                Spindles_DurSDEditFieldLabel.Position = [54 209 46 22];
                Spindles_DurSDEditFieldLabel.Text = 'Dur. SD';

                % Create Spindles_DurSDEditField
                Spindles_DurSDEditField = uieditfield(SpindlesTab, 'numeric');
                Spindles_DurSDEditField.Position = [141 209 103 22];

                % Create Spindles_BaselineRateEditFieldLabel
                Spindles_BaselineRateEditFieldLabel = uilabel(SpindlesTab);
                Spindles_BaselineRateEditFieldLabel.HorizontalAlignment = 'right';
                Spindles_BaselineRateEditFieldLabel.Position = [21 132 79 22];
                Spindles_BaselineRateEditFieldLabel.Text = 'Baseline Rate';

                % Create Spindles_BaselineRateEditField
                Spindles_BaselineRateEditField = uieditfield(SpindlesTab, 'numeric');
                Spindles_BaselineRateEditField.Position = [141 132 103 22];

                % Create Spindles_StartTimeEditFieldLabel
                Spindles_StartTimeEditFieldLabel = uilabel(SpindlesTab);
                Spindles_StartTimeEditFieldLabel.HorizontalAlignment = 'right';
                Spindles_StartTimeEditFieldLabel.Position = [40 97 60 22];
                Spindles_StartTimeEditFieldLabel.Text = 'Start Time';

                % Create Spindles_StartTimeEditField
                Spindles_StartTimeEditField = uieditfield(SpindlesTab, 'numeric');
                Spindles_StartTimeEditField.Position = [141 97 103 22];

                % Create Spindles_ModulationFactEditFieldLabel
                Spindles_ModulationFactEditFieldLabel = uilabel(SpindlesTab);
                Spindles_ModulationFactEditFieldLabel.HorizontalAlignment = 'right';
                Spindles_ModulationFactEditFieldLabel.Position = [9 17 95 22];
                Spindles_ModulationFactEditFieldLabel.Text = 'Modulation Fact.';

                % Create Spindles_ModulationFactEditField
                Spindles_ModulationFactEditField = uieditfield(SpindlesTab, 'numeric');
                Spindles_ModulationFactEditField.Position = [145 17 103 22];

                % Create Spindles_PhasePrefEditFieldLabel
                Spindles_PhasePrefEditFieldLabel = uilabel(SpindlesTab);
                Spindles_PhasePrefEditFieldLabel.HorizontalAlignment = 'right';
                Spindles_PhasePrefEditFieldLabel.Position = [36 49 67 22];
                Spindles_PhasePrefEditFieldLabel.Text = 'Phase Pref.';

                % Create Spindles_PhasePrefEditField
                Spindles_PhasePrefEditField = uieditfield(SpindlesTab, 'text');
                Spindles_PhasePrefEditField.Position = [144 49 103 22];
                Spindles_PhasePrefEditField.HorizontalAlignment = 'right';

                % Create Spindles_MaxTimeEditFieldLabel
                Spindles_MaxTimeEditFieldLabel = uilabel(SpindlesTab);
                Spindles_MaxTimeEditFieldLabel.HorizontalAlignment = 'right';
                Spindles_MaxTimeEditFieldLabel.Position = [706 18 58 22];
                Spindles_MaxTimeEditFieldLabel.Text = 'Max Time';

                % Create Spindles_MaxTimeEditField
                Spindles_MaxTimeEditField = uieditfield(SpindlesTab, 'numeric');
                Spindles_MaxTimeEditField.Position = [809 18 103 22];

                % Create Spindles_TensionEditFieldLabel
                Spindles_TensionEditFieldLabel = uilabel(SpindlesTab);
                Spindles_TensionEditFieldLabel.HorizontalAlignment = 'right';
                Spindles_TensionEditFieldLabel.Position = [721 49 46 22];
                Spindles_TensionEditFieldLabel.Text = 'Tension';

                % Create Spindles_TensionEditField
                Spindles_TensionEditField = uieditfield(SpindlesTab, 'numeric');
                Spindles_TensionEditField.Position = [808 49 103 22];

                % Create Spindles_ControlPointsLabel
                Spindles_ControlPointsLabel = uilabel(SpindlesTab);
                Spindles_ControlPointsLabel.HorizontalAlignment = 'right';
                Spindles_ControlPointsLabel.Position = [334 49 85 22];
                Spindles_ControlPointsLabel.Text = 'Control Points';

                % Create Spindles_ControlPointsEditField
                Spindles_ControlPointsEditField = uieditfield(SpindlesTab, 'text');
                Spindles_ControlPointsEditField.Position = [434 49 249 22];

                % Create Spindles_SplineValueEditFieldLabel
                Spindles_SplineValueEditFieldLabel = uilabel(SpindlesTab);
                Spindles_SplineValueEditFieldLabel.HorizontalAlignment = 'right';
                Spindles_SplineValueEditFieldLabel.Position = [347 18 71 22];
                Spindles_SplineValueEditFieldLabel.Text = 'Spline Value';

                % Create Spindles_SplineValueEditField
                Spindles_SplineValueEditField = uieditfield(SpindlesTab, 'text');
                Spindles_SplineValueEditField.Position = [433 18 250 22];

                % Create Spindles_AmpMinEditFieldLabel
                Spindles_AmpMinEditFieldLabel = uilabel(SpindlesTab);
                Spindles_AmpMinEditFieldLabel.HorizontalAlignment = 'right';
                Spindles_AmpMinEditFieldLabel.Position = [43 276 57 22];
                Spindles_AmpMinEditFieldLabel.Text = 'Amp. Min';

                % Create Spindles_AmpMinEditField
                Spindles_AmpMinEditField = uieditfield(SpindlesTab, 'numeric');
                Spindles_AmpMinEditField.Position = [141 276 103 22];

                % Create Spindles_DurMinEditFieldLabel
                Spindles_DurMinEditFieldLabel = uilabel(SpindlesTab);
                Spindles_DurMinEditFieldLabel.HorizontalAlignment = 'right';
                Spindles_DurMinEditFieldLabel.Position = [50 176 49 22];
                Spindles_DurMinEditFieldLabel.Text = 'Dur. Min';

                % Create Spindles_AmpMinEditField
                Spindles_DurMinEditField = uieditfield(SpindlesTab, 'numeric');
                Spindles_DurMinEditField.Position = [148   176    95    22];

                fillSpindles(Spindles_FreqSDEditField, ss, Spindles_AmpMeanEditField, Spindles_AmpSDEditField, Spindles_FreqMeanEditField, Spindles_DurMeanEditField, ...
                    Spindles_DurSDEditField, Spindles_BaselineRateEditField, Spindles_StartTimeEditField, Spindles_ModulationFactEditField, Spindles_PhasePrefEditField, ...
                    Spindles_MaxTimeEditField, Spindles_TensionEditField, Spindles_ControlPointsEditField, Spindles_SplineValueEditField, Spindles_AmpMinEditField, Spindles_DurMinEditField, obj);


                spindleCallback = {@updateSpindles, obj, ss, SpindlesTab ...
                    Spindles_UIAxes, Spindles_FreqSDEditField, Spindles_AmpMeanEditField, ...
                    Spindles_AmpSDEditField, Spindles_FreqMeanEditField, Spindles_DurMeanEditField, ...
                    Spindles_DurSDEditField, Spindles_BaselineRateEditField, Spindles_StartTimeEditField, ...
                    Spindles_ModulationFactEditField, Spindles_PhasePrefEditField, Spindles_MaxTimeEditField, ...
                    Spindles_TensionEditField, Spindles_ControlPointsEditField, Spindles_SplineValueEditField, ...
                    Spindles_AmpMinEditField, Spindles_DurMinEditField};

                Spindles_FreqSDEditField.ValueChangedFcn = spindleCallback;
                Spindles_AmpMeanEditField.ValueChangedFcn = spindleCallback;
                Spindles_AmpSDEditField.ValueChangedFcn = spindleCallback;
                Spindles_FreqMeanEditField.ValueChangedFcn = spindleCallback;
                Spindles_DurMeanEditField.ValueChangedFcn = spindleCallback;
                Spindles_DurSDEditField.ValueChangedFcn = spindleCallback;
                Spindles_BaselineRateEditField.ValueChangedFcn = spindleCallback;
                Spindles_StartTimeEditField.ValueChangedFcn = spindleCallback;
                Spindles_ModulationFactEditField.ValueChangedFcn = spindleCallback;
                Spindles_PhasePrefEditField.ValueChangedFcn = spindleCallback;
                Spindles_MaxTimeEditField.ValueChangedFcn = spindleCallback;
                Spindles_TensionEditField.ValueChangedFcn = spindleCallback;
                Spindles_ControlPointsEditField.ValueChangedFcn = spindleCallback;
                Spindles_SplineValueEditField.ValueChangedFcn = spindleCallback;
                Spindles_AmpMinEditField.ValueChangedFcn = spindleCallback;
                Spindles_DurMinEditField.ValueChangedFcn = spindleCallback; %#ok<*SAGROW>

                updateSpindles([],[], obj, ss, SpindlesTab,...
                    Spindles_UIAxes, Spindles_FreqSDEditField, Spindles_AmpMeanEditField, ...
                    Spindles_AmpSDEditField, Spindles_FreqMeanEditField, Spindles_DurMeanEditField, ...
                    Spindles_DurSDEditField, Spindles_BaselineRateEditField, Spindles_StartTimeEditField, ...
                    Spindles_ModulationFactEditField, Spindles_PhasePrefEditField, Spindles_MaxTimeEditField, ...
                    Spindles_TensionEditField, Spindles_ControlPointsEditField, Spindles_SplineValueEditField, ...
                    Spindles_AmpMinEditField, Spindles_DurMinEditField);
            end

            function  [UIFigure, TabGroup, SimulationOptionsMenu, PlotButton, PlotSimulationMenu, PlotComponentsMenu,...
                    PlotSpectrumMenu, SetActiveComponentsMenu, ResimulateMenu, AddComponentMenu, AperiodicMenu, SlowWavesMenu, ...
                    SpindlesMenu, LineNoiseMenu, OscillatorMenu, ArtifactsMenu, RemoveComponentMenu] = createFigureComponents(obj)

                % Create UIFigure and hide until aln_num components are created
                UIFigure = uifigure('Visible', 'off');
                UIFigure.AutoResizeChildren = 'off';
                UIFigure.Position = [100 100 974 627];
                UIFigure.Name = 'SleepEEGSim Components';
                UIFigure.Resize = 'off';

                % Create TabGroup
                TabGroup = uitabgroup(UIFigure);
                TabGroup.AutoResizeChildren = 'off';
                TabGroup.Position = [9 100 962 500];

                % Create PlotButton
                PlotButton = uibutton(UIFigure, 'push');
                PlotButton.FontSize = 18;
                PlotButton.Position = [443 30 121 29];
                PlotButton.Text = 'Plot';
                PlotButton.ButtonPushedFcn = @(s,e)obj.plot;

                % Create SimulationOptionsMenu
                SimulationOptionsMenu = uimenu(UIFigure);
                SimulationOptionsMenu.Text = 'Simulation Options';

                % Create PlotSimulationMenu
                PlotSimulationMenu = uimenu(SimulationOptionsMenu);
                PlotSimulationMenu.Text = 'Plot Simulation';
                PlotSimulationMenu.MenuSelectedFcn = @(s,e)obj.plot;

                % Create PlotComponentsMenu
                PlotComponentsMenu = uimenu(SimulationOptionsMenu);
                PlotComponentsMenu.Text = 'Plot Components';
                PlotComponentsMenu.MenuSelectedFcn = @(s,e)obj.plotComponents;

                % Create PlotSpectrumMenu
                PlotSpectrumMenu = uimenu(SimulationOptionsMenu);
                PlotSpectrumMenu.Text = 'Plot Spectrum';
                PlotSpectrumMenu.MenuSelectedFcn = @(s,e)obj.plotSpect;

                % Create SetActiveComponentsMenu
                SetActiveComponentsMenu = uimenu(SimulationOptionsMenu);
                SetActiveComponentsMenu.Text = 'Set Active Components...';
                SetActiveComponentsMenu.MenuSelectedFcn = @(s,e)obj.setActive;

                % Create ResimulateMenu
                ResimulateMenu = uimenu(SimulationOptionsMenu);
                ResimulateMenu.Text = 'Resimulate';

                function simcb(~,~,obj)
                    varargin
                    h = msgbox('Simulating EEG...');
                    obj.sim;
                   delete(h);
                end
                ResimulateMenu.MenuSelectedFcn = {@simcb, obj};

                % Create AddComponentMenu
                AddComponentMenu = uimenu(SimulationOptionsMenu);
                AddComponentMenu.Text = 'Add Component';

                % Create AperiodicMenu
                AperiodicMenu = uimenu(AddComponentMenu);
                AperiodicMenu.Text = 'Aperiodic';


                % Create SlowWavesMenu
                SlowWavesMenu = uimenu(AddComponentMenu);
                SlowWavesMenu.Text = 'Slow Waves';

                % Create SpindlesMenu
                SpindlesMenu = uimenu(AddComponentMenu);
                SpindlesMenu.Text = 'Spindles';

                % Create LineNoiseMenu
                LineNoiseMenu = uimenu(AddComponentMenu);
                LineNoiseMenu.Text = 'Line Noise';

                % Create OscillatorMenu
                OscillatorMenu = uimenu(AddComponentMenu);
                OscillatorMenu.Text = 'Oscillator';

                % Create ArtifactsMenu
                ArtifactsMenu = uimenu(AddComponentMenu);
                ArtifactsMenu.Text = 'Artifacts';

                % Create RemoveComponentMenu
                RemoveComponentMenu = uimenu(SimulationOptionsMenu);
                RemoveComponentMenu.Text = 'Remove Component';
                RemoveComponentMenu.MenuSelectedFcn = {@(s,e)removeComponent(obj, TabGroup)};

                AperiodicMenu.MenuSelectedFcn = {@(s,e)GUIaddAperiodic(obj, TabGroup)};
                SlowWavesMenu.MenuSelectedFcn = {@(s,e)GUIaddSlowWaves(obj, TabGroup)};
                ArtifactsMenu.MenuSelectedFcn = {@(s,e)GUIaddArtifacts(obj, TabGroup)};
                SpindlesMenu.MenuSelectedFcn = {@(s,e)GUIaddSpindles(obj, TabGroup)};
                OscillatorMenu.MenuSelectedFcn = {@(s,e)GUIaddOscillator(obj, TabGroup)};
                LineNoiseMenu.MenuSelectedFcn = {@(s,e)GUIaddLineNoise(obj, TabGroup)};
            end

            function [Artifacts_AmpMeanEditField, Artifacts_AmpSDEditField, Artifacts_AmpMinEditField, Artifacts_RateEditField] = createArtifactsTab(TabGroup, obj)
                ArtifactsTab = uitab(TabGroup);
                ArtifactsTab.Title = 'Artifacts';

                % Create AmpMeanEditFieldLabel
                Artifacts_AmpMeanEditFieldLabel = uilabel(ArtifactsTab);
                Artifacts_AmpMeanEditFieldLabel.HorizontalAlignment = 'right';
                Artifacts_AmpMeanEditFieldLabel.Position = [15 345 67 22];
                Artifacts_AmpMeanEditFieldLabel.Text = 'Amp. Mean';

                % Create Artifacts_AmpMeanEditField
                Artifacts_AmpMeanEditField = uieditfield(ArtifactsTab, 'numeric');
                Artifacts_AmpMeanEditField.Position = [123 345 103 22];

                % Create AmpSDEditFieldLabel
                Artifacts_AmpSDEditFieldLabel = uilabel(ArtifactsTab);
                Artifacts_AmpSDEditFieldLabel.HorizontalAlignment = 'right';
                Artifacts_AmpSDEditFieldLabel.Position = [29 313 53 22];
                Artifacts_AmpSDEditFieldLabel.Text = 'Amp. SD';

                % Create Artifacts_AmpSDEditField
                Artifacts_AmpSDEditField = uieditfield(ArtifactsTab, 'numeric');
                Artifacts_AmpSDEditField.Position = [123 313 103 22];

                % Create AmpMinEditFieldLabel
                Artifacts_AmpMinEditFieldLabel = uilabel(ArtifactsTab);
                Artifacts_AmpMinEditFieldLabel.HorizontalAlignment = 'right';
                Artifacts_AmpMinEditFieldLabel.Position = [25 278 57 22];
                Artifacts_AmpMinEditFieldLabel.Text = 'Amp. Min';

                % Create Artifacts_AmpMinEditField
                Artifacts_AmpMinEditField = uieditfield(ArtifactsTab, 'numeric');
                Artifacts_AmpMinEditField.Position = [123 278 103 22];

                % Create RateEditFieldLabel
                Artifacts_RateEditFieldLabel = uilabel(ArtifactsTab);
                Artifacts_RateEditFieldLabel.HorizontalAlignment = 'right';
                Artifacts_RateEditFieldLabel.Position = [18 377 64 22];
                Artifacts_RateEditFieldLabel.Text = 'Rate';

                % Create Artifacts_RateEditField
                Artifacts_RateEditField = uieditfield(ArtifactsTab, 'numeric');
                Artifacts_RateEditField.Position = [123 377 103 22];

                fillArtifacts(Artifacts_AmpMeanEditField, Artifacts_AmpSDEditField, Artifacts_AmpMinEditField, Artifacts_RateEditField, obj);

                artCallback =  {@updateArtifacts, obj, Artifacts_RateEditField, Artifacts_AmpMeanEditField, Artifacts_AmpSDEditField, Artifacts_AmpMinEditField};

                Artifacts_RateEditField.ValueChangedFcn = artCallback;
                Artifacts_AmpMeanEditField.ValueChangedFcn = artCallback;
                Artifacts_AmpSDEditField.ValueChangedFcn = artCallback;
                Artifacts_AmpMinEditField.ValueChangedFcn = artCallback;
            end

            function [LineNoiseTab, LineNoise_UIAxes, LineNoise_FreqEditField, LineNoise_AmpEditField, ...
                    LineNoise_WaveformDropDown] = createLineNoiseTab(TabGroup, obj, ln_num)

                LineNoiseTab = uitab(TabGroup);

                % Create UIAxes
                LineNoise_UIAxes = uiaxes(LineNoiseTab);
                title(LineNoise_UIAxes, 'Line Noise')
                xlabel(LineNoise_UIAxes, 'Time (s)')
                ylabel(LineNoise_UIAxes, 'Amplitude')
                LineNoise_UIAxes.Position = [29 10 917 268];

                % Create AmpMeanEditFieldLabel
                LineNoise_FreqEditFieldLabel = uilabel(LineNoiseTab);
                LineNoise_FreqEditFieldLabel.HorizontalAlignment = 'right';
                LineNoise_FreqEditFieldLabel.Position = [21 345 61 22];
                LineNoise_FreqEditFieldLabel.Text = 'Freq.';

                % Create LineNoise_AmpMeanEditField
                LineNoise_FreqEditField = uieditfield(LineNoiseTab, 'numeric');
                LineNoise_FreqEditField.Position = [123 345 103 22];

                % Create AmpSDEditFieldLabel
                LineNoise_AmpEditFieldLabel = uilabel(LineNoiseTab);
                LineNoise_AmpEditFieldLabel.HorizontalAlignment = 'right';
                LineNoise_AmpEditFieldLabel.Position = [29 313 53 22];
                LineNoise_AmpEditFieldLabel.Text = 'Amp.';

                % Create LineNoise_AmpSDEditField
                LineNoise_AmpEditField = uieditfield(LineNoiseTab, 'numeric');
                LineNoise_AmpEditField.Position = [123 313 103 22];

                % Create WaveformDropDownLabel
                LineNoise_WaveformDropDownLabel = uilabel(LineNoiseTab);
                LineNoise_WaveformDropDownLabel.HorizontalAlignment = 'right';
                LineNoise_WaveformDropDownLabel.Position = [23 377 59 22];
                LineNoise_WaveformDropDownLabel.Text = 'Waveform';

                % Create LineNoise_WaveformDropDown
                LineNoise_WaveformDropDown = uidropdown(LineNoiseTab);
                LineNoise_WaveformDropDown.Items = {'sin', 'sawtooth', 'square'};
                LineNoise_WaveformDropDown.Position = [123 377 103 22];
                LineNoise_WaveformDropDown.Value = 'sin';

                [LineNoise_FreqEditField, LineNoise_AmpEditField, LineNoise_WaveformDropDown] = fillLineNoise(LineNoise_FreqEditField, ln_num, LineNoise_AmpEditField, LineNoise_WaveformDropDown, obj);

                linenoiseCallback = {@updateLineNoise, obj, ln_num, LineNoiseTab, LineNoise_FreqEditField, LineNoise_AmpEditField, LineNoise_WaveformDropDown, LineNoise_UIAxes};

                LineNoise_FreqEditField.ValueChangedFcn = linenoiseCallback;
                LineNoise_AmpEditField.ValueChangedFcn = linenoiseCallback;
                LineNoise_WaveformDropDown.ValueChangedFcn = linenoiseCallback;

                updateLineNoise([],[],obj, ln_num, LineNoiseTab, LineNoise_FreqEditField, LineNoise_AmpEditField, LineNoise_WaveformDropDown, LineNoise_UIAxes);
            end

            function [OscillatorTab, Oscillator_UIAxes, Oscillator_FreqEditField, Oscillator_StateNoiseEditField, ...
                    Oscillator_ObsNoiseEditField, Oscillator_DampingFactorEditField, Oscillator_AmpMultEditField] = createOscillatorTab(TabGroup, obj, osc_num)

                OscillatorTab = uitab(TabGroup);
                shift = -32;
                % Create UIAxes
                Oscillator_UIAxes = uiaxes(OscillatorTab);
                title(Oscillator_UIAxes, 'Oscillator')
                xlabel(Oscillator_UIAxes, 'Time (s)')
                ylabel(Oscillator_UIAxes, 'Amplitude')
                Oscillator_UIAxes.Position = [29 10 917 268];

                % Create AmpMeanEditFieldLabel
                Oscillator_FreqEditFieldLabel = uilabel(OscillatorTab);
                Oscillator_FreqEditFieldLabel.HorizontalAlignment = 'right';
                Oscillator_FreqEditFieldLabel.Position = [21 377-shift 61 22];
                Oscillator_FreqEditFieldLabel.Text = 'Freq.';

                % Create Oscillator_AmpMeanEditField
                Oscillator_FreqEditField = uieditfield(OscillatorTab, 'numeric');
                Oscillator_FreqEditField.Position = [123 377-shift  103 22];

                % Create StateNoiseEditFieldLabel
                Oscillator_StateNoiseEditFieldLabel = uilabel(OscillatorTab);
                Oscillator_StateNoiseEditFieldLabel.HorizontalAlignment = 'right';
                Oscillator_StateNoiseEditFieldLabel.Position = [29 345-shift  53 22];
                Oscillator_StateNoiseEditFieldLabel.Text = 'State Noise';

                % Create StateNoiseEditFieldLabel
                Oscillator_StateNoiseEditField = uieditfield(OscillatorTab, 'numeric');
                Oscillator_StateNoiseEditField.Position = [123 345-shift  103 22];

                % Create Oscillator_ObsNoiseEditField
                Oscillator_ObsNoiseEditFieldLabel = uilabel(OscillatorTab);
                Oscillator_ObsNoiseEditFieldLabel.HorizontalAlignment = 'right';
                Oscillator_ObsNoiseEditFieldLabel.Position = [23 313-shift  59 22];
                Oscillator_ObsNoiseEditFieldLabel.Text = 'Obs. Noise';

                % Create Oscillator_ObsNoiseEditField
                Oscillator_ObsNoiseEditField = uieditfield(OscillatorTab, 'numeric');
                Oscillator_ObsNoiseEditField.Position = [123 313-shift  103 22];

                % Create Oscillator_DampingFactorEditFieldLabel
                Oscillator_DampingFactorEditFieldLabel = uilabel(OscillatorTab);
                Oscillator_DampingFactorEditFieldLabel.HorizontalAlignment = 'right';
                Oscillator_DampingFactorEditFieldLabel.Position = [23 281-shift  59 22];
                Oscillator_DampingFactorEditFieldLabel.Text = 'DampingFactor';

                % Create Oscillator_DampingFactorEditField
                Oscillator_DampingFactorEditField = uieditfield(OscillatorTab, 'numeric');
                Oscillator_DampingFactorEditField.Position = [123 281-shift  103 22];

                % Create Oscillator_MEditFieldLabel
                Oscillator_AmpMultEditFieldLabel = uilabel(OscillatorTab);
                Oscillator_AmpMultEditFieldLabel.HorizontalAlignment = 'right';
                Oscillator_AmpMultEditFieldLabel.Position = [23 249-shift  59 22];
                Oscillator_AmpMultEditFieldLabel.Text = 'Amp. Mult.';

                % Create Oscillator_MEditField
                Oscillator_AmpMultEditField = uieditfield(OscillatorTab, 'numeric');
                Oscillator_AmpMultEditField.Position = [123 249-shift  103 22];


                [Oscillator_FreqEditField, Oscillator_StateNoiseEditField, Oscillator_ObsNoiseEditField, Oscillator_DampingFactorEditField, Oscillator_AmpMultEditField] = fillOscillator(Oscillator_FreqEditField, osc_num, Oscillator_StateNoiseEditField, Oscillator_ObsNoiseEditField, Oscillator_DampingFactorEditField, Oscillator_AmpMultEditField, obj);

                OscillatorCallback = {@updateOscillator, obj, osc_num, OscillatorTab, Oscillator_FreqEditField, Oscillator_StateNoiseEditField, Oscillator_ObsNoiseEditField, Oscillator_DampingFactorEditField, Oscillator_AmpMultEditField, Oscillator_UIAxes};

                Oscillator_FreqEditField.ValueChangedFcn = OscillatorCallback;
                Oscillator_StateNoiseEditField.ValueChangedFcn = OscillatorCallback;
                Oscillator_ObsNoiseEditField.ValueChangedFcn = OscillatorCallback;
                Oscillator_DampingFactorEditField.ValueChangedFcn = OscillatorCallback;
                Oscillator_AmpMultEditField.ValueChangedFcn =  OscillatorCallback;

                updateOscillator([], [], obj, osc_num, OscillatorTab, Oscillator_FreqEditField, Oscillator_StateNoiseEditField, Oscillator_ObsNoiseEditField, Oscillator_DampingFactorEditField, Oscillator_AmpMultEditField, Oscillator_UIAxes);

            end

            function GUIaddAperiodic(obj, TabGroup)
                if isempty(obj.Aperiodic)
                    obj.addAperiodic;
                    createAperiodicTab(TabGroup, obj);
                else
                    msgbox('Only one aperiodic component currently allowed');
                end
            end

            function GUIaddSlowWaves(obj, TabGroup)
                if isempty(obj.Slow_Waves)
                    obj.addSlowWaves;
                    createSlowWavesTab(TabGroup, obj);
                else
                    msgbox('Only one Slow Wave component currently allowed');
                end
            end

            function GUIaddArtifacts(obj, TabGroup)
                if isempty(obj.Artifacts)
                    obj.addArtifacts;
                    createArtifactsTab(TabGroup, obj);
                else
                    msgbox('Only one Motion Artifact component currently allowed');
                end
            end

            function GUIaddSpindles(obj, TabGroup)
                obj.addSpindles;
                createSpindlesTab(TabGroup, obj, length(obj.SpindleSets));
            end

            function GUIaddOscillator(obj, TabGroup)
                obj.addOscillator;
                createOscillatorTab(TabGroup, obj,length(obj.OscillatorSets));
            end

            function GUIaddLineNoise(obj, TabGroup)
                obj.addLineNoise;
                createLineNoiseTab(TabGroup, obj, length(obj.LineNoiseSets));
            end

            function [Aperiodic_AlphaEditField, Aperiodic_MagnitudeEditField] = fillAperiodic(Aperiodic_AlphaEditField, Aperiodic_MagnitudeEditField, Aperiodic_UIAxes, obj)
                Aperiodic_AlphaEditField.Value = obj.Aperiodic.Alpha;
                Aperiodic_MagnitudeEditField.Value = obj.Aperiodic.Magnitude;
                f = linspace(0,60);
                p = Aperiodic_MagnitudeEditField.Value./(f.^Aperiodic_AlphaEditField.Value);
                plot(Aperiodic_UIAxes,f,pow2db(p),'linewidth',2)
            end

            function [Artifacts_AmpMeanEditField, Artifacts_AmpSDEditField, Artifacts_AmpMinEditField, Artifacts_RateEditField] = fillArtifacts(Artifacts_AmpMeanEditField, Artifacts_AmpSDEditField, Artifacts_AmpMinEditField, Artifacts_RateEditField, obj)
                Artifacts_AmpMeanEditField.Value = obj.Artifacts.Amp_mean;
                Artifacts_AmpSDEditField.Value = obj.Artifacts.Amp_sd;
                Artifacts_AmpMinEditField.Value = obj.Artifacts.Amp_min;
                Artifacts_RateEditField.Value = obj.Artifacts.Rate;
            end

            function [SlowWaves_RateEditField, SlowWaves_AmpMeanEditField, SlowWaves_AmpSDEditField, SlowWaves_DurMeanEditField, SlowWaves_DurSDEditField] = fillSlowWaves(SlowWaves_RateEditField, SlowWaves_AmpMeanEditField, SlowWaves_AmpSDEditField, SlowWaves_DurMeanEditField, SlowWaves_DurSDEditField, obj)
                SlowWaves_RateEditField.Value = obj.Slow_Waves.Rate;
                SlowWaves_AmpMeanEditField.Value = obj.Slow_Waves.Amp_mean;
                SlowWaves_AmpSDEditField.Value = obj.Slow_Waves.Amp_sd;
                SlowWaves_DurMeanEditField.Value = obj.Slow_Waves.Dur_mean;
                SlowWaves_DurSDEditField.Value = obj.Slow_Waves.Dur_sd;
            end

            function [Spindles_FreqSDEditField, Spindles_AmpMeanEditField, Spindles_AmpSDEditField, Spindles_FreqMeanEditField, Spindles_DurMeanEditField, Spindles_DurSDEditField, Spindles_BaselineRateEditField, Spindles_StartTimeEditField, Spindles_ModulationFactEditField, Spindles_PhasePrefEditField, Spindles_MaxTimeEditField, Spindles_TensionEditField, Spindles_ControlPointsEditField, Spindles_SplineValueEditField, Spindles_AmpMinEditField, Spindles_DurMinEditField] = fillSpindles(Spindles_FreqSDEditField, ss, Spindles_AmpMeanEditField, Spindles_AmpSDEditField, Spindles_FreqMeanEditField, Spindles_DurMeanEditField, Spindles_DurSDEditField, Spindles_BaselineRateEditField, Spindles_StartTimeEditField, Spindles_ModulationFactEditField, Spindles_PhasePrefEditField, Spindles_MaxTimeEditField, Spindles_TensionEditField, Spindles_ControlPointsEditField, Spindles_SplineValueEditField, Spindles_AmpMinEditField, Spindles_DurMinEditField, obj)

                Spindles_FreqSDEditField.Value = obj.SpindleSets(ss).Freq_sd;
                Spindles_AmpMeanEditField.Value = obj.SpindleSets(ss).Amp_mean;
                Spindles_AmpSDEditField.Value = obj.SpindleSets(ss).Amp_sd;
                Spindles_FreqMeanEditField.Value = obj.SpindleSets(ss).Freq_mean;
                Spindles_DurMeanEditField.Value = obj.SpindleSets(ss).Dur_mean;
                Spindles_DurSDEditField.Value = obj.SpindleSets(ss).Dur_sd;
                Spindles_BaselineRateEditField.Value = obj.SpindleSets(ss).Baseline_rate;
                Spindles_StartTimeEditField.Value = obj.SpindleSets(ss).Start_time;
                Spindles_ModulationFactEditField.Value = obj.SpindleSets(ss).Modulation_factor;
                Spindles_PhasePrefEditField.Value = value2str(obj.SpindleSets(ss).Phase_pref);
                Spindles_MaxTimeEditField.Value = obj.SpindleSets(ss).Spline_tmax;
                Spindles_TensionEditField.Value = obj.SpindleSets(ss).Tension;
                Spindles_ControlPointsEditField.Value = value2str(obj.SpindleSets(ss).Ctrl_pts);
                Spindles_SplineValueEditField.Value = value2str(obj.SpindleSets(ss).Theta_spline);
                Spindles_AmpMinEditField.Value = obj.SpindleSets(ss).Amp_min;
                Spindles_DurMinEditField.Value = obj.SpindleSets(ss).Dur_min;
            end

            function [LineNoise_FreqEditField, LineNoise_AmpEditField, LineNoise_WaveformDropDown] = fillLineNoise(LineNoise_FreqEditField, ln_num, LineNoise_AmpEditField, LineNoise_WaveformDropDown, obj)
                LineNoise_FreqEditField.Value = obj.LineNoiseSets(ln_num).Freq;
                LineNoise_AmpEditField.Value = obj.LineNoiseSets(ln_num).Amp;
                LineNoise_WaveformDropDown.Value = obj.LineNoiseSets(ln_num).Waveform;
            end

            function [Oscillator_FreqEditField, Oscillator_StateNoiseEditField, Oscillator_ObsNoiseEditField, Oscillator_DampingFactorEditField, Oscillator_AmpMultEditField] = fillOscillator(Oscillator_FreqEditField, oo, Oscillator_StateNoiseEditField, Oscillator_ObsNoiseEditField, Oscillator_DampingFactorEditField, Oscillator_AmpMultEditField, obj)
                Oscillator_FreqEditField.Value = obj.OscillatorSets(oo).Freq;
                Oscillator_StateNoiseEditField.Value = obj.OscillatorSets(oo).StateNoise;
                Oscillator_ObsNoiseEditField.Value = obj.OscillatorSets(oo).ObsNoise;
                Oscillator_DampingFactorEditField.Value = obj.OscillatorSets(oo).DampingFactor;
                Oscillator_AmpMultEditField.Value = obj.OscillatorSets(oo).AmpMult;
            end

            function removeComponent(obj, TabGroup)
                c_titles = get(TabGroup.Children, 'title');
                % Create a UI figure
                fig = uifigure('Name', 'Delete Component','units','normalized', 'Position', [0.4186    0.4333    0.0872    0.3736]);
                fig.Units = "pixels";
                fig.Position(3:4) = [300 600];

                % Create a list box with the options from the component_titles array
                listbox = uilistbox(fig, 'Items', c_titles, 'Position', [50    90   200   439]);

                % Create a button to delete the selected component
                deleteButton = uibutton(fig, 'push', 'Text', 'Delete Component', ...
                    'Position', [80 40 150 30], ...
                    'ButtonPushedFcn', @(src, event) deleteComponent(listbox, TabGroup, obj));

                % Function to handle deletion of the selected component
                function deleteComponent(listbox, TabGroup, obj)
                    % Get the selected value from the list box
                    selectedValue = listbox.Value;
                    selectedIdx = listbox.ValueIndex;

                    % Confirm deletion
                    choice = uiconfirm(fig, ...
                        ['Are you sure you want to delete "' selectedValue '"?'], ...
                        'Confirm Deletion', ...
                        'Options', {'Yes', 'Cancel'}, ...
                        'DefaultOption', 2, ...
                        'Icon', 'warning');

                    % If the user confirms deletion, remove the selected item
                    if strcmp(choice, 'Yes')


                        if contains(selectedValue,'Aperiodic','IgnoreCase',true)
                            obj.Aperiodic = [];
                        end

                        if contains(selectedValue,'Slow Waves','IgnoreCase',true)
                            obj.Slow_Waves = [];
                        end

                        if contains(selectedValue,'Artifacts','IgnoreCase',true)
                            obj.Artifacts = [];
                        end

                        if contains(selectedValue,'Spindles','IgnoreCase',true)
                            sp_inds = contains(listbox.Items,'Spindles');
                            sp_idx = cumsum(sp_inds(1:selectedIdx));

                            obj.SpindleSets = obj.SpindleSets(setdiff(1:length(obj.SpindleSets),sp_idx));

                        end

                        delete(TabGroup.Children(selectedIdx));
                        c_titles = get(TabGroup.Children, 'title');

                        %Make into a cell if there is only one component left
                        if length(TabGroup.Children) == 1 %#ok<ISCL>
                            c_titles = {c_titles};
                        end
                        if ~isempty(c_titles)
                            listbox.Items = c_titles;
                        else
                            listbox.Items = [];
                        end

                    end
                end
            end
        end
    end

    methods (Access = private)
        function makeSelectTree(obj)
            %MAKESELECTTREE Creates a checkbox tree for selecting active
            %properties
            %
            %   This method does interactive isActive toggling
            %
            %   Inputs:
            %       obj: SleepEEGSim object - instance of the SleepEEGSim class
            %

            %Set up Ui Figure
            if isempty(obj.setactive_fig) | ~ishandle(obj.setactive_fig)
                obj.setactive_fig = uifigure('Units','normalized','Position', [0.8   0.6    0.1000    0.5000]);
                obj.setactive_fig.Units = "pixels";
                obj.setactive_fig.Name = 'Select Components';
                obj.setactive_fig.Position(3:4) = [350 450];
            end

            %Set up checkbox tree
            cbtree = uitree(obj.setactive_fig,'checkbox');
            cbtree.Position = [25 80 obj.setactive_fig.Position(3)-50 obj.setactive_fig.Position(4) - 100];
            cbtree.FontSize = 18;
            cbtree.CheckedNodesChangedFcn = @obj.updateCheckboxActive;

            btn = uibutton(obj.setactive_fig,'Position', [350/2-50 10 100 50],'Text','Plot',"ButtonPushedFcn",@(src, event)obj.plot);

            %Get component names
            names = obj.componentNames;

            %Populate tree and name nodes with component names
            cc = 1;
            if ~isempty(obj.Aperiodic)
                n = uitreenode(cbtree,"Text",names{1},"NodeData",cc);
                if obj.Aperiodic.isActive
                    checked_nodes(cc) = n;
                    cc = cc+1;
                end
            end

            if ~isempty(obj.Slow_Waves)
                n = uitreenode(cbtree,"Text",names{2},"NodeData",cc);
                if obj.Slow_Waves.isActive
                    checked_nodes(cc) = n;
                    cc = cc+1;
                end
            end

            if ~isempty(obj.OscillatorSets)
                bb_check = uitreenode(cbtree,"Text",'EEG Bands',"NodeData",[]);
                for ii = 1:length(obj.OscillatorSets)
                    osc = obj.OscillatorSets(ii);
                    n = uitreenode(bb_check,"Text",names{2+ii},"NodeData",cc);
                    if osc.isActive
                        checked_nodes(cc) = n;
                        cc = cc+1;
                    end
                end
            end

            if ~isempty(obj.SpindleSets)
                sp_check = uitreenode(cbtree,"Text",'Spindles',"NodeData",[]);
                for ii = 1:length(obj.SpindleSets)
                    spindle = obj.SpindleSets(ii);
                    n = uitreenode(sp_check,"Text",names{2 + length(obj.OscillatorSets) + ii},"NodeData",cc);
                    if spindle.isActive
                        checked_nodes(cc) = n;
                        cc = cc+1;
                    end
                end
            end

            if ~isempty(obj.LineNoiseSets)
                ln_check = uitreenode(cbtree,"Text",'Line Noise',"NodeData",[]);
                for ii = 1:length(obj.LineNoiseSets)
                    ln = obj.LineNoiseSets(ii);
                    n = uitreenode(ln_check,"Text",names{2 + length(obj.OscillatorSets) + length(obj.SpindleSets) + ii},"NodeData",cc);
                    if ln.isActive
                        checked_nodes(cc) = n;
                        cc = cc+1;
                    end
                end
            end

            if ~isempty(obj.Artifacts)
                n = uitreenode(cbtree,"Text",names{2 + length(obj.OscillatorSets) + length(obj.SpindleSets) + length(obj.LineNoiseSets) + 1},"NodeData",cc);
                if obj.Artifacts.isActive
                    checked_nodes(cc) = n;
                end
            end

            %Set the active nodes to be checked
            cbtree.CheckedNodes = checked_nodes;

            %Expand the tree
            expand(cbtree);
        end

        function updateCheckboxActive(obj,cbtree,~)
            %Callback for checkbox tree
            names = obj.componentNames;
            %Set active nodes to checked nodes
            obj.setActive(ismember(names,{cbtree.CheckedNodes.Text}));
        end

        function [SO_phase, SO_EEG] = computeSOPhase(obj, baseline_signal)
            %COMPUTESOPHASE Compute the Slow Oscillation (SO) phase and signal
            %
            %   This method computes the Slow Oscillation (SO) phase and SO-filtered
            %   EEG signal from a given baseline signal. It applies a bandpass filter
            %   to isolate the SO frequency range and then extracts the phase using
            %   the Hilbert transform.
            %
            %   Inputs:
            %       baseline_signal: Vector - the signal from which SO phase and signal
            %           will be computed.
            %
            %   Outputs:
            %       SO_phase: Vector - the phase of the Slow Oscillation component.
            %       SO_EEG: Vector - the SO-filtered EEG signal.
            %
            %   Example:
            %       [SO_phase, SO_EEG] = obj.computeSOPhase(baseline_signal);
            %
            %   Note:
            %       The method uses a bandpass filter with a frequency range of 0.3 to
            %       1.5 Hz to isolate the SO component.

            % Compute SO band filter
            SO_freqrange = [.3 1.5];
            d = designfilt('bandpassiir', ...       % Response type
                'StopbandFrequency1', SO_freqrange(1) - 0.1, ...    % Frequency constraints
                'PassbandFrequency1', SO_freqrange(1), ...
                'PassbandFrequency2', SO_freqrange(2), ...
                'StopbandFrequency2', SO_freqrange(2) + 0.1, ...
                'StopbandAttenuation1', 60, ...   % Magnitude constraints
                'PassbandRipple', 1, ...
                'StopbandAttenuation2', 60, ...
                'DesignMethod', 'ellip', ...      % Design method
                'MatchExactly', 'passband', ...   % Design method options
                'SampleRate', obj.Fs);
            %% Create baseline signal
            SO_EEG = filtfilt(d, baseline_signal);
            % Extract SO-phase
            SO_phase = angle(hilbert(SO_EEG));
        end

        function vfilt_sig = visfilt_EEG(obj)
            %VISFILT_EEG Apply visual filter to the EEG signal
            %
            %   This method applies a bandpass filter to the EEG signal to isolate
            %   the frequency range from 0.3 to 35 Hz. The filtered signal can be used
            %   for visualization or further analysis.
            %
            %   Inputs:
            %       obj: SleepEEGSim object - instance of the SleepEEGSim class
            %
            %   Outputs:
            %       vfilt_sig: Vector - the EEG signal after bandpass filtering.
            %
            %   Example:
            %       vfilt_sig = obj.visfilt_EEG();
            %
            %   Note:
            %       The method uses a bandpass filter with a frequency range of 0.3 to
            %       35 Hz for visualizing the EEG signal.

            % Compute SO band filter
            SO_freqrange = [.3 35];
            d = designfilt('bandpassiir', ...       % Response type
                'StopbandFrequency1', SO_freqrange(1) - 0.1, ...    % Frequency constraints
                'PassbandFrequency1', SO_freqrange(1), ...
                'PassbandFrequency2', SO_freqrange(2), ...
                'StopbandFrequency2', SO_freqrange(2) + 1, ...
                'StopbandAttenuation1', 60, ...   % Magnitude constraints
                'PassbandRipple', 1, ...
                'StopbandAttenuation2', 60, ...
                'DesignMethod', 'ellip', ...      % Design method
                'MatchExactly', 'passband', ...   % Design method options
                'SampleRate', obj.Fs);
            %% Create baseline signal
            vfilt_sig = filtfilt(d, obj.Signal);
        end
    end

    methods (Static)
        function [t_sp, b, yhat, dylo, dyhi] = fit_ppsplines(t, SO_phase, spindle_sets)
            %FIT_PPSPLINES Fit splines using a point process model for spindles
            %
            %   This method fits splines to the phase of Slow Oscillation (SO) using
            %   a point process model for spindle data. The splines are constructed
            %   using control points and tension parameters to model spindle modulations.
            %
            %   Inputs:
            %       t: Vector - time points for the analysis.
            %       SO_phase: Vector - phase of the Slow Oscillation at the time points.
            %       spindle_sets: Array of SpindleSets objects - each containing spindle
            %           times, phases, control points, and tension parameters.
            %
            %   Outputs:
            %       t_sp: Cell array - time points for each spindle set used for spline fitting.
            %       b: Cell array - regression coefficients for each spindle set.
            %       yhat: Cell array - predicted values from the spline fit for each spindle set.
            %       dylo: Cell array - lower confidence bounds for the predicted values.
            %       dyhi: Cell array - upper confidence bounds for the predicted values.
            %
            %   Example:
            %       [t_sp, b, yhat, dylo, dyhi] = fit_ppsplines(t, SO_phase, spindle_sets);
            %
            %   Note:
            %       The method constructs splines using cubic spline interpolation and
            %       fits a Poisson regression model to the spindles' occurrences.
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
