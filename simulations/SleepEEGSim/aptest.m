%Create basic figure components
[UIFigure, TabGroup, SimulationOptionsMenu, PlotButton, PlotSimulationMenu, PlotComponentsMenu,...
    PlotSpectrumMenu, SetActiveComponentsMenu, ResimulateMenu, AddComponentMenu, AperiodicMenu, SlowWavesMenu, ...
    SpindlesMenu, LineNoiseMenu, OscillatorMenu, ArtifactsMenu, RemoveComponentMenu]   = createFigureComponents(obj);

% Create AperiodicEEGTab
if ~isempty(obj.Aperiodic)
    [AperiodicEEGTab, Aperiodic_MagnitudeEditField, Aperiodic_AlphaEditField, Aperiodic_UIAxes] = createAperiodicTab(TabGroup, obj);
end


% Create SlowWavesTab
if ~isempty(obj.Slow_Waves)
    [SlowWavesTab, SlowWaves_AmpMeanEditField, SlowWaves_AmpSDEditField, SlowWaves_DurMeanEditField, SlowWaves_DurSDEditField, SlowWaves_RateEditField] = ...
        createSlowWavesTab(TabGroup, obj);
end

% Create SpindleTab
if ~isempty(obj.SpindleSets)
    for ss = 1:length(obj.SpindleSets)
        [SpindlesTab(ss), Spindles_UIAxes(ss), Spindles_FreqSDEditField(ss), Spindles_AmpMeanEditField(ss), Spindles_AmpSDEditField(ss), Spindles_FreqMeanEditField(ss), ...
            Spindles_DurMeanEditField(ss), Spindles_DurSDEditField(ss),Spindles_DurMinEditField(ss), Spindles_BaselineRateEditField(ss), Spindles_StartTimeEditField(ss), Spindles_ModulationFactEditField(ss), ...
            Spindles_PhasePrefEditField(ss), Spindles_MaxTimeEditField(ss), Spindles_TensionEditField(ss), Spindles_ControlPointsEditField(ss), ...
            Spindles_SplineValueEditField(ss), Spindles_AmpMinEditField(ss)] = ...
            createSpindlesTab(TabGroup, obj, ss);
    end
end

% Create OscillatorTab
if ~isempty(obj.OscillatorSets)
    for osc_num = 1:length(obj.OscillatorSets)
        [OscillatorTab(osc_num), Oscillator_UIAxes(osc_num), Oscillator_FreqEditField(osc_num), Oscillator_StateNoiseEditField(osc_num), ...
            Oscillator_ObsNoiseEditField(osc_num), Oscillator_DampingFactorEditField(osc_num), Oscillator_AmpMultEditField(osc_num)] = ...
            createOscillatorTab(TabGroup, obj, osc_num);
    end
end

% Create LineNoiseTab
if ~isempty(obj.LineNoiseSets)
    for ln_num = 1:length(obj.LineNoiseSets)
        [LineNoiseTab(ln_num), LineNoise_UIAxes(ln_num), LineNoise_FreqEditField(ln_num), LineNoise_AmpEditField(ln_num), LineNoise_WaveformDropDown(ln_num)] = ...
            createLineNoiseTab(TabGroup, obj, ln_num);
    end
end

% Create ArtifactsTab
if ~isempty(obj.Artifacts)
    [Artifacts_AmpMeanEditField, Artifacts_AmpSDEditField, Artifacts_AmpMinEditField, Artifacts_RateEditField] = createArtifactsTab(TabGroup, obj);
end


% Show the figure after aln_num components are created
UIFigure.Visible = 'on';

function updateAperiodic(~,~,obj, Aperiodic_AlphaEditField, Aperiodic_MagnitudeEditField, Aperiodic_UIAxes)
obj.Aperiodic.Alpha = Aperiodic_AlphaEditField.Value;
obj.Aperiodic.Magnitude = Aperiodic_MagnitudeEditField.Value;

f = linspace(0,60);
p = Aperiodic_MagnitudeEditField.Value./(f.^Aperiodic_AlphaEditField.Value);
plot(Aperiodic_UIAxes,f,pow2db(p),'linewidth',2)
end

function updateSlowWaves(~,~,obj, ratefield, ampmeanfield, ampsdfield, durmeanfield, dursdfield)
obj.Slow_Waves.Rate = ratefield.Value;
obj.Slow_Waves.Amp_mean = ampmeanfield.Value;
obj.Slow_Waves.Amp_sd = ampsdfield.Value;
obj.Slow_Waves.Dur_mean = durmeanfield.Value;
obj.Slow_Waves.Dur_sd = dursdfield.Value;
end

function updateArtifacts(~,~,obj, ratefield, ampmeanfield, ampsdfield, ampminfield)
obj.Artifacts.Rate = ratefield.Value;
obj.Artifacts.Amp_mean = ampmeanfield.Value;
obj.Artifacts.Amp_sd = ampsdfield.Value;
obj.Artifacts.Amp_min = ampminfield.Value;
end

function updateSpindles(~,~,obj, ss, SpindlesTab,...
    Spindles_UIAxes, Spindles_FreqSDEditField, Spindles_AmpMeanEditField, ...
    Spindles_AmpSDEditField, Spindles_FreqMeanEditField, Spindles_DurMeanEditField, ...
    Spindles_DurSDEditField, Spindles_BaselineRateEditField, Spindles_StartTimeEditField, ...
    Spindles_ModulationFactEditField, Spindles_PhasePrefEditField, Spindles_MaxTimeEditField, ...
    Spindles_TensionEditField, Spindles_ControlPointsEditField, Spindles_SplineValueEditField, ...
    Spindles_AmpMinEditField, Spindles_DurMinEditField)

obj.SpindleSets(ss).Freq_sd = Spindles_FreqSDEditField.Value;
obj.SpindleSets(ss).Amp_mean = Spindles_AmpMeanEditField.Value;
obj.SpindleSets(ss).Amp_sd = Spindles_AmpSDEditField.Value;
obj.SpindleSets(ss).Freq_mean = Spindles_FreqMeanEditField.Value;
obj.SpindleSets(ss).Dur_mean = Spindles_DurMeanEditField.Value;
obj.SpindleSets(ss).Dur_sd = Spindles_DurSDEditField.Value;
obj.SpindleSets(ss).Baseline_rate = Spindles_BaselineRateEditField.Value;
obj.SpindleSets(ss).Start_time = Spindles_StartTimeEditField.Value;
obj.SpindleSets(ss).Modulation_factor = Spindles_ModulationFactEditField.Value;
obj.SpindleSets(ss).Phase_pref = eval(Spindles_PhasePrefEditField.Value);
obj.SpindleSets(ss).Spline_tmax = Spindles_MaxTimeEditField.Value;
obj.SpindleSets(ss).Tension = Spindles_TensionEditField.Value;
obj.SpindleSets(ss).Ctrl_pts = eval(Spindles_ControlPointsEditField.Value);
obj.SpindleSets(ss).Theta_spline = eval(Spindles_SplineValueEditField.Value);
obj.SpindleSets(ss).Amp_min = Spindles_AmpMinEditField.Value;
obj.SpindleSets(ss).Dur_min = Spindles_DurMinEditField.Value;

