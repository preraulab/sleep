function noise_opts = N2_EEG_sim_noise_opts(varargin)
%N2_EEG_SIM_NOISE_OPTS Set options for simulating N2 EEG 1/f noise and motion artifacts
%
%   Usage:
%       noise_opts = N2_EEG_sim_noise_opts('ParameterName', ParameterValue, ...)
%
%   Input:
%       'ParameterName', ParameterValue - Name-value pairs specifying options for simulating N2 EEG 1/f noise and motion artifacts.
%           Valid parameter names and their default values are:
%             'alpha_exp'          - Exponent for A/f^alpha noise. (default: 1.5)
%             'noise_factor'       - Scaling factor for A/f^alpha noise. (default: 5)
%             'artifact_rate'      - Rate of artifacts. (default: 0)
%             'artifact_amp_mean'  - Mean amplitude of artifacts. (default: 600)
%             'artifact_amp_std'   - Standard deviation of artifact amplitudes. (default: 60)
%
%   Output:
%       noise_opts - A structure containing options for simulating N2 EEG 1/f noise and motion artifacts.
%
%   Example:
%       % Create options for simulating EEG noise with default parameters
%       noise_opts = N2_EEG_sim_noise_opts();
%
%   Copyright 2024 Michael J. Prerau Laboratory. - http://www.sleepEEG.org
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parser = inputParser;
parser.addParameter('alpha_exp', 1.5, @(x) validateattributes(x, {'numeric'}, {'nonnegative', 'real', 'scalar'}));
parser.addParameter('noise_factor', 5, @(x) validateattributes(x, {'numeric'}, {'nonnegative', 'real', 'scalar'}));
parser.addParameter('artifact_rate', 0, @(x) validateattributes(x, {'numeric'}, {'nonnegative', 'real', 'scalar'}));
parser.addParameter('artifact_amp_mean', 600, @(x) validateattributes(x, {'numeric'}, {'nonnegative', 'real', 'scalar'}));
parser.addParameter('artifact_amp_std', 60, @(x) validateattributes(x, {'numeric'}, {'nonnegative', 'real', 'scalar'}));
parser.parse(varargin{:});

noise_opts.alpha_exp = parser.Results.alpha_exp;
noise_opts.noise_factor = parser.Results.noise_factor;
noise_opts.artifact_rate = parser.Results.artifact_rate;
noise_opts.artifact_amp_mean = parser.Results.artifact_amp_mean;
noise_opts.artifact_amp_std = parser.Results.artifact_amp_std;

