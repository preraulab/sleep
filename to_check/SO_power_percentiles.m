function [SO_ptiles_processed, SO_power_rmartifacts, stimes] = ...
    SO_power_percentiles(data, Fs, norm_percentiles, num_std, units, SO_freq_range, taper_params, window_params, min_NFFT, detrend_opt, ploton_MTS, verbose_MTS);
%SW_PERCENTILES_ARTIFACT_REJECTED Remove slow wave artifacts and compute
%percentiles on the slow wave power
%
%   Usage:
%   processed_ptiles = SW_percentiles_artifact_rejected(eeg_data, Fs, percentiles, num_std, units)
%
%   Input:
%   eegdata: 1x<samples> double vector of EEG time domain data
%   Fs: double, sampling frequency
%   percentiles: 1x2 double vector of percentiles to return (default: [1 99])
%   num_std: double, number of standard deviations for threshold (default: 3);
%   units: string, units for percentiles 'dB','sqrt','none' (default: 'dB');
%
%   Output:
%   processed_ptiles: 1x2 double vector of processed percentiles
%
%   Copyright 2024 Michael J. Prerau, Ph.D.
%
%   Last modified 09/13/2018
%********************************************************************

%Set defaults
if nargin<3
    norm_percentiles=[1 99];
end

if nargin<4
    num_std=3;
end

if nargin<5
    units='db';
end

if nargin<6
    SO_freq_range = [.3 1.5];
end

if nargin<7
    taper_params = [15 29];
end

if nargin<8
    window_params = [30 15];
end

switch lower(units)
    case 'db'
        uval=1;
    case {'absolute', 'none'}
        uval=0;
    case 'sqrt'
        uval=2;
    otherwise
        warning('Invalid unit selected. Use ''dB'', ''sqrt'', or ''none''');
end

%Transform the data to be positive and sqrt
% sqdata=sqrt(abs(quickbandpass(eeg_data,Fs,[30 min(55, floor(Fs/2)-1)])));
sqdata = sqrt(abs(data));

%Look for places with invalid data
isdataartifact = isnan(sqdata) | isinf(sqdata);

%Look for large runs of 0, for unhooked EEG
[~,inds] = consecutive(sqdata == 0, 10);

for ii = 1:length(inds)
    isdataartifact(inds{ii}) = true;
end

%Get rid of very very large artifacts
prethresh = nanmedian(sqdata) + 10*std(sqdata);
isgiantartifact = sqdata > prethresh;
isdataartifact(isgiantartifact) = true;

%Threshold
thresh = fast_prctile(sqdata(~isdataartifact), 50) + num_std*std(sqdata(~isdataartifact));

%Find the data above the threshold
isartifact = isdataartifact | sqdata>thresh;

%Compute the spectrogram with artifacts removed
data_noartifact = data;
data_noartifact(isartifact) = nan;

[spect, stimes, sfreqs] = ...
    multitaper_spectrogram_mex(data_noartifact,Fs,SO_freq_range, taper_params, window_params, min_NFFT, detrend_opt, [], false, false, true);
df = sfreqs(2)-sfreqs(1);

%Fix bad values
spect(isinf(spect)) = nan;

%Compute the total power
SO_power_rmartifacts = real(sum(spect,2))*df;
bad_inds=isnan(SO_power_rmartifacts) | isinf(SO_power_rmartifacts) | SO_power_rmartifacts <= 0;

if uval==1
    SO_power_rmartifacts(~bad_inds) = pow2db(SO_power_rmartifacts(~bad_inds));
elseif uval==2
    SO_power_rmartifacts(~bad_inds) = sqrt(SO_power_rmartifacts(~bad_inds));
end

%Return the processed percentiles
SO_ptiles_processed = fast_prctile(SO_power_rmartifacts(~bad_inds),norm_percentiles);
