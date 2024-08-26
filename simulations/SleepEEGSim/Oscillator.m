classdef Oscillator < handle
    %OSCILLATOR  Create an noisy oscillator object with specified properties.
    %
    %   The Oscillator class simulates noisy oscillator with a specific
    %   Freq, state noise, observation noise, and autoregressive parameter.
    %
    %   Usage:
    %       obj = Oscillator('PropertyName', PropertyValue, ...)
    %
    %   Inputs (name-value pairs):
    %       Freq: double vector - Frequency for oscillator[Hz] (Default: 8)
    %       StateNoise: double - Amplitude of the state noise (Default: 0.1)
    %       ObsNoise: double - Amplitude of the observation noise (Default: 0.1)
    %       DampingFactor: double - Autoregressive damping factor (Default: 0.99)
    %       AmpMult: double - Amplitude multiplier (Default: 1)
    %       isActive: logical - Flag to indicate if the object is active (Default: true)
    %
    %   NOTE: Set rho to 1 and sig2state and sig2obs to 0 to generate a
    %   pure sin wave
    %
    %   Properties:
    %       Freq: double vector - Freq center for oscillator [Hz]
    %       StateNoise: double - Amplitude of the state noise
    %       ObsNoise: double - Amplitude of the observation noise
    %       DampingFactor: double - Autoregressive parameter
    %       AmpMult: double - Amplitude multiplier
    %       Signal: double vector - Stored simulated noise signal
    %       isActive: logical - Flag to indicate if the object is active
    %
    %   Example:
    %       osc = Oscillator('Freq', 10, 'StateNoise', 0.05);
    %       disp(osc.Freq);
    %

    properties
        Freq double {mustBeReal, mustBeVector, mustBeNonempty} = 8; % Freq range for band power [Hz]
        StateNoise double {mustBeNonnegative, mustBeReal, mustBeNonempty} = 15; % Amplitude of state noise
        ObsNoise double {mustBeNonnegative, mustBeReal, mustBeNonempty} = 0.1; % Amplitude of observation noise
        DampingFactor double {mustBePositive, mustBeReal, mustBeNonempty} = 0.99; % Autoregressive parameter
        AmpMult double {mustBePositive, mustBeReal, mustBeNonempty} = 1; % Autoregressive parameter

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
            %       Freq: double vector - Freq range for band power [Hz]
            %           (Default: 8)
            %       sig2state: double - Amplitude of the state noise (Default: 0.1)
            %       sig2obs: double - Amplitude of the observation noise (Default: 0.1)
            %       rho: double - Damping parameter (Default: 0.99)
            %       isActive: logical - Flag to indicate if the object is active (Default: true)

            % Create an input parser object
            p = inputParser;

            % Define the parameters and their default values
            addParameter(p, 'Freq', obj.Freq, @(x) validateattributes(x, {'numeric'}, {'vector', 'nonempty'}));
            addParameter(p, 'StateNoise', obj.StateNoise, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
            addParameter(p, 'ObsNoise', obj.ObsNoise, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
            addParameter(p, 'DampingFactor', obj.DampingFactor, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
            addParameter(p, 'AmpMult', obj.AmpMult, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
            addParameter(p, 'isActive', obj.isActive, @(x) islogical(x) && isscalar(x));

            % Parse the inputs
            parse(p, varargin{:});

            % Assign parsed values to object properties
            obj.Freq = p.Results.Freq;
            obj.StateNoise = p.Results.StateNoise;
            obj.ObsNoise = p.Results.ObsNoise;
            obj.DampingFactor = p.Results.DampingFactor;
            obj.AmpMult = p.Results.AmpMult;
            obj.isActive = p.Results.isActive;
        end

        function oscillation = sim(obj, t)
            Fs = 1/(t(2)-t(1));
            oscillation = obj.genNoisyOscillator(t, Fs, obj.Freq, obj.AmpMult, obj.DampingFactor, obj.StateNoise, obj.ObsNoise);
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
            %       Fs: double - Sampling Freq in Hz.
            %       freq: double - Freq of the oscillation in Hz.
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
           
            % Calculate angular Freq and state transition matrix F
            w = 2 * pi * freq / Fs;  % Angular Freq
            F = rho * [cos(w) -sin(w); sin(w) cos(w)];
            G = [1 0];

            % Time series setup
            T = length(t);

            % Initialize state and observation matrices
            x = zeros(2, T + 1);   % Hidden states (2D state space, T+1 time points)
            y = zeros(1, T);       % Observations (1D observation, T time points)

            % Initial state at t=0, sampled from the state noise distribution
            x(:, 1) = randn(2,1);

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
