classdef BandEEG < handle
    %BANDEEG Class for simulating band-limited EEG noise.
    %
    %   Usage:
    %       obj = BandEEG('PropertyName', PropertyValue, ...)
    %
    %   Properties (default values in parentheses):
    %       FrequencyRange: double vector - Frequency range for band power [Hz] (Default: [0.1 1.5])
    %       Amplitude: double - Amplitude of the band power (Default: 5)
    %       Signal: double array - Stored simulated noise signal (empty if no simulation is performed)
    %       isActive: logical - Flag to indicate if the object is active (Default: true)
    %
    %   Methods:
    %       sim: Simulate band-limited noise based on a time vector.
    %
    %   Example:
    %       % Create an instance of BandEEG with specific parameters
    %       bandEEG = BandEEG('FrequencyRange', [8 12], 'Amplitude', 10);
    %
    %       % Simulate noise on a time vector
    %       Fs = 1000;
    %       t = 0:(1/Fs):10; % Example time vector
    %       band_noise = bandEEG.sim(t);
    %       plot(t, band_noise);
    %
    %   Copyright 2024 Prerau Laboratory. - http://www.sleepEEG.org
    % *********************************************************************
    
    properties
        FrequencyRange double {mustBeReal, mustBeVector, mustBeNonempty} = [0.1 1.5]; % Frequency range for band power [Hz]
        Amplitude double {mustBePositive, mustBeReal, mustBeNonempty} = 5; % Amplitude of band power
        Signal double = []; % Stored simulated noise signal
        isActive logical = true; % Flag to indicate if the object is active
    end

    methods
        function obj = BandEEG(varargin)
            %BANDEEG Construct an instance of this class.
            %
            %   Usage:
            %       obj = BandEEG('PropertyName', PropertyValue, ...)
            %
            %   Inputs (name-value pairs):
            %       FrequencyRange: double vector - Frequency range for band power [Hz] (Default: [0.1 1.5])
            %       Amplitude: double - Amplitude of the band power (Default: 5)
            
            % Create an input parser object
            p = inputParser;

            % Define the parameters and their default values
            addOptional(p, 'FrequencyRange', obj.FrequencyRange, @(x) validateattributes(x, {'numeric'}, {'vector', 'increasing'}));
            addOptional(p, 'Amplitude', obj.Amplitude, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));

            % Parse the inputs
            parse(p, varargin{:});

            % Assign parsed values to object properties
            obj.FrequencyRange = p.Results.FrequencyRange;
            obj.Amplitude = p.Results.Amplitude;
        end

        function band_EEG = sim(obj, t)
            %SIM Simulate band-limited EEG noise based on a time vector.
            %
            %   Usage:
            %       band_EEG = sim(obj, t)
            %
            %   Input:
            %       t: double array - Time vector (e.g., [0, 0.001, 0.002, ...])
            %
            %   Output:
            %       band_EEG: double array - Simulated band-limited noise values at each time point
            %
            %   Example:
            %       % Create an instance of BandEEG with specific parameters
            %       bandEEG = BandEEG('FrequencyRange', [8 12], 'Amplitude', 10);
            %
            %       % Simulate noise on a time vector
            %       Fs = 1000;
            %       t = 0:(1/Fs):10; % Example time vector
            %       band_noise = bandEEG.sim(t);
            %       plot(t, band_noise);
            %
            
            assert(nargin==2,'A time vector must be provided for simulation');

            if ~isempty(obj.FrequencyRange) && ~isempty(obj.Amplitude)
                N = length(t);
                Fs = 1/(t(2)-t(1));

                if obj.Amplitude > 0
                    % Design a bandpass filter based on the specified frequency range
                    d = designfilt('bandpassiir', ...
                        'StopbandFrequency1',max(obj.FrequencyRange(1)-1,0.005), ... % Frequency constraints
                        'PassbandFrequency1',obj.FrequencyRange(1), ...
                        'PassbandFrequency2',obj.FrequencyRange(2), ...
                        'StopbandFrequency2',min(obj.FrequencyRange(2)+1, Fs/2), ...
                        'StopbandAttenuation1',60, ... % Magnitude constraints
                        'PassbandRipple',1, ...
                        'StopbandAttenuation2',60, ...
                        'DesignMethod','ellip', ... % Design method
                        'MatchExactly','passband', ... % Design method options
                        'SampleRate',Fs);

                    % Simulate the band-limited EEG noise
                    obj.Signal = filter(d,randn(1,N));
                    obj.Signal = obj.Signal/(prctile(abs(obj.Signal),97.5))*obj.Amplitude;
                    band_EEG = obj.Signal;
                end
            else
                error('Must have valid frequency range and amplitude to simulate');
            end
        end
    end
end
