classdef AperiodicEEG < handle
    %APERIODICEEG Class for simulating aperiodic EEG 1/f noise.
    %
    %   Usage:
    %       opts = AperiodicEEG('PropertyName', PropertyValue, ...)
    %
    %   Properties (default values in parentheses):
    %       Alpha: double - Exponent for 1/f^alpha noise (Default: 1.5)
    %       Magnitude: double - Scaling factor for 1/f^alpha noise (Default: 5)
    %       Signal: double array - Stored simulated noise signal (empty if no simulation is performed)
    %
    %   Methods:
    %       sim: Simulate aperiodic noise based on a time vector.
    %
    %   Example:
    %       % Create options for simulating EEG 1/f noise with specific parameters
    %       ap = AperiodicEEG(2,10);
    %
    %       % Simulate noise on a time vector
    %       Fs = 1000;
    %       t = 0:(1/Fs):10; % Example time vector
    %       aperiodic_noise = ap.sim(t);
    %       plot(t, aperiodic_noise);
    %
    %   Copyright 2024 Prerau Laboratory. - http://www.sleepEEG.org
    % *********************************************************************

    properties
        Alpha double {mustBeReal, mustBeNonempty} = 1.5; % Exponent for 1/f^alpha noise
        Magnitude double {mustBePositive, mustBeReal, mustBeNonempty} = 5; % Scaling factor for 1/f^alpha noise

        Signal double = []; % Stored simulated noise signal
    end

    methods
        function obj = AperiodicEEG(varargin)
            % Create an input parser object
            p = inputParser;
            
            % Define the parameters and their default values
            addOptional(p, 'Alpha', obj.Alpha, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
            addOptional(p, 'Magnitude', obj.Magnitude, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
                        
            % Parse the inputs
            parse(p, varargin{:});
            
            % Assign parsed values to object properties
            obj.Alpha = p.Results.Alpha;
            obj.Magnitude = p.Results.Magnitude;
        end

        function aperiodic_noise = sim(obj, t)
            %SIM Simulate aperiodic noise based on a time vector.
            %
            %   Usage:
            %       aperiodic_noise = sim(obj, t)
            %
            %   Input:
            %       t: double array - Time vector (e.g., [0, 0.001, 0.002, ...])
            %
            %   Output:
            %       aperiodic_noise: double array - Simulated aperiodic noise values at each time point
            %
            %   Example:
            %       % Create options for simulating EEG 1/f noise with specific parameters
            %       ap = AperiodicEEG(2, 10);
            %
            %       % Simulate noise on a time vector
            %       Fs = 1000;
            %       t = 0:(1/Fs):10; % Example time vector
            %       aperiodic_noise = ap.sim(t);
            %       plot(t, aperiodic_noise);
            %
            assert(nargin==2,'A time vector must be provided for simulation');

            if ~isempty(obj.Alpha) && ~isempty(obj.Magnitude)
                N = length(t);
                if obj.Magnitude > 0
                    cn = dsp.ColoredNoise('SamplesPerFrame', N, 'InverseFrequencyPower', obj.Alpha);
                    aperiodic_noise = cn() * obj.Magnitude;
                    obj.Signal = aperiodic_noise';
                end
            else
                error('Must have valid alpha and magnitude to simulate');
            end
        end
    end
end
