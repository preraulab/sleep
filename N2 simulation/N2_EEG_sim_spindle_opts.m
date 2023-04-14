function spindle_opts = N2_EEG_sim_spindle_opts(varargin)
% N2_EEG_SIM_SPINDLE_OPTS - Returns a structure containing options for simulating N2 EEG spindles.
%
% Syntax:  spindle_opts = N2_EEG_sim_spindle_opts('ParameterName', ParameterValue, ...)
%
% Inputs:
%    'ParameterName', ParameterValue - Name-value pairs specifying options for simulating N2 EEG spindles.
%        Valid parameter names and their default values are:
%          'phase_pref'           - Preferred phase angle of the spindle, in radians. Default: pi.
%          'spindle_freq_mean'    - Mean frequency of the spindle, in Hz. Default: 15.
%          'spindle_freq_std'     - Standard deviation of the frequency, in Hz. Default: 1.
%          'spindle_amp_mean'     - Mean amplitude of the spindle, in microvolts. Default: 8.
%          'spindle_amp_std'      - Standard deviation of the amplitude, in microvolts. Default: 0.5.
%          'spindle_dur_mean'     - Mean duration of the spindle, in seconds. Default: 1.5.
%          'spindle_dur_std'      - Standard deviation of the duration, in seconds. Default: 0.25.
%          'spindle_baseline_rate'- Baseline rate of spindles, in Hz. Default: 10.
%          'modulation_factor'    - Modulation factor for cosine tuning. Default: 40.
%          'spindle_min_separation'- Minimum separation between spindles, in seconds. Default: 0.5.
%
% Outputs:
%    spindle_opts - A structure containing options for simulating N2 EEG spindles.
%
% Example:
%    spindle_opts = N2_EEG_sim_spindle_opts('spindle_freq_mean', 12, 'spindle_amp_mean', 5)
%    This returns a structure containing options for simulating N2 EEG spindles with mean frequency 12 Hz and mean amplitude 5 microvolts.
%
%    Copyright 2023 Michael J. Prerau Laboratory. - http://www.sleepEEG.org


% Set default values
defaults.phase_pref = pi;
defaults.spindle_freq_mean = 15;
defaults.spindle_freq_std = 1;
defaults.spindle_amp_mean = 8;
defaults.spindle_amp_std = 0.5;
defaults.spindle_dur_mean = 1.5;
defaults.spindle_dur_std = 0.25;
defaults.spindle_baseline_rate = 10;
defaults.modulation_factor = 4;
defaults.spindle_min_separation = 0.5;

% Create input parser
p = inputParser;

addParameter(p, 'phase_pref', defaults.phase_pref, @(x) validateattributes(x, {'numeric'}, {'real','scalar','>=',-pi,'<=',pi}));
addParameter(p, 'spindle_freq_mean', defaults.spindle_freq_mean, @(x) validateattributes(x, {'numeric'}, {'real','scalar','positive'}));
addParameter(p, 'spindle_freq_std', defaults.spindle_freq_std, @(x) validateattributes(x, {'numeric'}, {'real','scalar','positive'}));
addParameter(p, 'spindle_amp_mean', defaults.spindle_amp_mean, @(x) validateattributes(x, {'numeric'}, {'real','scalar','positive'}));
addParameter(p, 'spindle_amp_std', defaults.spindle_amp_std, @(x) validateattributes(x, {'numeric'}, {'real','scalar','positive'}));
addParameter(p, 'spindle_dur_mean', defaults.spindle_dur_mean, @(x) validateattributes(x, {'numeric'}, {'real','scalar','positive'}));
addParameter(p, 'spindle_dur_std', defaults.spindle_dur_std, @(x) validateattributes(x, {'numeric'}, {'real','scalar','positive'}));
addParameter(p, 'spindle_baseline_rate', defaults.spindle_baseline_rate, @(x) validateattributes(x, {'numeric'}, {'real','scalar','positive'}));
addParameter(p, 'modulation_factor', defaults.modulation_factor, @(x) validateattributes(x, {'numeric'}, {'real','scalar','positive'}));
addParameter(p, 'spindle_min_separation', defaults.spindle_min_separation, @(x) validateattributes(x, {'numeric'}, {'real','scalar','positive'}));

% Parse inputs
parse(p, varargin{:});

% Assign to structure
spindle_opts = p.Results;
end