obj.SpindleSets(ss).genS;
obj.SpindleSets(ss).plot_spline(Spindles_UIAxes,'linewidth',2);
SpindlesTab.Title = ['Spindles ' num2str(obj.SpindleSets(ss).Freq_mean) 'Hz'];
end

function updateLineNoise(~,~,obj, ln_num, LineNoiseTab, LineNoise_FreqEditField, LineNoise_AmpEditField, LineNoise_WaveformDropDown, LineNoise_UIAxes)
obj.LineNoiseSets(ln_num).Freq = LineNoise_FreqEditField.Value;
obj.LineNoiseSets(ln_num).Amp = LineNoise_AmpEditField.Value;
obj.LineNoiseSets(ln_num).Waveform = LineNoise_WaveformDropDown.Value;

LineNoiseTab.Title = ['Line Noise ' obj.LineNoiseSets(ln_num).Waveform ' ' num2str(obj.LineNoiseSets(ln_num).Freq) 'Hz' ];

f  = obj.LineNoiseSets(ln_num).Freq;
a = obj.LineNoiseSets(ln_num).Amp ;

Fs = max(500, f*2);
t = 0:(1/Fs):1; %Plot 1s of data

switch obj.LineNoiseSets(ln_num).Waveform
    case 'sin'
        ln_fun = @sin;
    case 'sawtooth'
        ln_fun = @sawtooth;
    case 'square'
        ln_fun = @square;
    otherwise
        error('Invalid line noise function type. Options are sin, square, and sawtooth');
end

y  = a * ln_fun(2 * pi * t * f);

plot(LineNoise_UIAxes, t, y);
end

function updateOscillator(~,~,obj, o_num, OscillatorTab, Oscillator_FreqEditField, Oscillator_StateNoiseEditField, Oscillator_ObsNoiseEditField, Oscillator_DampingFactorEditField, Oscillator_AmpMultEditField, Oscillator_UIAxes)
obj.OscillatorSets(o_num).Freq= Oscillator_FreqEditField.Value;
obj.OscillatorSets(o_num).StateNoise= Oscillator_StateNoiseEditField.Value;
obj.OscillatorSets(o_num).ObsNoise= Oscillator_ObsNoiseEditField.Value;
obj.OscillatorSets(o_num).DampingFactor= Oscillator_DampingFactorEditField.Value;
obj.OscillatorSets(o_num).AmpMult= Oscillator_AmpMultEditField.Value;

OscillatorTab.Title = ['Oscillator ' num2str(obj.OscillatorSets(o_num).Freq) 'Hz' ];

f  = obj.OscillatorSets(o_num).Freq;

Fs = max(500, f*2);

t = 0:(1/Fs):1; %Plot 1s of data

%Save signal
o_sig = obj.OscillatorSets(o_num).Signal;

%Simulate a short signal
y = obj.OscillatorSets(o_num).sim(t);

%Restore old signal
obj.OscillatorSets(o_num).Signal = o_sig;

%Plot
plot(Oscillator_UIAxes, t, y);
end


function [AperiodicEEGTab, Aperiodic_MagnitudeEditField, Aperiodic_AlphaEditField, Aperiodic_UIAxes] = createAperiodicTab(TabGroup, obj)
AperiodicEEGTab = uitab(TabGroup);
AperiodicEEGTab.Title = 'Aperiodic EEG';

% Create MagnitudeEditFieldLabel
Aperiodic_MagnitudeEditFieldLabel = uilabel(AperiodicEEGTab);
Aperiodic_MagnitudeEditFieldLabel.HorizontalAlignment = 'right';
Aperiodic_MagnitudeEditFieldLabel.Position = [20 345 62 22];
Aperiodic_MagnitudeEditFieldLabel.Text = 'Magnitude';

% Create Aperiodic_MagnitudeEditField
Aperiodic_MagnitudeEditField = uieditfield(AperiodicEEGTab, 'numeric');
Aperiodic_MagnitudeEditField.Position = [123 345 103 22];

% Create AlphaEditFieldLabel
Aperiodic_AlphaEditFieldLabel = uilabel(AperiodicEEGTab);
Aperiodic_AlphaEditFieldLabel.HorizontalAlignment = 'right';
Aperiodic_AlphaEditFieldLabel.Position = [18 377 64 22];
Aperiodic_AlphaEditFieldLabel.Text = 'Alpha';

% Create Aperiodic_AlphaEditField
Aperiodic_AlphaEditField = uieditfield(AperiodicEEGTab, 'numeric');
Aperiodic_AlphaEditField.Position = [123 377 103 22];

% Create Aperiodic_UIAxes
Aperiodic_UIAxes = uiaxes(AperiodicEEGTab);
title(Aperiodic_UIAxes, 'Aperiodic EEG')
xlabel(Aperiodic_UIAxes, 'Frequency (Hz)')
ylabel(Aperiodic_UIAxes, 'Power (dB)')
Aperiodic_UIAxes.Position = [250 12 680 412];

[Aperiodic_AlphaEditField, Aperiodic_MagnitudeEditField] = fillAperiodic(Aperiodic_AlphaEditField, Aperiodic_MagnitudeEditField, Aperiodic_UIAxes, obj);

aperiodicCallback =  {@updateAperiodic, obj, Aperiodic_AlphaEditField, Aperiodic_MagnitudeEditField, Aperiodic_UIAxes};
Aperiodic_AlphaEditField.ValueChangedFcn = aperiodicCallback;
Aperiodic_MagnitudeEditField.ValueChangedFcn = aperiodicCallback;
end

function [SlowWavesTab, SlowWaves_AmpMeanEditField, SlowWaves_AmpSDEditField, SlowWaves_DurMeanEditField, ...
    SlowWaves_DurSDEditField, SlowWaves_RateEditField] = createSlowWavesTab(TabGroup, obj)
SlowWavesTab = uitab(TabGroup);
SlowWavesTab.Title = 'Slow Waves';

% Create AmpMeanEditFieldLabel
SlowWaves_AmpMeanEditFieldLabel = uilabel(SlowWavesTab);
SlowWaves_AmpMeanEditFieldLabel.HorizontalAlignment = 'right';
SlowWaves_AmpMeanEditFieldLabel.Position = [15 345 67 22];
SlowWaves_AmpMeanEditFieldLabel.Text = 'Amp. Mean';

% Create SlowWaves_AmpMeanEditField
SlowWaves_AmpMeanEditField = uieditfield(SlowWavesTab, 'numeric');
SlowWaves_AmpMeanEditField.Position = [123 345 103 22];

% Create AmpSDEditFieldLabel
SlowWaves_AmpSDEditFieldLabel = uilabel(SlowWavesTab);
SlowWaves_AmpSDEditFieldLabel.HorizontalAlignment = 'right';
SlowWaves_AmpSDEditFieldLabel.Position = [29 313 53 22];
SlowWaves_AmpSDEditFieldLabel.Text = 'Amp. SD';

% Create SlowWaves_AmpSDEditField
SlowWaves_AmpSDEditField = uieditfield(SlowWavesTab, 'numeric');
SlowWaves_AmpSDEditField.Position = [123 313 103 22];

