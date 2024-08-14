classdef SlowWaves < handle
    %SLOWWAVES Class for simulating slow waves in EEG data.
    %
    %   Usage:
    %       sw = SlowWaves('PropertyName', PropertyValue, ...)
    %
    %   Properties (default values in parentheses):
    %       Rate: double - Slow wave rate in events per second. (Default: 40/60)
    %       Amp_mean: double - Mean amplitude of slow waves. (Default: 70)
    %       Amp_sd: double - Standard deviation of slow wave amplitudes. (Default: 3)
    %       Dur_mean: double - Mean duration of slow waves in seconds. (Default: 1.5)
    %       Dur_sd: double - Standard deviation of slow wave durations in seconds. (Default: 0.2)
    %       Times: double array - Array of slow wave occurrence times (populated after simulation).
    %       Amps: double array - Array of slow wave amplitudes (populated after simulation).
    %       Durations: double array - Array of slow wave durations (populated after simulation).
    %       Signal: double array - Stored simulated slow wave signal (empty if no simulation is performed).
    %
    %   Methods:
    %       sim: Simulate slow waves based on a time vector.
    %
    %   Example:
    %       % Create an instance of SlowWaves with specific parameters
    %       sw = SlowWaves('Rate', 40/60, 'Amp_mean', 80, 'Amp_sd', 5, 'Dur_mean', 1.6, 'Dur_sd', 0.25);
    %
    %       % Simulate slow waves on a time vector
    %       Fs = 1000;
    %       t = 0:(1/Fs):10; % Example time vector
    %       slow_wave_signal = sw.sim(t);
    %       plot(t, slow_wave_signal);
    %
    %   Copyright 2024 Prerau Laboratory. - http://www.sleepEEG.org
    % *********************************************************************

    properties
        Rate double {mustBeReal, mustBeNonempty} = 40/60 % Slow wave rate (events/s)
        Amp_mean double {mustBePositive, mustBeReal, mustBeNumeric, mustBeNonempty} = 10 % Mean amplitude of slow waves
        Amp_sd double {mustBePositive, mustBeReal, mustBeNumeric, mustBeNonempty} = 3 % Standard deviation of slow wave amplitudes
        Dur_mean double {mustBePositive, mustBeReal, mustBeNumeric, mustBeNonempty} = 1.5 % Mean duration of slow waves (s)
        Dur_sd double {mustBePositive, mustBeReal, mustBeNumeric, mustBeNonempty} = 0.2 % Standard deviation of slow wave durations (s)

        Times = [] % Array of slow wave occurrence times
        Amps = [] % Array of slow wave amplitudes
        Durations = [] % Array of slow wave durations
        Signal double = [] % Stored simulated slow wave signal

        isActive = true;
    end

    methods
        function obj = SlowWaves(varargin)
            %SLOWWAVES Construct an instance of this class with specified properties.
            %
            %   Usage:
            %       obj = SlowWaves('PropertyName', PropertyValue, ...)
            %
            %   Example:
            %       % Create an instance of SlowWaves with specific parameters
            %       sw = SlowWaves('Rate', 40/60, 'Amp_mean', 80, 'Amp_sd', 5, 'Dur_mean', 1.6, 'Dur_sd', 0.25);
            %
            %   See also: sim
            
            % Create an input parser object
            p = inputParser;

            % Define the parameters and their default values
            addOptional(p, 'Rate', obj.Rate, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
            addOptional(p, 'Amp_mean', obj.Amp_mean, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
            addOptional(p, 'Amp_sd', obj.Amp_sd, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
            addOptional(p, 'Dur_mean', obj.Dur_mean, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
            addOptional(p, 'Dur_sd', obj.Dur_sd, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));

            % Parse the inputs
            parse(p, varargin{:});

            % Assign parsed values to object properties
            obj.Rate = p.Results.Rate;
            obj.Amp_mean = p.Results.Amp_mean;
            obj.Amp_sd = p.Results.Amp_sd;
            obj.Dur_mean = p.Results.Dur_mean;
            obj.Dur_sd = p.Results.Dur_sd;
        end

        function slow_waves = sim(obj, t)
            %SIM Simulate slow waves based on a time vector.
            %
            %   Usage:
            %       slow_waves = sim(obj, t)
            %
            %   Input:
            %       t: double array - Time vector (e.g., [0, 0.001, 0.002, ...])
            %
            %   Output:
            %       slow_waves: double array - Simulated slow wave signal values at each time point.
            %
            %   Example:
            %       % Create an instance of SlowWaves with specific parameters
            %       sw = SlowWaves('Rate', 40/60, 'Amp_mean', 80, 'Amp_sd', 5, 'Dur_mean', 1.6, 'Dur_sd', 0.25);
            %
            %       % Simulate slow waves on a time vector
            %       Fs = 1000;
            %       t = 0:(1/Fs):10; % Example time vector
            %       slow_wave_signal = sw.sim(t);
            %       plot(t, slow_wave_signal);
            %
            %   See also: SlowWaves
            
            assert(nargin == 2, 'A time vector must be provided for simulation');

            % Total number of time points
            N = length(t);
            Fs = 1 / (t(2) - t(1)); % Sampling frequency

            % Initialize slow wave signal array
            slow_waves = zeros(1, N);

            % Generate Poisson events
            SW_times = find(poissrnd(obj.Rate / Fs, 1, N));

            SW_amps = zeros(1, length(SW_times));
            SW_durations = zeros(1, length(SW_times));

            % Loop through all events and generate slow waves
            for ii = 1:length(SW_times)
                % Simulate slow wave duration and amplitude
                SW_durations(ii) = obj.Dur_mean + rand * obj.Dur_sd;
                SW_amps(ii) = obj.Amp_mean + randn * obj.Amp_sd;
                SW_t = linspace(0, 1, SW_durations(ii) * Fs);

                % Generate a parametric slow wave
                SW = (sin(5/4 * 2 * pi * SW_t) + sin(2/4 * pi * SW_t - pi)) .* hanning(length(SW_t))' * SW_amps(ii);

                % Add slow wave to time series
                inds = round(SW_t * Fs + SW_times(ii) - SW_durations(ii) * Fs / 2);

                if all(inds > 1 & inds < N)
                    slow_waves(inds) = SW;
                end
            end

            % Save results
            obj.Times = SW_times / Fs;
            obj.Amps = SW_amps;
            obj.Durations = SW_durations;
            obj.Signal = slow_waves;
        end
    end
end
