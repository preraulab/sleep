function [SOfilt_data, SOfilt_times, SO_phase, SW_amps, SW_durs, SW_stage, SW_times, SW_inds] = extract_SW(data, Fs, stage_times, stage_vals, varargin)
%EXTRACT_SW Extract slow waves from EEG data
%
%   Usage:
%       [SOfilt_data, SOfilt_times, SO_phase, SW_amps, SW_durs, SW_stage, SW_times, SW_inds] = extract_SW(data, Fs, stage_times, stage_vals, 'Name', Value)
%
%   Input:
%       data: <number of samples> x 1 vector - EEG data -- required
%       Fs: double - sampling frequency in Hz -- required
%       stage_times: 1xP vector - time values corresponding to sleep stages -- required
%       stage_vals: 1xP vector - sleep stage values corresponding to stage_times -- required
%       Optional Name-Value Pairs:
%           'include_stages': 1xM vector - stages to include in the analysis (default: 1:3)
%           'thresh_ptile': double - threshold percentile (default: 75)
%           'include_stages_thresh': 1xN vector - stages for thresholding (default: 1 , where N3 = 1, N2 = 2, N1 = 3, REM = 4, W = 5)
%           'dur_min': double - minimum duration of slow waves (default: 0.8)
%           'dur_max': double - maximum duration of slow waves (default: 2)
%           'verbose': logical - option to display verbose output (default: true)
%           'plot_on': logical - option to plot the results (default: true)
%
%   Output:
%       SOfilt_data: <number of samples> x 1 vector - EEG data filtered for SO
%       SOfilt_times: <number of samples> x 1 - time values corresponding to filtered data
%       SO_phase: <number of samples> x 1 vector - phase of slow oscillation
%       SW_amps: Nx1 vector - amplitudes of slow waves
%       SW_durs: Nx1 vector - durations of slow waves
%       SW_stage: Nx1 vector - sleep stage values corresponding to slow waves
%       SW_times: Nx2 matrix - start and end times of slow waves
%       SW_inds: Nx2 matrix - start and end indices of slow waves
%
%   Description:
%       This function extracts slow waves (SWs) from EEG data. It detects artifacts,
%       computes the SO phase, removes artifacts and unwanted stages, finds zero crossings, 
%       and finds SWs that fall above the amplitude threshold and are the
%       required duration
%
%   Example:
%       % Extract slow waves from EEG data with default parameters
%       extract_SW(eeg_data, 200, stage_times, stage_vals);
%
%       % Extract slow waves from EEG data, only including stages 1 to 2
%       % and change percentile to p60
%       extract_SW(eeg_data, 200, stage_times, stage_vals, 'include_stages', 1:2, 'thresh_ptile', 60);
%
%   See also: detect_artifacts, computeSOphase
%
%   Copyright 2024 Prerau Lab - http://www.sleepEEG.org
%**********************************************************************

% Create input parser
p = inputParser;
addRequired(p, 'data', @(x) isvector(x) && isnumeric(x)); % data must be a vector of numeric values
addRequired(p, 'Fs', @(x) isscalar(x) && isnumeric(x) && x > 0); % Fs must be a positive scalar
addRequired(p, 'stage_times', @(x) isvector(x) && isnumeric(x)); % stage_times must be a vector of numeric values
addRequired(p, 'stage_vals', @(x) isvector(x) && isnumeric(x)); % stage_vals must be a vector of numeric values

default_include_stages = 1:3;
default_thresh_ptile = 75;
default_include_stages_thresh = 1;
default_dur_min = 0.8;
default_dur_max = 2;
default_verbose = true;
default_plot_on = true;

addOptional(p, 'include_stages', default_include_stages, @(x) isvector(x) && isnumeric(x));
addOptional(p, 'thresh_ptile', default_thresh_ptile, @(x) isscalar(x) && isnumeric(x) && isnumeric(x) && x>=0 && x<=100);
addOptional(p, 'include_stages_thresh', default_include_stages_thresh, @(x) isvector(x) && all(ismember(x,0:6)));
addOptional(p, 'dur_min', default_dur_min, @(x) isscalar(x) && isnumeric(x) && x>=0);
addOptional(p, 'dur_max', default_dur_max, @(x) isscalar(x) && isnumeric(x) && x>0);
addOptional(p, 'verbose', default_verbose, @(x) isscalar(x) && islogical(x));
addOptional(p, 'plot_on', default_plot_on, @(x) isscalar(x) && islogical(x));

% Parse inputs
parse(p, data, Fs, stage_times, stage_vals, varargin{:});

% Extract parsed inputs
data = p.Results.data;
Fs = p.Results.Fs;
stage_times = p.Results.stage_times;
stage_vals = p.Results.stage_vals;
include_stages = p.Results.include_stages;
thresh_ptile = p.Results.thresh_ptile;
include_stages_thresh = p.Results.include_stages_thresh;
plot_on = p.Results.plot_on;
dur_min = p.Results.dur_min;
dur_max = p.Results.dur_max;
verbose = p.Results.verbose;