% Create DurMeanEditFieldLabel
SlowWaves_DurMeanEditFieldLabel = uilabel(SlowWavesTab);
SlowWaves_DurMeanEditFieldLabel.HorizontalAlignment = 'right';
SlowWaves_DurMeanEditFieldLabel.Position = [22 278 60 22];
SlowWaves_DurMeanEditFieldLabel.Text = 'Dur. Mean';

% Create SlowWaves_DurMeanEditField
SlowWaves_DurMeanEditField = uieditfield(SlowWavesTab, 'numeric');
SlowWaves_DurMeanEditField.Position = [123 278 103 22];

% Create DurSDEditFieldLabel
SlowWaves_DurSDEditFieldLabel = uilabel(SlowWavesTab);
SlowWaves_DurSDEditFieldLabel.HorizontalAlignment = 'right';
SlowWaves_DurSDEditFieldLabel.Position = [36 246 46 22];
SlowWaves_DurSDEditFieldLabel.Text = 'Dur. SD';

% Create SlowWaves_DurSDEditField
SlowWaves_DurSDEditField = uieditfield(SlowWavesTab, 'numeric');
SlowWaves_DurSDEditField.Position = [123 246 103 22];

% Create RateEditFieldLabel
SlowWaves_RateEditFieldLabel = uilabel(SlowWavesTab);
SlowWaves_RateEditFieldLabel.HorizontalAlignment = 'right';
SlowWaves_RateEditFieldLabel.Position = [18 377 64 22];
SlowWaves_RateEditFieldLabel.Text = 'Rate';

% Create SlowWaves_RateEditField
SlowWaves_RateEditField = uieditfield(SlowWavesTab, 'numeric');
SlowWaves_RateEditField.Position = [123 377 103 22];


[SlowWaves_RateEditField, SlowWaves_AmpMeanEditField, SlowWaves_AmpSDEditField, SlowWaves_DurMeanEditField, SlowWaves_DurSDEditField] = fillSlowWaves(SlowWaves_RateEditField, SlowWaves_AmpMeanEditField, SlowWaves_AmpSDEditField, SlowWaves_DurMeanEditField, SlowWaves_DurSDEditField, obj);


SWCallback = {@updateSlowWaves, obj, SlowWaves_RateEditField, SlowWaves_AmpMeanEditField, SlowWaves_AmpSDEditField, SlowWaves_DurMeanEditField, SlowWaves_DurSDEditField};

SlowWaves_RateEditField.ValueChangedFcn = SWCallback;
SlowWaves_AmpSDEditField.ValueChangedFcn = SWCallback;
SlowWaves_AmpMeanEditField.ValueChangedFcn = SWCallback;
SlowWaves_DurSDEditField.ValueChangedFcn = SWCallback;
SlowWaves_DurMeanEditField.ValueChangedFcn = SWCallback;
end

function [SpindlesTab, Spindles_UIAxes, Spindles_FreqSDEditField, Spindles_AmpMeanEditField, Spindles_AmpSDEditField, ...
    Spindles_FreqMeanEditField, Spindles_DurMeanEditField, Spindles_DurSDEditField,Spindles_DurMinEditField, Spindles_BaselineRateEditField, ...
    Spindles_StartTimeEditField, Spindles_ModulationFactEditField, Spindles_PhasePrefEditField, Spindles_MaxTimeEditField,...
    Spindles_TensionEditField, Spindles_ControlPointsEditField, Spindles_SplineValueEditField, Spindles_AmpMinEditField] = createSpindlesTab(TabGroup, obj,ss)
% Create SpindlesTab
SpindlesTab = uitab(TabGroup);

% Create Spindles_UIAxes
Spindles_UIAxes = uiaxes(SpindlesTab);
title(Spindles_UIAxes, 'History Modulation Curve')
xlabel(Spindles_UIAxes, 'Time Since Last Spindle (s)')
ylabel(Spindles_UIAxes, 'Modulation Factor')
Spindles_UIAxes.Position = [295 97 625 332];

% Create Spindles_FreqSDEditFieldLabel
Spindles_FreqSDEditFieldLabel = uilabel(SpindlesTab);
Spindles_FreqSDEditFieldLabel.HorizontalAlignment = 'right';
Spindles_FreqSDEditFieldLabel.Position = [47 378 52 22];
Spindles_FreqSDEditFieldLabel.Text = 'Freq. SD';

% Create Spindles_FreqSDEditField
Spindles_FreqSDEditField = uieditfield(SpindlesTab, 'numeric');
Spindles_FreqSDEditField.Position = [140 378 103 22];

% Create Spindles_AmpMeanEditFieldLabel
Spindles_AmpMeanEditFieldLabel = uilabel(SpindlesTab);
Spindles_AmpMeanEditFieldLabel.HorizontalAlignment = 'right';
Spindles_AmpMeanEditFieldLabel.Position = [32 346 67 22];
Spindles_AmpMeanEditFieldLabel.Text = 'Amp. Mean';

% Create Spindles_AmpMeanEditField
Spindles_AmpMeanEditField = uieditfield(SpindlesTab, 'numeric');
Spindles_AmpMeanEditField.Position = [140 346 103 22];

% Create Spindles_AmpSDEditFieldLabel
Spindles_AmpSDEditFieldLabel = uilabel(SpindlesTab);
Spindles_AmpSDEditFieldLabel.HorizontalAlignment = 'right';
Spindles_AmpSDEditFieldLabel.Position = [46 311 53 22];
Spindles_AmpSDEditFieldLabel.Text = 'Amp. SD';

% Create Spindles_AmpSDEditField
Spindles_AmpSDEditField = uieditfield(SpindlesTab, 'numeric');
Spindles_AmpSDEditField.Position = [140 311 103 22];

% Create Spindles_FreqMeanEditFieldLabel
Spindles_FreqMeanEditFieldLabel = uilabel(SpindlesTab);
Spindles_FreqMeanEditFieldLabel.HorizontalAlignment = 'right';
Spindles_FreqMeanEditFieldLabel.Position = [33 410 66 22];
Spindles_FreqMeanEditFieldLabel.Text = 'Freq. Mean';

% Create Spindles_FreqMeanEditField
Spindles_FreqMeanEditField = uieditfield(SpindlesTab, 'numeric');
Spindles_FreqMeanEditField.Position = [140 410 103 22];

% Create Spindles_DurMeanEditFieldLabel
Spindles_DurMeanEditFieldLabel = uilabel(SpindlesTab);
Spindles_DurMeanEditFieldLabel.HorizontalAlignment = 'right';
Spindles_DurMeanEditFieldLabel.Position = [40 244 60 22];
Spindles_DurMeanEditFieldLabel.Text = 'Dur. Mean';

% Create Spindles_DurMeanEditField
Spindles_DurMeanEditField = uieditfield(SpindlesTab, 'numeric');
Spindles_DurMeanEditField.Position = [141 244 103 22];

% Create Spindles_DurSDEditFieldLabel
Spindles_DurSDEditFieldLabel = uilabel(SpindlesTab);
Spindles_DurSDEditFieldLabel.HorizontalAlignment = 'right';
Spindles_DurSDEditFieldLabel.Position = [54 209 46 22];
Spindles_DurSDEditFieldLabel.Text = 'Dur. SD';

