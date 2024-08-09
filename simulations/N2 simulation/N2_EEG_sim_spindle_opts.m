function spindle_opts = N2_EEG_sim_spindle_opts(varargin)
% N2_EEG_SIM_SPINDLE_OPTS  Returns a structure containing options for simulating N2 EEG spindles.
%
%   Usage:
%       spindle_opts = N2_EEG_sim_spindle_opts('ParameterName', ParameterValue, ...)
%
%   Inputs (default values in parentheses):
%       phase_pref: double - Preferred phase angle of the spindle, in radians. (Default: 0)
%       spindle_freq_mean: double - Mean frequency of the spindle, in Hz. (Default: 15)
%       spindle_freq_std: double - Standard deviation of the frequency, in Hz. (Default: 0.125)
%       spindle_amp_mean: double - Mean amplitude of the spindle, in microvolts. (Default: 8)
%       spindle_amp_std: double - Standard deviation of the amplitude, in microvolts. (Default: 0.5)
%       spindle_dur_mean: double - Mean duration of the spindle, in seconds. (Default: 1.5)
%       spindle_dur_std: double - Standard deviation of the duration, in seconds. (Default: 0.25)
%       spindle_baseline_rate: double - Baseline rate of spindles, in Hz. (Default: 5/60)
%       modulation_factor: double - Modulation factor for cosine tuning. (Default: 0.6)
%       ctrl_pts: numeric vector - Control points for spline. (Default: [-3, 0, 3, 5, 8, 9, 12, 15, 18, 45, 50, 55, 65, 85])
%       spline_tmax: double - Maximum time for spline. (Default: 60)
%       theta_spline: numeric vector - Theta values for spline. (Default: [0, -5, 0, 0.5, 0, 0, 0, 0])
%       tension: double - Tension for spline. (Default: 1)
%
%   Outputs:
%       spindle_opts: structure - A structure containing options for simulating N2 EEG spindles.
%
%   Example:
%       % Create options for simulating EEG spindles with specific parameters
%       spindle_opts = N2_EEG_sim_spindle_opts('spindle_freq_mean', 12, 'spindle_amp_mean', 5);
%
%    Copyright 2024 Prerau Laboratory. - http://www.sleepEEG.org
% *********************************************************************

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
