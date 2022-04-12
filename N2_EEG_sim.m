function signal = N2_EEG_sim(Fs, T)
if nargin == 0
    Fs = 200;
    T = 60*3;
end

%Total number of time points
N = T*Fs;

%% Generate spindles
spindles = zeros(1,N);

%Set spindle rate (events/minute) to be lambda of a Poisson process
spindle_rate = 15; 
%Generate Poisson events
spindle_times = find(poissrnd(spindle_rate/60/Fs, 1, N));
%Set min spacing between events
spindle_min_separation = 3;

%Loop through all events and generate spindles
for ii = 1:length(spindle_times)
    %Check for overlap
    if ii>1 && (spindle_times(ii) - spindle_times(ii-1))/Fs > spindle_min_separation
        
        %Simulate spindle waveform
        spindle_duration = rand*1.5 + .5;
        spindle_amp = rand + 5;
        spindle_freq = 15 + randn*.3;
        
        sp_t = linspace(0,spindle_duration,spindle_duration*Fs);
        spindle = sin(2*pi*sp_t*spindle_freq) .* hanning(length(sp_t))'*spindle_amp;
        
        %Add spindle to time series
        inds = spindle_times(ii):min((spindle_times(ii)+length(spindle)-1), N);
        spindles(inds) = spindles(inds) + spindle(1:length(inds));
    end
end

%% Generate K-Complexes
K_complexes = zeros(1,N);

%Set KC rate (events/minute) to be lambda of a Poisson process
kc_rate = 30;
%Generate Poisson events
kc_times = find(poissrnd(kc_rate/60/Fs, 1, N));
%Set min spacing between events
kc_min_separation = 2;

%Loop through all events and generate KCs
for ii = 1:length(kc_times)
    
    %Check for overlap
    if ii>1 && (kc_times(ii) - kc_times(ii-1))/Fs > kc_min_separation
        
        %Simulate KC waveform
        kc_duration = 2;
        kc_amp = 10*(rand + .5);
        kc_t = linspace(0,kc_duration,kc_duration*Fs);
        
        kc = sin(.75*2*pi*kc_t) .* hanning(length(kc_t))'*kc_amp;
        
        %Add KC to time series
        inds = kc_times(ii):min((kc_times(ii)+length(kc)-1), N);
        K_complexes(inds) = K_complexes(inds) + kc(1:length(inds));
    end
end

%% Generate "slow" and "delta" waveforms by spline interpolation 

%Create low-res random ~1Hz noise
slow_rnd = randn(1,N/60/Fs*120)*2;
slow_rnd([1 end]) = 0; %Keep spline well-behaved

%Interpolate the noise to make a slow component
slow = interp1(linspace(1,N,length(slow_rnd)),slow_rnd,1:N,'spline');


%Create low-res random ~1Hz noise
delta_rnd = randn(1,N/60/Fs*120*5)*1;
delta_rnd([1 end]) = 0; %Keep spline well-behaved

%Interpolate the noise to make a slow component
delta = interp1(linspace(1,N,length(delta_rnd)),delta_rnd,1:N,'spline');

%% Generate colored noise
%1/f^alpha
alpha_exp = 1.5;

cn = dsp.ColoredNoise('pink','SamplesPerFrame',N, 'InverseFrequencyPower', alpha_exp);
noise = cn();

%Create signal and zero mean
signal = spindles + K_complexes + slow + delta + noise';
signal = signal - mean(signal);

%% Plot signal
figure
multitaper_spectrogram_mex(signal, Fs, [.5 35],[2 3], [1.5 .05]);climscale; colormap(jet);
end