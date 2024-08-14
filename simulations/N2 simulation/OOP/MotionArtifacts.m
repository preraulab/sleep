classdef MotionArtifacts < handle
    %MOTIONARTIFACTS Class for simulating motion artifacts in EEG data.
    %
    %   Usage:
    %       ma = MotionArtifacts('PropertyName', PropertyValue, ...)
    %
    %   Properties (default values in parentheses):
    %       Rate: double - Rate of motion artifacts in events per second (Default: 10/3600)
    %       Amp_mean: double - Mean amplitude of motion artifacts (Default: 600)
    %       Amp_sd: double - Standard deviation of motion artifact amplitudes (Default: 60)
    %       Amp_min: double - Minimum motion artifact amplitude (Default: 100)
    %       Times: double array - Generated artifact times (empty if no sim)
    %       Signal: double array - Stored simulated noise signal (empty if no simulation is performed)
    %
    %   Methods:
    %       sim: Simulate motion artifacts based on time vector.
    %
    %   Example:
    %       % Create options for simulating motion artifacts with specific parameters
    %       ma = MotionArtifacts('rate', 20/3600, 'amp_mean', 700, 'amp_sd', 150);
    %
    %       % Simulate artifacts on a time vector
    %       Fs = 200;
    %       t = 0:(1/Fs):3600*2; % Example time vector
    %       [artifacts, features] = ma.sim(t);
    %       plot(t, artifacts);
    %
    %   Copyright 2024 Prerau Laboratory. - http://www.sleepEEG.org
    % *********************************************************************

    properties
        Rate double {mustBeNonnegative, mustBeReal, mustBeNumeric, mustBeNonempty} = 10/3600; % Rate of motion artifacts (events per second)
        Amp_mean double {mustBeNonnegative, mustBeReal, mustBeNumeric, mustBeNonempty} = 600; % Mean amplitude of motion artifacts
        Amp_sd double {mustBeNonnegative, mustBeReal, mustBeNumeric, mustBeNonempty} = 60; % Standard deviation of motion artifact amplitudes
        Amp_min double {mustBeNonnegative, mustBeReal, mustBeNumeric, mustBeNonempty} = 100; % Minimum amplitude value

        Times double = []; % Generated artifact times
        Amps double = []; % Generated artifact amplitudes
        Signal double = []; % Stored simulated signal

        isActive = true;
    end

    methods
        function obj = MotionArtifacts(varargin)
             % Create an input parser object
            p = inputParser;
            
            % Define the parameters and their default values
            addOptional(p, 'Rate', obj.Rate, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
            addOptional(p, 'Amp_mean', obj.Amp_mean, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
            addOptional(p, 'Amp_sd', obj.Amp_sd, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
            addOptional(p, 'Amp_min', obj.Amp_min, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
                        
            % Parse the inputs
            parse(p, varargin{:});
            
            % Assign parsed values to object properties
            obj.Rate = p.Results.Rate;
            obj.Amp_mean = p.Results.Amp_mean;
            obj.Amp_sd = p.Results.Amp_sd;
            obj.Amp_min = p.Results.Amp_min;
        end

        function artifacts = sim(obj, t)
            %SIM Simulate motion artifacts based on a time vector.
            %
            %   Usage:
            %       [artifacts, features] = sim(obj, t)
            %
            %   Input:
            %       t: double array - Time vector (e.g., [0, 0.001, 0.002, ...])
            %
            %   Output:
            %       artifacts: double array - Simulated motion artifact values at each time point
            %       features: structure - Contains artifact times and amplitudes
            %
            %   Example:
            %       % Create options for simulating motion artifacts with specific parameters
            %       ma = MotionArtifacts('rate', 20/3600, 'amp_mean', 700, 'amp_sd', 150);
            %
            %       % Simulate artifacts on a time vector
            %       Fs = 200;
            %       t = 0:(1/Fs):3600*2; % Example time vector
            %       [artifacts, features] = ma.sim(t);
            %       plot(t, artifacts);
            %
            assert(nargin==2,'A time vector must be provided for simulation');

            N = length(t);
            Fs = 1/(t(2)-t(1));

            if any(isempty([obj.Rate, obj.Amp_mean, obj.Amp_sd]))
                error('Must have valid rate, amplitude mean, and amplitude standard deviation to simulate');
            else
                % Generate Poisson events
                artifacts = min(poissrnd(obj.Rate/Fs*ones(1, N), 1, N), 1);

                % Generate artifact features
                N_art = sum(artifacts);
                artifact_times = t(artifacts == 1);
                artifact_amps = max(randn(1, N_art) * obj.Amp_sd + obj.Amp_mean, obj.Amp_min);

                % Set the values of the events to be the amplitude
                artifacts(artifacts > 0) = artifact_amps;

                % Use the sinc function as the basis for the artifact shape
                t_art = 0:(1/Fs):10;
                art = [-sinc(max(t_art)-t_art) sinc(t_art) * 2];
                art = art ./ max(art);

                % Convolve the shape with the event train to create artifacts
                artifacts = convn(artifacts, art, 'same');

                % Add to output structure
                obj.Times = artifact_times;
                obj.Amps = artifact_amps;

                % Save signal
                obj.Signal = artifacts;
            end
        end
    end
end
