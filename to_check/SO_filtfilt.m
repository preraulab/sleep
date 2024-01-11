function filtdata = SO_filtfilt(data,Fs)

switch Fs
    case 200
        load SO_filter_200Hz;
    otherwise
        SO_filter = designfilt('bandpassfir', 'StopbandFrequency1', .1, 'PassbandFrequency1', .3, 'PassbandFrequency2', 1.5, 'StopbandFrequency2', 1.8,...
            'StopbandAttenuation1', 60, 'PassbandRipple', 1, 'StopbandAttenuation2', 60, 'SampleRate', Fs);
end

%Filter the data and return result
filtdata=filtfilt(SO_filter,data);
% [EOF]