% Create Spindles_DurSDEditField
Spindles_DurSDEditField = uieditfield(SpindlesTab, 'numeric');
Spindles_DurSDEditField.Position = [141 209 103 22];

% Create Spindles_BaselineRateEditFieldLabel
Spindles_BaselineRateEditFieldLabel = uilabel(SpindlesTab);
Spindles_BaselineRateEditFieldLabel.HorizontalAlignment = 'right';
Spindles_BaselineRateEditFieldLabel.Position = [21 132 79 22];
Spindles_BaselineRateEditFieldLabel.Text = 'Baseline Rate';

% Create Spindles_BaselineRateEditField
Spindles_BaselineRateEditField = uieditfield(SpindlesTab, 'numeric');
Spindles_BaselineRateEditField.Position = [141 132 103 22];

% Create Spindles_StartTimeEditFieldLabel
Spindles_StartTimeEditFieldLabel = uilabel(SpindlesTab);
Spindles_StartTimeEditFieldLabel.HorizontalAlignment = 'right';
Spindles_StartTimeEditFieldLabel.Position = [40 97 60 22];
Spindles_StartTimeEditFieldLabel.Text = 'Start Time';

% Create Spindles_StartTimeEditField
Spindles_StartTimeEditField = uieditfield(SpindlesTab, 'numeric');
Spindles_StartTimeEditField.Position = [141 97 103 22];

% Create Spindles_ModulationFactEditFieldLabel
Spindles_ModulationFactEditFieldLabel = uilabel(SpindlesTab);
Spindles_ModulationFactEditFieldLabel.HorizontalAlignment = 'right';
Spindles_ModulationFactEditFieldLabel.Position = [9 17 95 22];
Spindles_ModulationFactEditFieldLabel.Text = 'Modulation Fact.';

% Create Spindles_ModulationFactEditField
Spindles_ModulationFactEditField = uieditfield(SpindlesTab, 'numeric');
Spindles_ModulationFactEditField.Position = [145 17 103 22];

% Create Spindles_PhasePrefEditFieldLabel
Spindles_PhasePrefEditFieldLabel = uilabel(SpindlesTab);
Spindles_PhasePrefEditFieldLabel.HorizontalAlignment = 'right';
Spindles_PhasePrefEditFieldLabel.Position = [36 49 67 22];
Spindles_PhasePrefEditFieldLabel.Text = 'Phase Pref.';

% Create Spindles_PhasePrefEditField
Spindles_PhasePrefEditField = uieditfield(SpindlesTab, 'text');
Spindles_PhasePrefEditField.Position = [144 49 103 22];
Spindles_PhasePrefEditField.HorizontalAlignment = 'right';

% Create Spindles_MaxTimeEditFieldLabel
Spindles_MaxTimeEditFieldLabel = uilabel(SpindlesTab);
Spindles_MaxTimeEditFieldLabel.HorizontalAlignment = 'right';
Spindles_MaxTimeEditFieldLabel.Position = [706 18 58 22];
Spindles_MaxTimeEditFieldLabel.Text = 'Max Time';

% Create Spindles_MaxTimeEditField
Spindles_MaxTimeEditField = uieditfield(SpindlesTab, 'numeric');
Spindles_MaxTimeEditField.Position = [809 18 103 22];

% Create Spindles_TensionEditFieldLabel
Spindles_TensionEditFieldLabel = uilabel(SpindlesTab);
Spindles_TensionEditFieldLabel.HorizontalAlignment = 'right';
Spindles_TensionEditFieldLabel.Position = [721 49 46 22];
Spindles_TensionEditFieldLabel.Text = 'Tension';

% Create Spindles_TensionEditField
Spindles_TensionEditField = uieditfield(SpindlesTab, 'numeric');
Spindles_TensionEditField.Position = [808 49 103 22];

% Create Spindles_ControlPointsLabel
Spindles_ControlPointsLabel = uilabel(SpindlesTab);
Spindles_ControlPointsLabel.HorizontalAlignment = 'right';
Spindles_ControlPointsLabel.Position = [334 49 85 22];
Spindles_ControlPointsLabel.Text = 'Control Points';

% Create Spindles_ControlPointsEditField
Spindles_ControlPointsEditField = uieditfield(SpindlesTab, 'text');
Spindles_ControlPointsEditField.Position = [434 49 249 22];

% Create Spindles_SplineValueEditFieldLabel
Spindles_SplineValueEditFieldLabel = uilabel(SpindlesTab);
Spindles_SplineValueEditFieldLabel.HorizontalAlignment = 'right';
Spindles_SplineValueEditFieldLabel.Position = [347 18 71 22];
Spindles_SplineValueEditFieldLabel.Text = 'Spline Value';

% Create Spindles_SplineValueEditField
Spindles_SplineValueEditField = uieditfield(SpindlesTab, 'text');
Spindles_SplineValueEditField.Position = [433 18 250 22];

% Create Spindles_AmpMinEditFieldLabel
Spindles_AmpMinEditFieldLabel = uilabel(SpindlesTab);
Spindles_AmpMinEditFieldLabel.HorizontalAlignment = 'right';
Spindles_AmpMinEditFieldLabel.Position = [43 276 57 22];
Spindles_AmpMinEditFieldLabel.Text = 'Amp. Min';

% Create Spindles_AmpMinEditField
Spindles_AmpMinEditField = uieditfield(SpindlesTab, 'numeric');
Spindles_AmpMinEditField.Position = [141 276 103 22];

% Create Spindles_DurMinEditFieldLabel
Spindles_DurMinEditFieldLabel = uilabel(SpindlesTab);
Spindles_DurMinEditFieldLabel.HorizontalAlignment = 'right';
Spindles_DurMinEditFieldLabel.Position = [50 176 49 22];
Spindles_DurMinEditFieldLabel.Text = 'Dur. Min';

% Create Spindles_AmpMinEditField
Spindles_DurMinEditField = uieditfield(SpindlesTab, 'numeric');
Spindles_DurMinEditField.Position = [148   176    95    22];

fillSpindles(Spindles_FreqSDEditField, ss, Spindles_AmpMeanEditField, Spindles_AmpSDEditField, Spindles_FreqMeanEditField, Spindles_DurMeanEditField, ...
    Spindles_DurSDEditField, Spindles_BaselineRateEditField, Spindles_StartTimeEditField, Spindles_ModulationFactEditField, Spindles_PhasePrefEditField, ...
    Spindles_MaxTimeEditField, Spindles_TensionEditField, Spindles_ControlPointsEditField, Spindles_SplineValueEditField, Spindles_AmpMinEditField, Spindles_DurMinEditField, obj);


spindleCallback = {@updateSpindles, obj, ss, SpindlesTab ...
    Spindles_UIAxes, Spindles_FreqSDEditField, Spindles_AmpMeanEditField, ...
    Spindles_AmpSDEditField, Spindles_FreqMeanEditField, Spindles_DurMeanEditField, ...
    Spindles_DurSDEditField, Spindles_BaselineRateEditField, Spindles_StartTimeEditField, ...
    Spindles_ModulationFactEditField, Spindles_PhasePrefEditField, Spindles_MaxTimeEditField, ...
    Spindles_TensionEditField, Spindles_ControlPointsEditField, Spindles_SplineValueEditField, ...
    Spindles_AmpMinEditField, Spindles_DurMinEditField};

