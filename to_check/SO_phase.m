function [phase, amp, filt_data] = SO_phase(data,Fs)

%Filter the data
filt_data=SO_filtfilt(data,Fs);

hilbert_transform = hilbert(filt_data);

phase = angle(hilbert_transform);

if nargout == 2
    amp = abs(hilbert_transform);
end