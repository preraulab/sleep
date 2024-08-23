classdef Oscillator < handle
    %OSCILLATOR  Create an noisy oscillator object with specified properties.
    %
    %   The Oscillator class simulates noisy oscillator with a specific
    %   frequency, state noise, observation noise, and autoregressive parameter.
    %
    %   Usage:
    %       obj = Oscillator('PropertyName', PropertyValue, ...)
    %
    %   Inputs (name-value pairs):
    %       Frequency: double vector - Frequency range for band power [Hz]
    %           (Default: 8)
    %       sig2state: double - Amplitude of the state noise (Default: 0.1)
    %       sig2obs: double - Amplitude of the observation noise (Default: 0.1)
    %       rho: double - Damping parameter (Default: 0.9)
    %       m: double - Amplitude multiplier (Default: 1)
    %       isActive: logical - Flag to indicate if the object is active (Default: true)
    %
    %   Properties:
    %       Frequency: double vector - Frequency range for band power [Hz]
    %       sig2state: double - Amplitude of the state noise
    %       sig2obs: double - Amplitude of the observation noise
    %       rho: double - Autoregressive parameter
    %       Signal: double vector - Stored simulated noise signal
    %       isActive: logical - Flag to indicate if the object is active
    %
    %   Example:
    %       osc = Oscillator('Frequency', 10, 'sig2state', 0.05);
    %       disp(osc.Frequency);
    %

    properties
        Frequency double {mustBeReal, mustBeVector, mustBeNonempty} = 8; % Frequency range for band power [Hz]
        sig2state double {mustBePositive, mustBeReal, mustBeNonempty} = 15; % Amplitude of state noise
        sig2obs double {mustBePositive, mustBeReal, mustBeNonempty} = 0.1; % Amplitude of observation noise
        rho double {mustBePositive, mustBeReal, mustBeNonempty} = 0.9; % Autoregressive parameter
        m double {mustBePositive, mustBeReal, mustBeNonempty} = 1; % Autoregressive parameter


        Signal double = []; % Stored simulated noise signal
        isActive logical = true; % Flag to indicate if the object is active
    end

    methods
        function obj = Oscillator(varargin)
            %OSCILLATOR Construct an instance of this class.
            %
            %   Usage:
            %       obj = Oscillator('PropertyName', PropertyValue, ...)
            %
            %   Inputs (name-value pairs):
            %       Frequency: double vector - Frequency range for band power [Hz]
            %           (Default: 8)
            %       sig2state: double - Amplitude of the state noise (Default: 0.1)
            %       sig2obs: double - Amplitude of the observation noise (Default: 0.1)
            %       rho: double - Damping parameter (Default: 0.9)
            %       isActive: logical - Flag to indicate if the object is active (Default: true)

            % Create an input parser object
            p = inputParser;

            % Define the parameters and their default values
            addParameter(p, 'Frequency', obj.Frequency, @(x) validateattributes(x, {'numeric'}, {'vector', 'nonempty'}));
            addParameter(p, 'sig2state', obj.sig2state, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
            addParameter(p, 'sig2obs', obj.sig2obs, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
            addParameter(p, 'rho', obj.rho, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
            addParameter(p, 'm', obj.rho, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
            addParameter(p, 'isActive', obj.isActive, @(x) islogical(x) && isscalar(x));

            % Parse the inputs
            parse(p, varargin{:});

            % Assign parsed values to object properties
            obj.Frequency = p.Results.Frequency;
            obj.sig2state = p.Results.sig2state;
            obj.sig2obs = p.Results.sig2obs;
            obj.rho = p.Results.rho;
            obj.m = p.Results.m;
            obj.isActive = p.Results.isActive;
        end

        function oscillation = sim(obj, t)
            Fs = 1/(t(2)-t(1));
            oscillation = obj.genNoisyOscillator(t, Fs, obj.Frequency, obj.m, obj.rho, obj.sig2state, obj.sig2obs);
            obj.Signal = oscillation;
        end
    end

    methods (Static)
        function y = genNoisyOscillator(t, Fs, freq, m, rho, s2state, s2obs)
            %GENNOISYOSCILLATOR Generate noisy oscillatory data using a state-space model.
            %
            %   Usage:
            %       [t, y] = genNoisyOscillator(Duration, Fs, freq, a, sig2state, sig2obs)
            %
            %   Input:
            %       Duration: double - Duration of the simulation in seconds.
            %       Fs: double - Sampling frequency in Hz.
            %       freq: double - Frequency of the oscillation in Hz.
            %       rho: double - Damping parameter (Default: 0.9)
            %       m: double - Amplitude multiplier parameter (Default: 1)
            %       sig2state: double - Variance of the state noise.
            %       sig2obs: double - Variance of the observation noise.
            %
            %   Output:
            %       t: 1xT vector - Time vector corresponding to the observations.
            %       y: 1xT vector - Simulated noisy oscillatory data (observations).
            %
            %   Example:
            %       [t, y] = genNoisyOscillator(1, 200, 15, 10, 0.1);
            %       plot(t, y);
            %       title('Simulated Noisy Oscillatory Data');
            %       xlabel('Time (s)');
            %       ylabel('Observation');
            %
            %   Copyright 2023 Michael J. Prerau Laboratory. - http://www.sleepEEG.org
            %% ********************************************************************

            % Calculate angular frequency and state transition matrix F
            w = 2 * pi * freq / Fs;  % Angular frequency
            F = rho * [cos(w) -sin(w); sin(w) cos(w)];
            G = [1 0];

            % Time series setup
            T = length(t);

            % Initialize state and observation matrices
            x = zeros(2, T + 1);   % Hidden states (2D state space, T+1 time points)
            y = zeros(1, T);       % Observations (1D observation, T time points)

            % Initial state at t=0, sampled from the state noise distribution
            x(:, 1) = randn(2,1) * s2state;

            % Simulation of the state-space model over time
            for ii = 2:T + 1
                % Update the hidden state using the state transition matrix F and noise
                x(:, ii) = F * x(:, ii - 1) + randn(2,1) * s2state;
                % Generate the observation using the observation matrix G and noise
                y(:, ii - 1) = m * G * x(:, ii) + randn * s2obs;
            end
          
        end
    end
end