Spindles_FreqSDEditField.ValueChangedFcn = spindleCallback;
Spindles_AmpMeanEditField.ValueChangedFcn = spindleCallback;
Spindles_AmpSDEditField.ValueChangedFcn = spindleCallback;
Spindles_FreqMeanEditField.ValueChangedFcn = spindleCallback;
Spindles_DurMeanEditField.ValueChangedFcn = spindleCallback;
Spindles_DurSDEditField.ValueChangedFcn = spindleCallback;
Spindles_BaselineRateEditField.ValueChangedFcn = spindleCallback;
Spindles_StartTimeEditField.ValueChangedFcn = spindleCallback;
Spindles_ModulationFactEditField.ValueChangedFcn = spindleCallback;
Spindles_PhasePrefEditField.ValueChangedFcn = spindleCallback;
Spindles_MaxTimeEditField.ValueChangedFcn = spindleCallback;
Spindles_TensionEditField.ValueChangedFcn = spindleCallback;
Spindles_ControlPointsEditField.ValueChangedFcn = spindleCallback;
Spindles_SplineValueEditField.ValueChangedFcn = spindleCallback;
Spindles_AmpMinEditField.ValueChangedFcn = spindleCallback;
Spindles_DurMinEditField.ValueChangedFcn = spindleCallback; %#ok<*SAGROW>

updateSpindles([],[], obj, ss, SpindlesTab,...
    Spindles_UIAxes, Spindles_FreqSDEditField, Spindles_AmpMeanEditField, ...
    Spindles_AmpSDEditField, Spindles_FreqMeanEditField, Spindles_DurMeanEditField, ...
    Spindles_DurSDEditField, Spindles_BaselineRateEditField, Spindles_StartTimeEditField, ...
    Spindles_ModulationFactEditField, Spindles_PhasePrefEditField, Spindles_MaxTimeEditField, ...
    Spindles_TensionEditField, Spindles_ControlPointsEditField, Spindles_SplineValueEditField, ...
    Spindles_AmpMinEditField, Spindles_DurMinEditField);
end

function  [UIFigure, TabGroup, SimulationOptionsMenu, PlotButton, PlotSimulationMenu, PlotComponentsMenu,...
    PlotSpectrumMenu, SetActiveComponentsMenu, ResimulateMenu, AddComponentMenu, AperiodicMenu, SlowWavesMenu, ...
    SpindlesMenu, LineNoiseMenu, OscillatorMenu, ArtifactsMenu, RemoveComponentMenu] = createFigureComponents(obj)

% Create UIFigure and hide until aln_num components are created
UIFigure = uifigure('Visible', 'off');
UIFigure.AutoResizeChildren = 'off';
UIFigure.Position = [100 100 974 627];
UIFigure.Name = 'SleepEEGSim Components';
UIFigure.Resize = 'off';

% Create TabGroup
TabGroup = uitabgroup(UIFigure);
TabGroup.AutoResizeChildren = 'off';
TabGroup.Position = [9 100 962 500];

% Create PlotButton
PlotButton = uibutton(UIFigure, 'push');
PlotButton.FontSize = 18;
PlotButton.Position = [443 30 121 29];
PlotButton.Text = 'Plot';
PlotButton.ButtonPushedFcn = @(s,e)obj.plot;

% Create SimulationOptionsMenu
SimulationOptionsMenu = uimenu(UIFigure);
SimulationOptionsMenu.Text = 'Simulation Options';

% Create PlotSimulationMenu
PlotSimulationMenu = uimenu(SimulationOptionsMenu);
PlotSimulationMenu.Text = 'Plot Simulation';
PlotSimulationMenu.MenuSelectedFcn = @(s,e)obj.plot;

% Create PlotComponentsMenu
PlotComponentsMenu = uimenu(SimulationOptionsMenu);
PlotComponentsMenu.Text = 'Plot Components';
PlotSimulationMenu.MenuSelectedFcn = @(s,e)obj.plotComponents;

% Create PlotSpectrumMenu
PlotSpectrumMenu = uimenu(SimulationOptionsMenu);
PlotSpectrumMenu.Text = 'Plot Spectrum';
PlotSimulationMenu.MenuSelectedFcn = @(s,e)obj.plotSpect;

% Create SetActiveComponentsMenu
SetActiveComponentsMenu = uimenu(SimulationOptionsMenu);
SetActiveComponentsMenu.Text = 'Set Active Components...';
PlotSimulationMenu.MenuSelectedFcn = @(s,e)obj.setActive;

% Create ResimulateMenu
ResimulateMenu = uimenu(SimulationOptionsMenu);
ResimulateMenu.Text = 'Resimulate';
PlotSimulationMenu.MenuSelectedFcn = @(s,e)obj.sim;

% Create AddComponentMenu
AddComponentMenu = uimenu(SimulationOptionsMenu);
AddComponentMenu.Text = 'Add Component';

% Create AperiodicMenu
AperiodicMenu = uimenu(AddComponentMenu);
AperiodicMenu.Text = 'Aperiodic';


% Create SlowWavesMenu
SlowWavesMenu = uimenu(AddComponentMenu);
SlowWavesMenu.Text = 'Slow Waves';

% Create SpindlesMenu
SpindlesMenu = uimenu(AddComponentMenu);
SpindlesMenu.Text = 'Spindles';

% Create LineNoiseMenu
LineNoiseMenu = uimenu(AddComponentMenu);
LineNoiseMenu.Text = 'Line Noise';

% Create OscillatorMenu
OscillatorMenu = uimenu(AddComponentMenu);
OscillatorMenu.Text = 'Oscillator';

% Create ArtifactsMenu
ArtifactsMenu = uimenu(AddComponentMenu);
ArtifactsMenu.Text = 'Artifacts';

% Create RemoveComponentMenu
RemoveComponentMenu = uimenu(SimulationOptionsMenu);
RemoveComponentMenu.Text = 'Remove Component';
RemoveComponentMenu.MenuSelectedFcn = {@(s,e)removeComponent(obj, TabGroup)};

AperiodicMenu.MenuSelectedFcn = {@(s,e)GUIaddAperiodic(obj, TabGroup)};
SlowWavesMenu.MenuSelectedFcn = {@(s,e)GUIaddSlowWaves(obj, TabGroup)};
ArtifactsMenu.MenuSelectedFcn = {@(s,e)GUIaddArtifacts(obj, TabGroup)};
SpindlesMenu.MenuSelectedFcn = {@(s,e)GUIaddSpindles(obj, TabGroup)};
OscillatorMenu.MenuSelectedFcn = {@(s,e)GUIaddOscillator(obj, TabGroup)};
LineNoiseMenu.MenuSelectedFcn = {@(s,e)GUIaddLineNoise(obj, TabGroup)};
end

function [Artifacts_AmpMeanEditField, Artifacts_AmpSDEditField, Artifacts_AmpMinEditField, Artifacts_RateEditField] = createArtifactsTab(TabGroup, obj)
ArtifactsTab = uitab(TabGroup);
ArtifactsTab.Title = 'Artifacts';

