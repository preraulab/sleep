function spindle_opts = N2_EEG_sim_spindle_opts(varargin)
% N2_EEG_SIM_SPINDLE_OPTS  Returns a structure containing options for simulating N2 EEG spindles.
%
%   Usage:
%       spindle_opts = N2_EEG_sim_spindle_opts('ParameterName', ParameterValue, ...)
%
%   Input:
%       'ParameterName', ParameterValue - Name-value pairs specifying options for simulating N2 EEG spindles.
%           Valid parameter names and their default values are:
%             'phase_pref'            - Preferred phase angle of the spindle, in radians. (default: 0)
%             'spindle_freq_mean'     - Mean frequency of the spindle, in Hz. (default: 15)
%             'spindle_freq_std'      - Standard deviation of the frequency, in Hz. (default: .125)
%             'spindle_amp_mean'      - Mean amplitude of the spindle, in microvolts. (default: 8)
%             'spindle_amp_std'       - Standard deviation of the amplitude, in microvolts. (default: 0.5)
%             'spindle_dur_mean'      - Mean duration of the spindle, in seconds. (default: 1.5)
%             'spindle_dur_std'       - Standard deviation of the duration, in seconds. (default: 0.25)
%             'spindle_baseline_rate' - Baseline rate of spindles, in Hz. (default: 5/60)
%             'modulation_factor'     - Modulation factor for cosine tuning. (default: 0.6)
%             'ctrl_pts'              - Control points for spline. (default: -3:3:18)
%             'spline_tmax'           - Maximum time for spline. (default: 15)
%             'theta_spline'          - Theta values for spline. (default: [0, -5, 0, 0.5, 0, 0, 0, 0])
%             'tension'               - Tension for spline. (default: 1)
%
%   Output:
%       spindle_opts - A structure containing options for simulating N2 EEG spindles.
%
%   Example:
%       spindle_opts = N2_EEG_sim_spindle_opts('spindle_freq_mean', 12, 'spindle_amp_mean', 5)
%       This returns a structure containing options for simulating N2 EEG spindles with mean frequency 12 Hz and mean amplitude 5 microvolts.
%
%   Copyright 2024 Prerau Laboratory. - http://www.sleepEEG.org
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set default values
defaults.phase_pref = 0;
defaults.modulation_factor = .6;
defaults.spindle_baseline_rate = 5/60;
defaults.spindle_freq_mean = 15;
defaults.spindle_freq_std = .125;
defaults.spindle_amp_mean = 8;
defaults.spindle_amp_std = 0.5;
defaults.spindle_dur_mean = 1.5;
defaults.spindle_dur_std = 0.25;
% defaults.ctrl_pts = -3:3:18;
% defaults.spline_tmax = 15;
% defaults.theta_spline = [0, -5, 0, 0.5, 0, 0, 0, 0];
defaults.tension = 1;

%To add infraslow
defaults.spline_tmax = 60;
defaults.ctrl_pts =         [    -3,     0, 3, 5, 8, 9, 12, 15, 18  45,  50, 55, 65, 85];
defaults.theta_spline = log([  1e-5,  1e-2, 1, 2, 1, 1,  1,  1,  1,  1, 1.5, 1,  1,  1]);

% Create input parser
p = inputParser;

addParameter(p, 'spindle_baseline_rate', defaults.spindle_baseline_rate, @(x) validateattributes(x, {'numeric'}, {'real','scalar','positive'}));
addParameter(p, 'phase_pref', defaults.phase_pref, @(x) validateattributes(x, {'numeric'}, {'real','scalar','>=',-pi,'<=',pi}));
addParameter(p, 'modulation_factor', defaults.modulation_factor, @(x) validateattributes(x, {'numeric'}, {'real','scalar','positive'}));
addParameter(p, 'spindle_freq_mean', defaults.spindle_freq_mean, @(x) validateattributes(x, {'numeric'}, {'real','scalar','positive'}));
addParameter(p, 'spindle_freq_std', defaults.spindle_freq_std, @(x) validateattributes(x, {'numeric'}, {'real','scalar','positive'}));
addParameter(p, 'spindle_amp_mean', defaults.spindle_amp_mean, @(x) validateattributes(x, {'numeric'}, {'real','scalar','positive'}));
addParameter(p, 'spindle_amp_std', defaults.spindle_amp_std, @(x) validateattributes(x, {'numeric'}, {'real','scalar','positive'}));
addParameter(p, 'spindle_dur_mean', defaults.spindle_dur_mean, @(x) validateattributes(x, {'numeric'}, {'real','scalar','positive'}));
addParameter(p, 'spindle_dur_std', defaults.spindle_dur_std, @(x) validateattributes(x, {'numeric'}, {'real','scalar','positive'}));
addParameter(p, 'ctrl_pts', defaults.ctrl_pts, @(x) validateattributes(x, {'numeric'}, {'vector'}));
addParameter(p, 'spline_tmax', defaults.spline_tmax, @(x) validateattributes(x, {'numeric'}, {'real','scalar','positive'}));
addParameter(p, 'tension', defaults.tension, @(x) validateattributes(x, {'numeric'}, {'real','scalar','positive'}));
addParameter(p, 'theta_spline', defaults.theta_spline, @(x) validateattributes(x, {'numeric'}, {'vector'}));

% Parse inputs
parse(p, varargin{:});

% Assign to structure
spindle_opts = p.Results;
end
