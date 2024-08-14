classdef LineNoise < handle
    %LINENOISE Class for simulating line noise in EEG data.
    %
    %   Usage:
    %       ln = LineNoise('PropertyName', PropertyValue, ...)
    %
    %   Properties (default values in parentheses):
    %       Waveform: char - Type of line noise ('sin', 'square', 'sawtooth'). (Default: 'sin')
    %       Freq: double - Frequency of line noise components. (Default: 60)
    %       Amp: double - Amplitude of line noise components. (Default: 5)
    %       Signal: double array - Stored simulated noise signal (empty if no simulation is performed)
    %
    %   Methods:
    %       sim: Simulate line noise based on a time vector.
    %
    %   Example:
    %       % Create an instance of LineNoise with specific parameters
    %       ln = LineNoise('Waveform', 'sin', 'Freq', 60, 'Amp', 10);
    %
    %       % Simulate line noise on a time vector
    %       Fs = 1000;
    %       t = 0:(1/Fs):10; % Example time vector
    %       line_noise = ln.sim(t);
    %       plot(t, line_noise);
    %
    %   Copyright 2024 Prerau Laboratory. - http://www.sleepEEG.org
    % *********************************************************************

    properties
        Waveform char {mustBeText, mustBeNonempty, mustBeMember(Waveform, {'sin', 'square', 'sawtooth'})} = 'sin' % Types of line noise
        Freq double {mustBePositive, mustBeReal, mustBeNumeric, mustBeNonempty} = 60 % Frequencies of line noise components
        Amp double {mustBePositive, mustBeReal, mustBeNumeric, mustBeNonempty} = 5 % Amplitudes of line noise components
        Signal double = [] % Stored simulated line noise signal

        isActive = true;
    end

    methods
        function obj = LineNoise(varargin)
            % Create an input parser object
            p = inputParser;

            % Define the parameters and their default values
            addOptional(p, 'Waveform', obj.Waveform, @(x)ismember(x,{'sin', 'square', 'sawtooth'}));
            addOptional(p, 'Freq', obj.Freq, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
            addOptional(p, 'Amp', obj.Amp, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));

            % Parse the inputs
            parse(p, varargin{:});

            % Assign parsed values to object properties
            obj.Waveform = p.Results.Waveform;
            obj.Freq = p.Results.Freq;
            obj.Amp = p.Results.Amp;
        end

        function line_noise = sim(obj, t)
            %SIM Simulate line noise based on a time vector.
            %
            %   Usage:
            %       line_noise = sim(obj, t)
            %
            %   Input:
            %       t: double array - Time vector (e.g., [0, 0.001, 0.002, ...])
            %
            %   Output:
            %       line_noise: double array - Simulated line noise values at each time point
            %
            %   Example:
            %       % Create options for simulating line noise with specific parameters
            %       ln = LineNoise('sin', 60, 10);
            %
            %       % Simulate line noise on a time vector
            %       Fs = 1000;
            %       t = 0:(1/Fs):10; % Example time vector
            %       line_noise = ln.sim(t);
            %       plot(t, line_noise);
            %
            assert(nargin==2,'A time vector must be provided for simulation');

            if isempty(obj.Waveform) || isempty(obj.Freq) || isempty(obj.Amp)
                error('Must have valid type, frequency, and amplitude to simulate');
            else
                Fs = 1 / (t(2) - t(1)); % Sampling frequency

                % Initialize line noise array
                line_noise = zeros(size(t));

                % Loop through each line noise component
                switch obj.Waveform
                    case 'sin'
                        ln_fun = @sin;
                    case 'sawtooth'
                        ln_fun = @sawtooth;
                    case 'square'
                        ln_fun = @square;
                    otherwise
                        error('Invalid line noise function type. Options are sin, square, and sawtooth');
                end

                % Check if frequency is below Nyquist
                if obj.Freq < Fs / 2
                    line_noise = line_noise + obj.Amp * ln_fun(2 * pi * t * obj.Freq);
                else
                    warning(['Line noise at ' num2str(obj.Freq) ' Hz not simulated, since it is above the Nyquist']);
                end

                % Save signal
                obj.Signal = line_noise;
            end
        end
    end
end