% Create AmpMeanEditFieldLabel
Artifacts_AmpMeanEditFieldLabel = uilabel(ArtifactsTab);
Artifacts_AmpMeanEditFieldLabel.HorizontalAlignment = 'right';
Artifacts_AmpMeanEditFieldLabel.Position = [15 345 67 22];
Artifacts_AmpMeanEditFieldLabel.Text = 'Amp. Mean';

% Create Artifacts_AmpMeanEditField
Artifacts_AmpMeanEditField = uieditfield(ArtifactsTab, 'numeric');
Artifacts_AmpMeanEditField.Position = [123 345 103 22];

% Create AmpSDEditFieldLabel
Artifacts_AmpSDEditFieldLabel = uilabel(ArtifactsTab);
Artifacts_AmpSDEditFieldLabel.HorizontalAlignment = 'right';
Artifacts_AmpSDEditFieldLabel.Position = [29 313 53 22];
Artifacts_AmpSDEditFieldLabel.Text = 'Amp. SD';

% Create Artifacts_AmpSDEditField
Artifacts_AmpSDEditField = uieditfield(ArtifactsTab, 'numeric');
Artifacts_AmpSDEditField.Position = [123 313 103 22];

% Create AmpMinEditFieldLabel
Artifacts_AmpMinEditFieldLabel = uilabel(ArtifactsTab);
Artifacts_AmpMinEditFieldLabel.HorizontalAlignment = 'right';
Artifacts_AmpMinEditFieldLabel.Position = [25 278 57 22];
Artifacts_AmpMinEditFieldLabel.Text = 'Amp. Min';

% Create Artifacts_AmpMinEditField
Artifacts_AmpMinEditField = uieditfield(ArtifactsTab, 'numeric');
Artifacts_AmpMinEditField.Position = [123 278 103 22];

% Create RateEditFieldLabel
Artifacts_RateEditFieldLabel = uilabel(ArtifactsTab);
Artifacts_RateEditFieldLabel.HorizontalAlignment = 'right';
Artifacts_RateEditFieldLabel.Position = [18 377 64 22];
Artifacts_RateEditFieldLabel.Text = 'Rate';

% Create Artifacts_RateEditField
Artifacts_RateEditField = uieditfield(ArtifactsTab, 'numeric');
Artifacts_RateEditField.Position = [123 377 103 22];

fillArtifacts(Artifacts_AmpMeanEditField, Artifacts_AmpSDEditField, Artifacts_AmpMinEditField, Artifacts_RateEditField, obj);

artCallback =  {@updateArtifacts, obj, Artifacts_RateEditField, Artifacts_AmpMeanEditField, Artifacts_AmpSDEditField, Artifacts_AmpMinEditField};

Artifacts_RateEditField.ValueChangedFcn = artCallback;
Artifacts_AmpMeanEditField.ValueChangedFcn = artCallback;
Artifacts_AmpSDEditField.ValueChangedFcn = artCallback;
Artifacts_AmpMinEditField.ValueChangedFcn = artCallback;
end

function [LineNoiseTab, LineNoise_UIAxes, LineNoise_FreqEditField, LineNoise_AmpEditField, ...
    LineNoise_WaveformDropDown] = createLineNoiseTab(TabGroup, obj, ln_num)

LineNoiseTab = uitab(TabGroup);

% Create UIAxes
LineNoise_UIAxes = uiaxes(LineNoiseTab);
title(LineNoise_UIAxes, 'Line Noise')
xlabel(LineNoise_UIAxes, 'Time (s)')
ylabel(LineNoise_UIAxes, 'Amplitude')
LineNoise_UIAxes.Position = [29 10 917 268];

% Create AmpMeanEditFieldLabel
LineNoise_FreqEditFieldLabel = uilabel(LineNoiseTab);
LineNoise_FreqEditFieldLabel.HorizontalAlignment = 'right';
LineNoise_FreqEditFieldLabel.Position = [21 345 61 22];
LineNoise_FreqEditFieldLabel.Text = 'Freq.';

% Create LineNoise_AmpMeanEditField
LineNoise_FreqEditField = uieditfield(LineNoiseTab, 'numeric');
LineNoise_FreqEditField.Position = [123 345 103 22];

% Create AmpSDEditFieldLabel
LineNoise_AmpEditFieldLabel = uilabel(LineNoiseTab);
LineNoise_AmpEditFieldLabel.HorizontalAlignment = 'right';
LineNoise_AmpEditFieldLabel.Position = [29 313 53 22];
LineNoise_AmpEditFieldLabel.Text = 'Amp.';

% Create LineNoise_AmpSDEditField
LineNoise_AmpEditField = uieditfield(LineNoiseTab, 'numeric');
LineNoise_AmpEditField.Position = [123 313 103 22];

% Create WaveformDropDownLabel
LineNoise_WaveformDropDownLabel = uilabel(LineNoiseTab);
LineNoise_WaveformDropDownLabel.HorizontalAlignment = 'right';
LineNoise_WaveformDropDownLabel.Position = [23 377 59 22];
LineNoise_WaveformDropDownLabel.Text = 'Waveform';

% Create LineNoise_WaveformDropDown
LineNoise_WaveformDropDown = uidropdown(LineNoiseTab);
LineNoise_WaveformDropDown.Items = {'sin', 'sawtooth', 'square'};
LineNoise_WaveformDropDown.Position = [123 377 103 22];
LineNoise_WaveformDropDown.Value = 'sin';

[LineNoise_FreqEditField, LineNoise_AmpEditField, LineNoise_WaveformDropDown] = fillLineNoise(LineNoise_FreqEditField, ln_num, LineNoise_AmpEditField, LineNoise_WaveformDropDown, obj);

linenoiseCallback = {@updateLineNoise, obj, ln_num, LineNoiseTab, LineNoise_FreqEditField, LineNoise_AmpEditField, LineNoise_WaveformDropDown, LineNoise_UIAxes};

LineNoise_FreqEditField.ValueChangedFcn = linenoiseCallback;
LineNoise_AmpEditField.ValueChangedFcn = linenoiseCallback;
LineNoise_WaveformDropDown.ValueChangedFcn = linenoiseCallback;

updateLineNoise([],[],obj, ln_num, LineNoiseTab, LineNoise_FreqEditField, LineNoise_AmpEditField, LineNoise_WaveformDropDown, LineNoise_UIAxes);
end

function [OscillatorTab, Oscillator_UIAxes, Oscillator_FreqEditField, Oscillator_StateNoiseEditField, ...
    Oscillator_ObsNoiseEditField, Oscillator_DampingFactorEditField, Oscillator_AmpMultEditField] = createOscillatorTab(TabGroup, obj, osc_num)

OscillatorTab = uitab(TabGroup);
shift = -32;
% Create UIAxes
Oscillator_UIAxes = uiaxes(OscillatorTab);
title(Oscillator_UIAxes, 'Oscillator')
xlabel(Oscillator_UIAxes, 'Time (s)')
ylabel(Oscillator_UIAxes, 'Amplitude')
Oscillator_UIAxes.Position = [29 10 917 268];

