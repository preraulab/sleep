function noise_opts = N2_EEG_sim_noise_opts(varargin)
%N2_EEG_SIM_NOISE_OPTS Set options for simulating N2 EEG 1/f noise, line noise, and motion artifacts.
%
%   Usage:
%       noise_opts = N2_EEG_sim_noise_opts('ParameterName', ParameterValue, ...)
%
%   Inputs (default values in parentheses):
%       alpha: double - Exponent for A/f^alpha noise. (Default: 1.5)
%       magnitude: double - Scaling factor for A/f^alpha noise. (Default: 5)
%       artifact_rate: double - Rate of motion artifacts. (Default: [])
%       artifact_amp_mean: double - Mean amplitude of motion artifacts. (Default: [])
%       artifact_amp_std: double - Standard deviation of motion artifact amplitudes. (Default: [])
%       line_noise_types: cell array of strings - Types of line noise ('sin', 'square', 'sawtooth'). (Default: {})
%       line_noise_freqs: vector - Frequencies of line noise components. (Default: [])
%       line_noise_amps: vector - Amplitudes of line noise components. (Default: [])
%
%   Outputs:
%       noise_opts: structure - A structure containing the following fields:
%           aperiodic:
%               alpha: double - Exponent for m/f^alpha noise.
%               magnitude: double - Scaling factor, m, for m/f^alpha noise.
%           artifacts:
%               rate: double - Rate of motion artifacts.
%               amp_mean: double - Mean amplitude of motion artifacts.
%               amp_std: double - Standard deviation of motion artifact amplitudes.
%           line_noise:
%               types: cell array of strings - Types of line noise.
%               freqs: vector - Frequencies of line noise components.
%               amps: vector - Amplitudes of line noise components.
%
%   Example:
%       % Create options for simulating EEG noise with default parameters
%       noise_opts = N2_EEG_sim_noise_opts();
%
%    Copyright 2024 Michael J. Prerau Laboratory. - http://www.sleepEEG.org
% *********************************************************************

% Validation function for line_noise_types
valid_types = {'sin', 'square', 'sawtooth'};
validatePeriodicNoiseType = @(x) iscell(x) && all(ismember(x, valid_types));

parser = inputParser;
parser.addOptional('alpha', 1.5, @(x) validateattributes(x, {'numeric'}, {'nonnegative', 'real', 'scalar'}));
parser.addOptional('magnitude', 5, @(x) validateattributes(x, {'numeric'}, {'nonnegative', 'real', 'scalar'}));

parser.addOptional('artifact_rate', [], @(x) validateattributes(x, {'numeric'}, {'nonnegative', 'real', 'scalar'}));
parser.addOptional('artifact_amp_mean', [], @(x) validateattributes(x, {'numeric'}, {'nonnegative', 'real', 'scalar'}));
parser.addOptional('artifact_amp_std', [], @(x) validateattributes(x, {'numeric'}, {'nonnegative', 'real', 'scalar'}));

parser.addOptional('line_noise_types', {}, validatePeriodicNoiseType);
parser.addOptional('line_noise_freqs', [], @(x) validateattributes(x, {'numeric'}, {'nonnegative', 'real', 'vector'}));
parser.addOptional('line_noise_amps', [], @(x) validateattributes(x, {'numeric'}, {'nonnegative', 'real', 'vector'}));

parser.parse(varargin{:});

noise_opts.aperiodic.alpha = parser.Results.alpha;
noise_opts.aperiodic.magnitude = parser.Results.magnitude;

noise_opts.artifacts.rate = parser.Results.artifact_rate;
noise_opts.artifacts.amp_mean = parser.Results.artifact_amp_mean;
noise_opts.artifacts.amp_std = parser.Results.artifact_amp_std;

noise_opts.line_noise.types = parser.Results.line_noise_types;
noise_opts.line_noise.freqs = parser.Results.line_noise_freqs;
noise_opts.line_noise.amps = parser.Results.line_noise_amps;

assert(length(noise_opts.line_noise.freqs)==length(noise_opts.line_noise.amps) && length(noise_opts.line_noise.freqs) == length(noise_opts.line_noise.types),...
    'Line noise type, frequency, and amplitude vectors must be of the same length');

if ~isempty(noise_opts.artifacts.rate)
    assert(~isempty(noise_opts.artifacts.amp_mean) && ~isempty(noise_opts.artifacts.amp_std),'Motion artifacts must have a declared ampltude mean and SD')
end

end
