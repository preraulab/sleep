function noise_opts = N2_EEG_sim_noise_opts(varargin)
%N2_EEG_SIM_NOISE_OPTS Set options for simulating N2 EEG noise
%
%   noise_opts = N2_EEG_sim_noise_opts('alpha_exp', alpha_exp, 'noise_factor', noise_factor)
%
%   Inputs (default values in parentheses):
%       - alpha_exp: exponent for 1/f^alpha noise (1.5)
%       - noise_factor: scaling factor for 1/f^alpha noise (3)
%
%   Outputs:
%       - noise_opts: structure with fields for each input
%
%    Copyright 2024 Michael J. Prerau Laboratory. - http://www.sleepEEG.org

parser = inputParser;
parser.addParameter('alpha_exp', 1.5, @(x) validateattributes(x, {'numeric'}, {'nonnegative', 'real', 'scalar'}));
parser.addParameter('noise_factor', 3, @(x) validateattributes(x, {'numeric'}, {'nonnegative', 'real', 'scalar'}));
parser.parse(varargin{:});

noise_opts.alpha_exp = parser.Results.alpha_exp;
noise_opts.noise_factor = parser.Results.noise_factor;

end