% Create AmpMeanEditFieldLabel
Oscillator_FreqEditFieldLabel = uilabel(OscillatorTab);
Oscillator_FreqEditFieldLabel.HorizontalAlignment = 'right';
Oscillator_FreqEditFieldLabel.Position = [21 377-shift 61 22];
Oscillator_FreqEditFieldLabel.Text = 'Freq.';

% Create Oscillator_AmpMeanEditField
Oscillator_FreqEditField = uieditfield(OscillatorTab, 'numeric');
Oscillator_FreqEditField.Position = [123 377-shift  103 22];

% Create StateNoiseEditFieldLabel
Oscillator_StateNoiseEditFieldLabel = uilabel(OscillatorTab);
Oscillator_StateNoiseEditFieldLabel.HorizontalAlignment = 'right';
Oscillator_StateNoiseEditFieldLabel.Position = [29 345-shift  53 22];
Oscillator_StateNoiseEditFieldLabel.Text = 'State Noise';

% Create StateNoiseEditFieldLabel
Oscillator_StateNoiseEditField = uieditfield(OscillatorTab, 'numeric');
Oscillator_StateNoiseEditField.Position = [123 345-shift  103 22];

% Create Oscillator_ObsNoiseEditField
Oscillator_ObsNoiseEditFieldLabel = uilabel(OscillatorTab);
Oscillator_ObsNoiseEditFieldLabel.HorizontalAlignment = 'right';
Oscillator_ObsNoiseEditFieldLabel.Position = [23 313-shift  59 22];
Oscillator_ObsNoiseEditFieldLabel.Text = 'Obs. Noise';

% Create Oscillator_ObsNoiseEditField
Oscillator_ObsNoiseEditField = uieditfield(OscillatorTab, 'numeric');
Oscillator_ObsNoiseEditField.Position = [123 313-shift  103 22];

% Create Oscillator_DampingFactorEditFieldLabel
Oscillator_DampingFactorEditFieldLabel = uilabel(OscillatorTab);
Oscillator_DampingFactorEditFieldLabel.HorizontalAlignment = 'right';
Oscillator_DampingFactorEditFieldLabel.Position = [23 281-shift  59 22];
Oscillator_DampingFactorEditFieldLabel.Text = 'DampingFactor';

% Create Oscillator_DampingFactorEditField
Oscillator_DampingFactorEditField = uieditfield(OscillatorTab, 'numeric');
Oscillator_DampingFactorEditField.Position = [123 281-shift  103 22];

% Create Oscillator_MEditFieldLabel
Oscillator_AmpMultEditFieldLabel = uilabel(OscillatorTab);
Oscillator_AmpMultEditFieldLabel.HorizontalAlignment = 'right';
Oscillator_AmpMultEditFieldLabel.Position = [23 249-shift  59 22];
Oscillator_AmpMultEditFieldLabel.Text = 'Amp. Mult.';

% Create Oscillator_MEditField
Oscillator_AmpMultEditField = uieditfield(OscillatorTab, 'numeric');
Oscillator_AmpMultEditField.Position = [123 249-shift  103 22];


[Oscillator_FreqEditField, Oscillator_StateNoiseEditField, Oscillator_ObsNoiseEditField, Oscillator_DampingFactorEditField, Oscillator_AmpMultEditField] = fillOscillator(Oscillator_FreqEditField, osc_num, Oscillator_StateNoiseEditField, Oscillator_ObsNoiseEditField, Oscillator_DampingFactorEditField, Oscillator_AmpMultEditField, obj);

OscillatorCallback = {@updateOscillator, obj, osc_num, OscillatorTab, Oscillator_FreqEditField, Oscillator_StateNoiseEditField, Oscillator_ObsNoiseEditField, Oscillator_DampingFactorEditField, Oscillator_AmpMultEditField, Oscillator_UIAxes};

Oscillator_FreqEditField.ValueChangedFcn = OscillatorCallback;
Oscillator_StateNoiseEditField.ValueChangedFcn = OscillatorCallback;
Oscillator_ObsNoiseEditField.ValueChangedFcn = OscillatorCallback;
Oscillator_DampingFactorEditField.ValueChangedFcn = OscillatorCallback;
Oscillator_AmpMultEditField.ValueChangedFcn =  OscillatorCallback;

updateOscillator([], [], obj, osc_num, OscillatorTab, Oscillator_FreqEditField, Oscillator_StateNoiseEditField, Oscillator_ObsNoiseEditField, Oscillator_DampingFactorEditField, Oscillator_AmpMultEditField, Oscillator_UIAxes);

end

function GUIaddAperiodic(obj, TabGroup)
if isempty(obj.Aperiodic)
    obj.addAperiodic;
    createAperiodicTab(TabGroup, obj);
else
    msgbox('Only one aperiodic component currently allowed');
end
end

function GUIaddSlowWaves(obj, TabGroup)
if isempty(obj.Slow_Waves)
    obj.addSlowWaves;
    createSlowWavesTab(TabGroup, obj)
else
    msgbox('Only one Slow Wave component currently allowed');
end
end

function GUIaddArtifacts(obj, TabGroup)
if isempty(obj.Artifacts)
    obj.addArtifacts;
    createArtifactsTab(TabGroup, obj);
else
    msgbox('Only one Motion Artifact component currently allowed');
end
end

function GUIaddSpindles(obj, TabGroup)
obj.addSpindles;
createSpindlesTab(TabGroup, obj, length(obj.SpindleSets));
end

function GUIaddOscillator(obj, TabGroup)
obj.addOscillator;
createOscillatorTab(TabGroup, obj,length(obj.OscillatorSets));
end

function GUIaddLineNoise(obj, TabGroup)
obj.addLineNoise;
createLineNoiseTab(TabGroup, obj, length(obj.LineNoiseSets));
end

function [Aperiodic_AlphaEditField, Aperiodic_MagnitudeEditField] = fillAperiodic(Aperiodic_AlphaEditField, Aperiodic_MagnitudeEditField, Aperiodic_UIAxes, obj)
Aperiodic_AlphaEditField.Value = obj.Aperiodic.Alpha;
Aperiodic_MagnitudeEditField.Value = obj.Aperiodic.Magnitude;
f = linspace(0,60);
p = Aperiodic_MagnitudeEditField.Value./(f.^Aperiodic_AlphaEditField.Value);
plot(Aperiodic_UIAxes,f,pow2db(p),'linewidth',2)
end

function [Artifacts_AmpMeanEditField, Artifacts_AmpSDEditField, Artifacts_AmpMinEditField, Artifacts_RateEditField] = fillArtifacts(Artifacts_AmpMeanEditField, Artifacts_AmpSDEditField, Artifacts_AmpMinEditField, Artifacts_RateEditField, obj)
Artifacts_AmpMeanEditField.Value = obj.Artifacts.Amp_mean;
Artifacts_AmpSDEditField.Value = obj.Artifacts.Amp_sd;
Artifacts_AmpMinEditField.Value = obj.Artifacts.Amp_min;
Artifacts_RateEditField.Value = obj.Artifacts.Rate;
end

