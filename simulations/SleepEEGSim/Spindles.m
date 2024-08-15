classdef Spindles < handle
    %SPINDLES  Class containing options for simulating N2 EEG spindles.
    %
    %   Usage:
    %       opts = Spindles('PropertyName', PropertyValue, ...)
    %
    %   Properties (default values in parentheses):
    %       Freq_mean: double - Mean frequency of the spindle, in Hz. (Default: 15)
    %       Freq_sd: double - Standard deviation of the frequency, in Hz. (Default: 0.125)
    %       Amp_mean: double - Mean amplitude of the spindle, in microvolts. (Default: 8)
    %       Amp_sd: double - Standard deviation of the amplitude, in microvolts. (Default: 0.5)
    %       Dur_mean: double - Mean duration of the spindle, in seconds. (Default: 1.5)
    %       Dur_sd: double - Standard deviation of the duration, in seconds. (Default: 0.25)
    %       Baseline_rate: double - Baseline rate of spindles, in Hz. (Default: 5/60)
    %       Start_time: double - Starting time of spindles in seconds for detection baseline purposes. (Default: 0)
    %       Phase_pref: double - Preferred phase angle of the spindle, in radians. (Default: 0)
    %       Modulation_factor: double - Modulation factor for cosine tuning. (Default: 0.6)
    %       Ctrl_pts: double vector - Control points for spline fitting. (Default: [-3, 0, 3, 5, 8, 9, 12, 15, 18, 45, 50, 55, 65, 85])
    %       Theta_spline: double vector - Theta values for spline fitting. (Default: log([1e-5, 1e-2, 1, 2, 1, 1, 1, 1, 1, 1, 1.5, 1, 1, 1]))
    %       Spline_tmax: double - Maximum time for spline fitting, in seconds. (Default: 60)
    %       Tension: double - Tension parameter for spline fitting. (Default: 1)
    %       Fs_sp: double - Downsampling rate for spline fitting. (Default: 50)
    %       Times: double vector - Times of detected spindles. (Populated after simulation)
    %       Freqs: double vector - Frequencies of detected spindles. (Populated after simulation)
    %       Amps: double vector - Amplitudes of detected spindles. (Populated after simulation)
    %       Durations: double vector - Durations of detected spindles. (Populated after simulation)
    %       Phase: double vector - Phase of the slow oscillation at the time of spindle occurrence. (Populated after simulation)
    %       S: double matrix - Spline matrix used in the simulation. (Populated after simulation)
    %       t_spline: double vector - Time points for spline fitting. (Populated after simulation)
    %       Signal: double vector - Simulated spindle signal. (Populated after simulation)
    %
    %   Example:
    %       % Create a Spindles object with default parameters
    %       spindles = Spindles();
    %
    %       % Customize specific parameters
    %       spindles = Spindles('Freq_mean', 13, 'Amp_mean', 10);
    %
    %   Copyright 2024 Prerau Laboratory. - http://www.sleepEEG.org
    % *********************************************************************

    properties
        Freq_mean double {mustBePositive, mustBeReal, mustBeNumeric, mustBeNonempty} = 15
        Freq_sd double {mustBePositive, mustBeReal, mustBeNumeric, mustBeNonempty} = 0.2
        Amp_mean double {mustBePositive, mustBeReal, mustBeNumeric, mustBeNonempty} = 15
        Amp_min double {mustBePositive, mustBeReal, mustBeNumeric, mustBeNonempty} = 5
        Amp_sd double {mustBePositive, mustBeReal, mustBeNumeric, mustBeNonempty} = 0.125
        Dur_mean double {mustBePositive, mustBeReal, mustBeNumeric, mustBeNonempty} = 1.5
        Dur_sd double {mustBePositive, mustBeReal, mustBeNumeric, mustBeNonempty} = 0.25
        Dur_min double {mustBePositive, mustBeReal, mustBeNumeric, mustBeNonempty} = 0.5
        Baseline_rate double {mustBePositive, mustBeReal, mustBeNumeric, mustBeNonempty} = 5/60
        Start_time double {mustBeNonnegative, mustBeReal, mustBeNumeric, mustBeNonempty} = 0
        Phase_pref double {mustBeReal, mustBeNumeric, mustBeNonempty} = 0
        Modulation_factor double {mustBePositive, mustBeReal, mustBeNumeric, mustBeNonempty} = 0.6
        Ctrl_pts double {mustBeReal, mustBeNumeric, mustBeNonempty, mustBeVector} =         [    -3,     0, 3, 5, 8, 9, 12, 15, 18  45,  50, 55, 65, 85]
        Theta_spline double {mustBeReal, mustBeNumeric, mustBeNonempty, mustBeVector} = log([  1e-5,  1e-2, 1, 2, 1, 1,  1,  1,  1,  1, 1.5, 1,  1,  1])
        Spline_tmax double {mustBePositive, mustBeReal, mustBeNumeric, mustBeNonempty} = 60
        Tension double {mustBePositive, mustBeReal, mustBeNumeric, mustBeNonempty} = 1
        Fs_sp double {mustBePositive, mustBeReal, mustBeNumeric, mustBeNonempty} = 50

        Times = [];
        Freqs = [];
        Amps  = [];
        Durations = [];
        Phase = [];
        S = [];
        t_spline = [];

        Signal = [];

        isActive = true;
    end

    methods
        function obj = Spindles(varargin)
            %SPINDLES Construct an instance of the Spindles class
            %
            %   This constructor initializes the Spindles object with specified or default
            %   properties related to spindle generation. These properties include the frequency
            %   and amplitude characteristics, duration, baseline rate, and more.
            %
            %   Inputs:
            %       varargin: Name-value pairs for setting the class properties
            %           - Freq_mean: Mean frequency of spindles (Hz)
            %           - Freq_sd: Standard deviation of spindle frequency (Hz)
            %           - Amp_mean: Mean amplitude of spindles (µV)
            %           - Amp_sd: Standard deviation of spindle amplitude (µV)
            %           - Amp_min: Minimum amplitude threshold (µV)
            %           - Dur_mean: Mean duration of spindles (s)
            %           - Dur_sd: Standard deviation of spindle duration (s)
            %           - Dur_min: Minimum duration threshold (s)
            %           - Baseline_rate: Baseline spindle occurrence rate (Hz)
            %           - Start_time: Start time for spindle generation (s)
            %           - Phase_pref: Preferred phase for spindle generation (radians)
            %           - Modulation_factor: Modulation factor for spindle amplitude
            %           - Ctrl_pts: Control points for spindle shape generation
            %           - Theta_spline: Theta values for spline interpolation
            %           - Spline_tmax: Maximum time for spline interpolation (s)
            %           - Tension: Tension parameter for spline interpolation
            %           - Fs_sp: Sampling frequency for spindle generation (Hz)
            %
            %   Outputs:
            %       obj: Instance of the Spindles class with initialized properties.

            % Create an input parser object
            p = inputParser;

            % Define the parameters and their default values
            addOptional(p, 'Freq_mean', obj.Freq_mean, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
            addOptional(p, 'Freq_sd', obj.Freq_sd, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
            addOptional(p, 'Amp_mean', obj.Amp_mean, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
            addOptional(p, 'Amp_sd', obj.Amp_sd, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
            addOptional(p, 'Amp_min', obj.Amp_min, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
            addOptional(p, 'Dur_mean', obj.Dur_mean, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
            addOptional(p, 'Dur_sd', obj.Dur_sd, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
            addOptional(p, 'Dur_min', obj.Dur_min, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
            addOptional(p, 'Baseline_rate', obj.Baseline_rate, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
            addOptional(p, 'Start_time', obj.Start_time, @(x) validateattributes(x, {'numeric'}, {'scalar', 'nonnegative'}));
            addOptional(p, 'Phase_pref', obj.Phase_pref, @(x) validateattributes(x, {'numeric'}, {'scalar'}));
            addOptional(p, 'Modulation_factor', obj.Modulation_factor, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
            addOptional(p, 'Ctrl_pts', obj.Ctrl_pts, @(x) validateattributes(x, {'numeric'}, {'vector'}));
            addOptional(p, 'Theta_spline', obj.Theta_spline, @(x) validateattributes(x, {'numeric'}, {'vector'}));
            addOptional(p, 'Spline_tmax', obj.Spline_tmax, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
            addOptional(p, 'Tension', obj.Tension, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
            addOptional(p, 'Fs_sp', obj.Fs_sp, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));

            % Parse the inputs
            parse(p, varargin{:});

            % Assign parsed values to object properties
            obj.Freq_mean = p.Results.Freq_mean;
            obj.Freq_sd = p.Results.Freq_sd;
            obj.Amp_mean = p.Results.Amp_mean;
            obj.Amp_sd = p.Results.Amp_sd;
            obj.Amp_min = p.Results.Amp_min;
            obj.Dur_mean = p.Results.Dur_mean;
            obj.Dur_sd = p.Results.Dur_sd;
            obj.Dur_min = p.Results.Dur_min;
            obj.Baseline_rate = p.Results.Baseline_rate;
            obj.Start_time = p.Results.Start_time;
            obj.Phase_pref = p.Results.Phase_pref;
            obj.Modulation_factor = p.Results.Modulation_factor;
            obj.Ctrl_pts = p.Results.Ctrl_pts;
            obj.Theta_spline = p.Results.Theta_spline;
            obj.Spline_tmax = p.Results.Spline_tmax;
            obj.Tension = p.Results.Tension;
            obj.Fs_sp = p.Results.Fs_sp;
        end

        function spindles = sim(obj, t, SO_phase)
            %SIM Simulate spindles based on specified properties and input signals
            %
            %   This method simulates spindle waveforms based on the properties of the Spindles
            %   object, time vector, and SO (slow oscillation) phase. It uses a point process model
            %   to determine spindle occurrence times and then generates spindle waveforms which
            %   are modulated by the SO phase.
            %
            %   Inputs:
            %       obj: Spindles object - instance of the Spindles class
            %       t: 1xN vector - time vector (seconds)
            %       SO_phase: 1xN vector - phase of slow oscillations (radians)
            %
            %   Outputs:
            %       spindles: 1xN vector - simulated spindle signal
            %
            %   The method also updates the following properties of the Spindles object:
            %       - Times: Vector of spindle onset times (seconds)
            %       - Freqs: Vector of spindle frequencies (Hz)
            %       - Amps: Vector of spindle amplitudes (µV)
            %       - Durations: Vector of spindle durations (seconds)
            %       - Phase: Vector of spindle phases at onset (radians)
            %       - Signal: Simulated spindle signal (same as the output 'spindles')

            if ~isempty(obj.Freq_mean)
                Fs = 1/(t(2)-t(1));
                N = length(t);

                assert(length(t) == length(SO_phase), 'Time and phase vectors must be the same length')

                spindles = zeros(1,N);

                %Compute spindle times using point process model
                [spindle_times, ~, obj.S, obj.t_spline] = ...
                    obj.gen_ppspline_times(Fs, obj.Fs_sp, obj.Baseline_rate, SO_phase, obj.Modulation_factor, obj.Phase_pref, obj.Ctrl_pts, obj.Theta_spline, obj.Tension, obj.Spline_tmax);

                %Remove any spindles before detection start time
                spindle_times = spindle_times(spindle_times>obj.Start_time);

                N_spindles = length(spindle_times);
                spindle_durations = max(obj.Dur_mean + randn(1,N_spindles)*obj.Dur_sd, obj.Dur_min);
                spindle_amps =  max(obj.Amp_mean + randn(1,N_spindles)*obj.Amp_sd, obj.Amp_min);
                spindle_freqs = max(obj.Freq_mean + randn(1,N_spindles)*obj.Freq_sd,0);

                spindle_phase = wrapToPi(interp1(t,unwrap(SO_phase), spindle_times));

                assert(length(spindle_durations)==N_spindles,'Error: Durations must be the same size as times');
                assert(length(spindle_amps)==N_spindles,'Error: Amps must be the same size as times');
                assert(length(spindle_freqs)==N_spindles,'Error: Freqs must be the same size as times');
                assert(length(spindle_phase)==N_spindles,'Error: Phases must be the same size as times');

                %Generate spindle waveforms and place at each time
                for ii = 1:N_spindles
                    sp_t = linspace(0,spindle_durations(ii),round(spindle_durations(ii)*Fs));
                    spindle = sin(2*pi*sp_t*spindle_freqs(ii)) .* hanning(length(sp_t))'*spindle_amps(ii);
                    sp_inds = round((sp_t+spindle_times(ii)-spindle_durations(ii)/2)*Fs);

                    if all(sp_inds>1 & sp_inds<N)
                        spindles(sp_inds) = spindle;
                    end
                end

                %Add to object
                obj.Times = spindle_times;
                obj.Freqs = spindle_freqs;
                obj.Amps = spindle_amps;
                obj.Durations = spindle_durations;
                obj.Phase = spindle_phase;
                obj.Signal = spindles;


            end
        end

        function plot_spline(obj, varargin)
            %PLOT_SPLINE Plot the spline function used for spindle generation
            %
            %   This method plots the spline function that was used to generate spindle
            %   waveforms. The spline function is represented by its multipliers over time.
            %   The plot is based on the spline data and theta values stored in the Spindles
            %   object. Additional plot properties can be specified via name-value pairs.
            %
            %   Inputs:
            %       obj: Spindles object - instance of the Spindles class
            %       varargin: Name-value pairs for customizing the plot (e.g., line color, style)
            %
            %   Outputs:
            %       None - This method generates a plot and does not return any output.
            %
            %   Example:
            %       % Plot the spline function with default settings
            %       obj.plot_spline();
            %
            %       % Plot the spline function with a red dashed line
            %       obj.plot_spline('r--');

            if ~isempty(obj.S)
                plot(obj.t_spline, exp(obj.S' * obj.Theta_spline'), varargin{:})
                xlabel('Time (s)')
                ylabel('Multiplier')
            end
        end

    end

    methods (Static, Access = private)
        function [times, train, S, t_spline] = gen_ppspline_times(Fs, Fs_sp, baseline_rate, phase, coupling_mag, phase_pref, ctrl_pts, theta_spline, tension, spline_tmax)
            %GEN_PPSPLINE_TIMES Generate point process spindle times and train using phase and spline parameters
            %
            %   Usage:
            %       [times, train, S, t_spline] = pptimes(Fs, Fs_sp, baseline_rate, phase, coupling_mag, phase_pref, ctrl_pts, theta_spline, tension, spline_tmax)
            %
            %   Input:
            %       Fs: double - original sampling frequency in Hz -- required
            %       Fs_sp: double - target sampling frequency for spiking data in Hz -- required
            %       baseline_rate: double - baseline firing rate -- (default: 1.67 = 10/min)
            %       phase: <number of samples> x 1 vector - phase time series data -- required
            %       coupling_mag: double - coupling magnitude for phase model -- required
            %       phase_pref: double - preferred phase for coupling -- required
            %       ctrl_pts: 1xN vector - control points for spline fitting (default: -3:3:18)
            %       theta_spline: 1xM vector - spline parameters -- required
            %       tension: double - tension parameter for spline fitting (default: 1)
            %       spline_tmax: double - maximum time for spline fitting in seconds (default: 15)
            %
            %   Output:
            %       times: 1xT vector - times of spindle events
            %       train: <number of samples> x 1 vector - binary spindle train
            %       S: spline matrix used in the simulation
            %       t_spline: 1x<spline_tmax*Fs_sp> vector - spline times
            %
            %   Example:
            %   In this example, we generate spindle times and train using phase data and spline parameters.
            %       Fs = 1000; % Original Sampling Frequency
            %       Fs_sp = 500; % Target Sampling Frequency for Spiking Data
            %       baseline_rate = log(0.05); % Baseline firing rate
            %       phase = rand(10000, 1); % Example phase data
            %       coupling_mag = 0.5; % Coupling magnitude
            %       phase_pref = pi/2; % Preferred phase
            %       ctrl_pts = -3:3:18; % Control points
            %       theta_spline = [0, -5, 0, 0.5, 0, 0, 0, 0]; % Spline parameters
            %       tension = 1; % Tension parameter
            %       spline_tmax = 15; % Maximum time for spline fitting
            %       [times, train, S, t_spline] = gen_ppspline_times(Fs, Fs_sp, baseline_rate, phase, coupling_mag, phase_pref, ctrl_pts, theta_spline, tension, spline_tmax);
            %
            %   See also: poissrnd
            %
            %   Copyright 2024 Prerau Laboratory - http://www.sleepEEG.org
            % *********************************************************************

            % Resample phase data if necessary
            if Fs ~= Fs_sp
                [d,n]=rat(Fs/Fs_sp);
                phase=resample(phase,n,d,500);
            end

            N = length(phase);
            t = (0:N-1) / Fs_sp;

            % Convert time to bins
            spline_tmax = spline_tmax * Fs_sp;
            ctrl_pts = ctrl_pts * Fs_sp;

            % Compute phase model
            phase_lambda = coupling_mag * cos(phase - phase_pref);

            numknots = length(ctrl_pts);

            % Construct spline matrix
            S = zeros(spline_tmax, numknots);

            if any(theta_spline)
                for i = 1:spline_tmax
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
            end

            % Transpose the spline matrix to optimize for the loop
            S = S';

            % Simulate spiking activity
            train = zeros(N, 1);
            lambda = zeros(N, 1);

            for i = spline_tmax + 1:N
                % Extract the segment of the spindle train for spline fitting
                seg = train(i - 1:-1:i - spline_tmax);

                % Calculate the firing rate lambda
                lambda(i) = exp(theta_spline * (S * seg) + phase_lambda(i) + log(baseline_rate));

                % Generate the spike train
                train(i) = min(poissrnd(lambda(i) / Fs_sp), 1);
            end

            % Extract the times of the spindle events
            times = t(logical(train));

            % Define the spline times
            t_spline = (0:spline_tmax-1) / Fs_sp;
        end

    end
end
