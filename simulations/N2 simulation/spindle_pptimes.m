function [spindle_times, spindle_train, S, t_spline] = spindle_pptimes(Fs, Fs_sp, baseline_rate, phase, coupling_mag, phase_pref, ctrl_pts, theta_spline, tension, spline_tmax)
%SPINDLE_PPTIMES Generate spindle times and train using phase and spline parameters
%
%   Usage:
%       [spindle_times, spindle_train, S, t_spline] = spindle_pptimes(Fs, Fs_sp, baseline_rate, phase, coupling_mag, phase_pref, ctrl_pts, theta_spline, tension, spline_tmax)
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
%       spindle_times: 1xT vector - times of spindle events
%       spindle_train: <number of samples> x 1 vector - binary spindle train
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
%       [spindle_times, spindle_train, S, t_spline] = spindle_pptimes(Fs, Fs_sp, baseline_rate, phase, coupling_mag, phase_pref, ctrl_pts, theta_spline, tension, spline_tmax);
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

%Set default rate
if isempty(baseline_rate)
    baseline_rate = 10/60;
end

% Define spline parameters
if isempty(spline_tmax)
    spline_tmax = 15;
end

% Define control points and values
if isempty(ctrl_pts)
    ctrl_pts = -3:3:18;
end

% Define spline parameters
if isempty(theta_spline)
    theta_spline = [-8, -5, 0, 0.5, 0, 0, 0, 0];
end

% Define tension parameter
if isempty(tension)
    tension = 1;
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
spindle_train = zeros(N, 1);
lambda = zeros(N, 1);

for i = spline_tmax + 1:N
    % Extract the segment of the spindle train for spline fitting
    spindle_seg = spindle_train(i - 1:-1:i - spline_tmax);

    % Calculate the firing rate lambda
    lambda(i) = exp(theta_spline * (S * spindle_seg) + phase_lambda(i) + log(baseline_rate));

    % Generate the spike train
    spindle_train(i) = min(poissrnd(lambda(i) / Fs_sp), 1);
end

% Extract the times of the spindle events
spindle_times = t(logical(spindle_train));

% Define the spline times
t_spline = (0:spline_tmax-1) / Fs_sp;
end