function [SlowWaves_RateEditField, SlowWaves_AmpMeanEditField, SlowWaves_AmpSDEditField, SlowWaves_DurMeanEditField, SlowWaves_DurSDEditField] = fillSlowWaves(SlowWaves_RateEditField, SlowWaves_AmpMeanEditField, SlowWaves_AmpSDEditField, SlowWaves_DurMeanEditField, SlowWaves_DurSDEditField, obj)
SlowWaves_RateEditField.Value = obj.Slow_Waves.Rate;
SlowWaves_AmpMeanEditField.Value = obj.Slow_Waves.Amp_mean;
SlowWaves_AmpSDEditField.Value = obj.Slow_Waves.Amp_sd;
SlowWaves_DurMeanEditField.Value = obj.Slow_Waves.Dur_mean;
SlowWaves_DurSDEditField.Value = obj.Slow_Waves.Dur_sd;
end

function [Spindles_FreqSDEditField, Spindles_AmpMeanEditField, Spindles_AmpSDEditField, Spindles_FreqMeanEditField, Spindles_DurMeanEditField, Spindles_DurSDEditField, Spindles_BaselineRateEditField, Spindles_StartTimeEditField, Spindles_ModulationFactEditField, Spindles_PhasePrefEditField, Spindles_MaxTimeEditField, Spindles_TensionEditField, Spindles_ControlPointsEditField, Spindles_SplineValueEditField, Spindles_AmpMinEditField, Spindles_DurMinEditField] = fillSpindles(Spindles_FreqSDEditField, ss, Spindles_AmpMeanEditField, Spindles_AmpSDEditField, Spindles_FreqMeanEditField, Spindles_DurMeanEditField, Spindles_DurSDEditField, Spindles_BaselineRateEditField, Spindles_StartTimeEditField, Spindles_ModulationFactEditField, Spindles_PhasePrefEditField, Spindles_MaxTimeEditField, Spindles_TensionEditField, Spindles_ControlPointsEditField, Spindles_SplineValueEditField, Spindles_AmpMinEditField, Spindles_DurMinEditField, obj)

Spindles_FreqSDEditField.Value = obj.SpindleSets(ss).Freq_sd;
Spindles_AmpMeanEditField.Value = obj.SpindleSets(ss).Amp_mean;
Spindles_AmpSDEditField.Value = obj.SpindleSets(ss).Amp_sd;
Spindles_FreqMeanEditField.Value = obj.SpindleSets(ss).Freq_mean;
Spindles_DurMeanEditField.Value = obj.SpindleSets(ss).Dur_mean;
Spindles_DurSDEditField.Value = obj.SpindleSets(ss).Dur_sd;
Spindles_BaselineRateEditField.Value = obj.SpindleSets(ss).Baseline_rate;
Spindles_StartTimeEditField.Value = obj.SpindleSets(ss).Start_time;
Spindles_ModulationFactEditField.Value = obj.SpindleSets(ss).Modulation_factor;
Spindles_PhasePrefEditField.Value = value2str(obj.SpindleSets(ss).Phase_pref);
Spindles_MaxTimeEditField.Value = obj.SpindleSets(ss).Spline_tmax;
Spindles_TensionEditField.Value = obj.SpindleSets(ss).Tension;
Spindles_ControlPointsEditField.Value = value2str(obj.SpindleSets(ss).Ctrl_pts);
Spindles_SplineValueEditField.Value = value2str(obj.SpindleSets(ss).Theta_spline);
Spindles_AmpMinEditField.Value = obj.SpindleSets(ss).Amp_min;
Spindles_DurMinEditField.Value = obj.SpindleSets(ss).Dur_min;
end

function [LineNoise_FreqEditField, LineNoise_AmpEditField, LineNoise_WaveformDropDown] = fillLineNoise(LineNoise_FreqEditField, ln_num, LineNoise_AmpEditField, LineNoise_WaveformDropDown, obj)
LineNoise_FreqEditField.Value = obj.LineNoiseSets(ln_num).Freq;
LineNoise_AmpEditField.Value = obj.LineNoiseSets(ln_num).Amp;
LineNoise_WaveformDropDown.Value = obj.LineNoiseSets(ln_num).Waveform;
end

function [Oscillator_FreqEditField, Oscillator_StateNoiseEditField, Oscillator_ObsNoiseEditField, Oscillator_DampingFactorEditField, Oscillator_AmpMultEditField] = fillOscillator(Oscillator_FreqEditField, oo, Oscillator_StateNoiseEditField, Oscillator_ObsNoiseEditField, Oscillator_DampingFactorEditField, Oscillator_AmpMultEditField, obj)
Oscillator_FreqEditField.Value = obj.OscillatorSets(oo).Freq;
Oscillator_StateNoiseEditField.Value = obj.OscillatorSets(oo).StateNoise;
Oscillator_ObsNoiseEditField.Value = obj.OscillatorSets(oo).ObsNoise;
Oscillator_DampingFactorEditField.Value = obj.OscillatorSets(oo).DampingFactor;
Oscillator_AmpMultEditField.Value = obj.OscillatorSets(oo).AmpMult;
end

function removeComponent(obj, TabGroup)
c_titles = get(TabGroup.Children, 'title');
% Create a UI figure
fig = uifigure('Name', 'Delete Component','units','normalized', 'Position', [0.4186    0.4333    0.0872    0.3736]);
fig.Units = "pixels";
fig.Position(3:4) = [300 600];

% Create a list box with the options from the component_titles array
listbox = uilistbox(fig, 'Items', c_titles, 'Position', [50    90   200   439]);

% Create a button to delete the selected component
deleteButton = uibutton(fig, 'push', 'Text', 'Delete Component', ...
    'Position', [80 40 150 30], ...
    'ButtonPushedFcn', @(src, event) deleteComponent(listbox, TabGroup, obj));

% Function to handle deletion of the selected component
    function deleteComponent(listbox, TabGroup, obj)
        % Get the selected value from the list box
        selectedValue = listbox.Value;
        selectedIdx = listbox.ValueIndex;

        % Confirm deletion
        choice = uiconfirm(fig, ...
            ['Are you sure you want to delete "' selectedValue '"?'], ...
            'Confirm Deletion', ...
            'Options', {'Yes', 'Cancel'}, ...
            'DefaultOption', 2, ...
            'Icon', 'warning');

        % If the user confirms deletion, remove the selected item
        if strcmp(choice, 'Yes')


            if contains(selectedValue,'Aperiodic','IgnoreCase',true)
                obj.Aperiodic = [];
            end

            if contains(selectedValue,'Slow Waves','IgnoreCase',true)
                obj.Slow_Waves = [];
            end

            if contains(selectedValue,'Artifacts','IgnoreCase',true)
                obj.Artifacts = [];
            end

            if contains(selectedValue,'Spindles','IgnoreCase',true)
                sp_inds = contains(listbox.Items,'Spindles');
                sp_idx = cumsum(sp_inds(1:selectedIdx));

                obj.SpindleSets = obj.SpindleSets(setdiff(1:length(obj.SpindleSets),sp_idx));

            end

            delete(TabGroup.Children(selectedIdx));
            c_titles = get(TabGroup.Children, 'title');

            %Make into a cell if there is only one component left
            if length(TabGroup.Children) == 1 %#ok<ISCL>
                c_titles = {c_titles};
            end
            if ~isempty(c_titles)
                listbox.Items = c_titles;
            else
                listbox.Items = [];
            end

        end
    end
end