assert(dur_min<dur_max,'Duration min must be less than duration max');

% Detect artifacts
if verbose
    disp("Detecting artifacts...")
    disp('  ');
    artifacts = detect_artifacts(data,Fs,'zscore_method','robust','hf_crit', 5.5,'bb_crit', 5.5,'slope_test',true, 'verbose',false);
end

% Get this function from dynam-o
[SO_phase, SOfilt_times, ~, SOfilt_data] = computeSOphase(data, Fs);

% Remove artifacts
SOfilt_data(artifacts) = nan;

% Interpolate stages to time of SO_phase
time_stages = interp1(stage_times, stage_vals, SOfilt_times, 'previous');

% Remove unwanted stages from the data
include_inds = ismember(time_stages, include_stages);
SOfilt_data(~include_inds) = nan;

if plot_on
    % Just for plotting and testing
    filtdata_orig = SOfilt_data;
end

% Find zero crossings
SW_bounds = find(diff(sign([0 SOfilt_data])) < 0);

N_waves_orig = length(SW_bounds) - 1;

if verbose
    stage_str = ["N3" "N2" "N1" "R" "W"];
    disp(['Initial search found ' num2str(N_waves_orig) ' slow waves in ' sprintf('%s ',stage_str(include_stages))]);
    disp('  ');
end

% Save SW amplitudes and indices
SW_amps = zeros(N_waves_orig,1);
SW_durs = zeros(N_waves_orig,1);
SW_inds = zeros(N_waves_orig,2);
SW_stage = zeros(N_waves_orig,1);

% Compute amplitudes and indices
for ii = 1:N_waves_orig
    SW_inds(ii,:) = [SW_bounds(ii) SW_bounds(ii+1)];
    swave_inds = SW_inds(ii,1):SW_inds(ii,2);

    SW_wave = SOfilt_data(swave_inds);
    SW_amps(ii) = max(SW_wave) - min(SW_wave);
    SW_durs(ii) = length(swave_inds) / Fs;
    SW_stage(ii) = mode(time_stages(swave_inds));
end

% Filter duration first
dur_inds = SW_durs >= dur_min & SW_durs <= dur_max;
N_waves_dur = sum(dur_inds);

SW_amps = SW_amps(dur_inds);
SW_durs = SW_durs(dur_inds);
SW_stage = SW_stage(dur_inds);
SW_inds = SW_inds(dur_inds,:);

if verbose
    disp('Filtering with:');
    disp(['   Duration range:  ' num2str(dur_min) ' to ' num2str(dur_max)]);
    disp(['Removed ' num2str(N_waves_orig - N_waves_dur) ' slow waves. ' num2str(N_waves_dur) ' slow waves remaining']);
    disp('  ');
end

% Get bounds of times
SW_times = SOfilt_times(SW_inds);

% Set a threshold within the limited stages
amp_thresh = prctile(SW_amps(ismember(SW_stage, include_stages_thresh)), thresh_ptile);

% Set bounds of SWs to keep
keep_inds = SW_amps >= amp_thresh;
N_keep = sum(keep_inds);

SW_amps = SW_amps(keep_inds);
SW_durs = SW_durs(keep_inds);
SW_stage = SW_stage(keep_inds);
SW_inds = SW_inds(keep_inds,:);
SW_times = SW_times(keep_inds,:);

if verbose
    disp('Filtering with:');
    disp(['   Amplitude threshold: p' num2str(thresh_ptile) ' of ' sprintf('%s ',stage_str(include_stages_thresh))]);
    disp(['                 Value: ' num2str(amp_thresh)]);
    disp(['Removed ' num2str(N_waves_dur - N_keep) ' slow waves. ' num2str(N_keep) ' slow waves retained']);
    disp('  ');
end

%Plot results
if plot_on
    % Keep all data that pass test
    SW_filtered = nan(size(SOfilt_data));
    for ii = 1:N_keep
        swave_inds = SW_inds(ii,1):SW_inds(ii,2);
        SW_wave = SOfilt_data(swave_inds);
        SW_filtered(swave_inds) = SW_wave;
    end

    ax = split_axis(gca,[.2 .8],1);
    linkaxes(ax,'x');
    axes(ax(1))
    hypnoplot(stage_times,stage_vals);
    axes(ax(2))
    hold on
    plot(SOfilt_times, filtdata_orig, 'color', [.7 .7 .7]);
    plot(SOfilt_times, SW_filtered, 'linewidth', .5)
    plot(SW_times(:,1), zeros(size(SW_times(:,1))), 'bx');
    plot(SW_times(:,2), zeros(size(SW_times(:,2))), 'b.');
    ylim([-150 150]);
end
end
