close all hidden
close all

%Create basic figure components
[UIFigure, TabGroup, SimulationOptionsMenu, PlotButton, PlotSimulationMenu, PlotComponentsMenu,...
    PlotSpectrumMenu, SetActiveComponentsMenu, ResimulateMenu, AddComponentMenu, AperiodicMenu, SlowWavesMenu, ...
    SpindlesMenu, LineNoiseMenu, BandPowerMenu, ArtifactsMenu, RemoveComponentMenu]   = createFigureComponents(obj);

% Create AperiodicEEGTab
if ~isempty(obj.Aperiodic)
    [AperiodicEEGTab, Aperiodic_MagnitudeEditField, Aperiodic_AlphaEditField, Aperiodic_UIAxes] = createAperiodicTab(TabGroup);
    [Aperiodic_AlphaEditField, Aperiodic_MagnitudeEditField] = fillAperiodic(Aperiodic_AlphaEditField, Aperiodic_MagnitudeEditField, Aperiodic_UIAxes, obj);

    aperiodicCallback =  {@updateAperiodic, obj, Aperiodic_AlphaEditField, Aperiodic_MagnitudeEditField, Aperiodic_UIAxes};
    Aperiodic_AlphaEditField.ValueChangedFcn = aperiodicCallback;
    Aperiodic_MagnitudeEditField.ValueChangedFcn = aperiodicCallback;
end

%Create Band EEG Tabs
if ~isempty(obj.BandSets)
    createBandTab(TabGroup, obj);
end

% Create SlowWavesTab
if ~isempty(obj.Slow_Waves)
    [SlowWavesTab, SlowWaves_AmpMeanEditField, SlowWaves_AmpSDEditField, SlowWaves_DurMeanEditField, SlowWaves_DurSDEditField, SlowWaves_RateEditField] = ...
        createSlowWavesTab(TabGroup);

    [SlowWaves_RateEditField, SlowWaves_AmpMeanEditField, SlowWaves_AmpSDEditField, SlowWaves_DurMeanEditField, SlowWaves_DurSDEditField] = fillSlowWaves(SlowWaves_RateEditField, SlowWaves_AmpMeanEditField, SlowWaves_AmpSDEditField, SlowWaves_DurMeanEditField, SlowWaves_DurSDEditField, obj);


    SWCallback = {@updateSlowWaves, obj, SlowWaves_RateEditField, SlowWaves_AmpMeanEditField, SlowWaves_AmpSDEditField, SlowWaves_DurMeanEditField, SlowWaves_DurSDEditField};;

    SlowWaves_RateEditField.ValueChangedFcn = SWCallback;
    SlowWaves_AmpSDEditField.ValueChangedFcn = SWCallback;
    SlowWaves_AmpMeanEditField.ValueChangedFcn = SWCallback;
    SlowWaves_DurSDEditField.ValueChangedFcn = SWCallback;
    SlowWaves_DurMeanEditField.ValueChangedFcn = SWCallback;
end

% Create SpindleTab
if ~isempty(obj.SpindleSets)
    for ss = 1:length(obj.SpindleSets)
        [SpindlesTab(ss), Spindles_UIAxes(ss), Spindles_FreqSDEditField(ss), Spindles_AmpMeanEditField(ss), Spindles_AmpSDEditField(ss), Spindles_FreqMeanEditField(ss), ...
            Spindles_DurMeanEditField(ss), Spindles_DurSDEditField(ss),Spindles_DurMinEditField(ss), Spindles_BaselineRateEditField(ss), Spindles_StartTimeEditField(ss), Spindles_ModulationFactEditField(ss), ...
            Spindles_PhasePrefEditField(ss), Spindles_MaxTimeEditField(ss), Spindles_TensionEditField(ss), Spindles_ControlPointsEditField(ss), ...
            Spindles_SplineValueEditField(ss), Spindles_AmpMinEditField(ss)] = ...
            createSpindlesTab(TabGroup);

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

        Spindles_FreqSDEditField(ss).ValueChangedFcn = spindleCallback;
        Spindles_AmpMeanEditField(ss).ValueChangedFcn = spindleCallback;
        Spindles_AmpSDEditField(ss).ValueChangedFcn = spindleCallback;
        Spindles_FreqMeanEditField(ss).ValueChangedFcn = spindleCallback;
        Spindles_DurMeanEditField(ss).ValueChangedFcn = spindleCallback;
        Spindles_DurSDEditField(ss).ValueChangedFcn = spindleCallback;
        Spindles_BaselineRateEditField(ss).ValueChangedFcn = spindleCallback;
        Spindles_StartTimeEditField(ss).ValueChangedFcn = spindleCallback;
        Spindles_ModulationFactEditField(ss).ValueChangedFcn = spindleCallback;
        Spindles_PhasePrefEditField(ss).ValueChangedFcn = spindleCallback;
        Spindles_MaxTimeEditField(ss).ValueChangedFcn = spindleCallback;
        Spindles_TensionEditField(ss).ValueChangedFcn = spindleCallback;
        Spindles_ControlPointsEditField(ss).ValueChangedFcn = spindleCallback;
        Spindles_SplineValueEditField(ss).ValueChangedFcn = spindleCallback;
        Spindles_AmpMinEditField(ss).ValueChangedFcn = spindleCallback;
        Spindles_DurMinEditField(ss).ValueChangedFcn = spindleCallback; %#ok<*SAGROW>

        updateSpindles([],[], obj, ss, SpindlesTab,...
            Spindles_UIAxes, Spindles_FreqSDEditField, Spindles_AmpMeanEditField, ...
            Spindles_AmpSDEditField, Spindles_FreqMeanEditField, Spindles_DurMeanEditField, ...
            Spindles_DurSDEditField, Spindles_BaselineRateEditField, Spindles_StartTimeEditField, ...
            Spindles_ModulationFactEditField, Spindles_PhasePrefEditField, Spindles_MaxTimeEditField, ...
            Spindles_TensionEditField, Spindles_ControlPointsEditField, Spindles_SplineValueEditField, ...
            Spindles_AmpMinEditField, Spindles_DurMinEditField);
    end
end

% Create LineNoiseTab
if ~isempty(obj.LineNoiseSets)
    for ll = 1:length(obj.LineNoiseSets)
        [LineNoiseTab(ll), LineNoise_UIAxes(ll), LineNoise_FreqEditField(ll), LineNoise_AmpEditField(ll), LineNoise_WaveformDropDown(ll)] = ...
            createLineNoiseTab(TabGroup);
    end
end

% Create ArtifactsTab
if ~isempty(obj.Artifacts)
    [Artifacts_AmpMeanEditField, Artifacts_AmpSDEditField, Artifacts_AmpMinEditField, Artifacts_RateEditField] = createArtifactsTab(TabGroup);
end

%Update Artifacts
if ~isempty(obj.Artifacts)
    if ~isempty(obj.Artifacts)
        Artifacts_RateEditField.Value = obj.Artifacts.Rate;
        Artifacts_AmpMeanEditField.Value = obj.Artifacts.Amp_mean;
        Artifacts_AmpSDEditField.Value = obj.Artifacts.Amp_sd;
        Artifacts_AmpMinEditField.Value = obj.Artifacts.Amp_min;
    end

    artCallback =  {@updateArtifacts, obj, Artifacts_RateEditField, Artifacts_AmpMeanEditField, Artifacts_AmpSDEditField, Artifacts_AmpMinEditField};

    Artifacts_RateEditField.ValueChangedFcn = artCallback;
    Artifacts_AmpMeanEditField.ValueChangedFcn = artCallback;
    Artifacts_AmpSDEditField.ValueChangedFcn = artCallback;
    Artifacts_AmpMinEditField.ValueChangedFcn = artCallback;
end



%Update LineNoise
if ~isempty(obj.LineNoiseSets)
    for ll = 1:length(obj.LineNoiseSets)
        LineNoise_FreqEditField(ll).Value = obj.LineNoiseSets(ll).Freq;
        LineNoise_AmpEditField(ll).Value = obj.LineNoiseSets(ll).Amp;
        LineNoise_WaveformDropDown(ll).Value = obj.LineNoiseSets(ll).Waveform;

        linenoiseCallback = {@updateLineNoise, obj, ll, LineNoiseTab, LineNoise_FreqEditField, LineNoise_AmpEditField, LineNoise_WaveformDropDown, LineNoise_UIAxes(ll)};

        LineNoise_FreqEditField(ll).ValueChangedFcn = linenoiseCallback;
        LineNoise_AmpEditField(ll).ValueChangedFcn = linenoiseCallback;
        LineNoise_WaveformDropDown(ll).ValueChangedFcn = linenoiseCallback;

        updateLineNoise([],[],obj, ll, LineNoiseTab, LineNoise_FreqEditField, LineNoise_AmpEditField, LineNoise_WaveformDropDown, LineNoise_UIAxes(ll));
    end
end


% Show the figure after all components are created
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

obj.SpindleSets(ss).Freq_sd = Spindles_FreqSDEditField(ss).Value;
obj.SpindleSets(ss).Amp_mean = Spindles_AmpMeanEditField(ss).Value;
obj.SpindleSets(ss).Amp_sd = Spindles_AmpSDEditField(ss).Value;
obj.SpindleSets(ss).Freq_mean = Spindles_FreqMeanEditField(ss).Value;
obj.SpindleSets(ss).Dur_mean = Spindles_DurMeanEditField(ss).Value;
obj.SpindleSets(ss).Dur_sd = Spindles_DurSDEditField(ss).Value;
obj.SpindleSets(ss).Baseline_rate = Spindles_BaselineRateEditField(ss).Value;
obj.SpindleSets(ss).Start_time = Spindles_StartTimeEditField(ss).Value;
obj.SpindleSets(ss).Modulation_factor = Spindles_ModulationFactEditField(ss).Value;
obj.SpindleSets(ss).Phase_pref = eval(Spindles_PhasePrefEditField(ss).Value);
obj.SpindleSets(ss).Spline_tmax = Spindles_MaxTimeEditField(ss).Value;
obj.SpindleSets(ss).Tension = Spindles_TensionEditField(ss).Value;
obj.SpindleSets(ss).Ctrl_pts = eval(Spindles_ControlPointsEditField(ss).Value);
obj.SpindleSets(ss).Theta_spline = eval(Spindles_SplineValueEditField(ss).Value);
obj.SpindleSets(ss).Amp_min = Spindles_AmpMinEditField(ss).Value;
obj.SpindleSets(ss).Dur_min = Spindles_DurMinEditField(ss).Value;

obj.SpindleSets(ss).genS;
obj.SpindleSets(ss).plot_spline(Spindles_UIAxes(ss),'linewidth',2);
SpindlesTab(ss).Title = ['Spindles ' num2str(obj.SpindleSets(ss).Freq_mean) 'Hz'];
end

function updateLineNoise(~,~,obj, ll, LineNoiseTab, LineNoise_FreqEditField, LineNoise_AmpEditField, LineNoise_WaveformDropDown, LineNoise_UIAxes)
obj.LineNoiseSets(ll).Freq = LineNoise_FreqEditField(ll).Value;
obj.LineNoiseSets(ll).Amp = LineNoise_AmpEditField(ll).Value;
obj.LineNoiseSets(ll).Waveform = LineNoise_WaveformDropDown(ll).Value;

LineNoiseTab(ll).Title = ['Line Noise ' obj.LineNoiseSets(ll).Waveform ' ' num2str(obj.LineNoiseSets(ll).Freq) 'Hz' ];

f  = obj.LineNoiseSets(ll).Freq;
a = obj.LineNoiseSets(ll).Amp ;

Fs = max(500, f*2);
t = 0:(1/Fs):1; %Plot 1s of data

switch obj.LineNoiseSets(ll).Waveform
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


function [AperiodicEEGTab, Aperiodic_MagnitudeEditField, Aperiodic_AlphaEditField, Aperiodic_UIAxes] = createAperiodicTab(TabGroup)
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
end

function createBandTab(TabGroup)
% Create BandPowerTab
BandPowerTab = uitab(TabGroup);
BandPowerTab.Title = 'Band Power';

% Create AmplitudeLabel
Band_AmplitudeLabel = uilabel(BandPowerTab);
Band_AmplitudeLabel.HorizontalAlignment = 'right';
Band_AmplitudeLabel.Position = [23 345 59 22];
Band_AmplitudeLabel.Text = 'Amplitude';

% Create Band_AmpEditField
Band_AmpEditField = uieditfield(BandPowerTab, 'numeric');
Band_AmpEditField.Position = [123 345 103 22];

% Create FreqRangeLabel
Band_FreqRangeLabel = uilabel(BandPowerTab);
Band_FreqRangeLabel.HorizontalAlignment = 'right';
Band_FreqRangeLabel.Position = [11 377 71 22];
Band_FreqRangeLabel.Text = 'Freq. Range';

% Create Band_FreqEditField
Band_FreqEditField = uieditfield(BandPowerTab, 'numeric');
Band_FreqEditField.Position = [123 377 103 22];
end

function [SlowWavesTab, SlowWaves_AmpMeanEditField, SlowWaves_AmpSDEditField, SlowWaves_DurMeanEditField, ...
    SlowWaves_DurSDEditField, SlowWaves_RateEditField] = createSlowWavesTab(TabGroup)
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
end

function [SpindlesTab, Spindles_UIAxes, Spindles_FreqSDEditField, Spindles_AmpMeanEditField, Spindles_AmpSDEditField, ...
    Spindles_FreqMeanEditField, Spindles_DurMeanEditField, Spindles_DurSDEditField,Spindles_DurMinEditField, Spindles_BaselineRateEditField, ...
    Spindles_StartTimeEditField, Spindles_ModulationFactEditField, Spindles_PhasePrefEditField, Spindles_MaxTimeEditField,...
    Spindles_TensionEditField, Spindles_ControlPointsEditField, Spindles_SplineValueEditField, Spindles_AmpMinEditField] = createSpindlesTab(TabGroup)
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
end

function  [UIFigure, TabGroup, SimulationOptionsMenu, PlotButton, PlotSimulationMenu, PlotComponentsMenu,...
    PlotSpectrumMenu, SetActiveComponentsMenu, ResimulateMenu, AddComponentMenu, AperiodicMenu, SlowWavesMenu, ...
    SpindlesMenu, LineNoiseMenu, BandPowerMenu, ArtifactsMenu, RemoveComponentMenu] = createFigureComponents(obj)

% Create UIFigure and hide until all components are created
UIFigure = uifigure('Visible', 'off');
UIFigure.AutoResizeChildren = 'off';
UIFigure.Position = [100 100 974 627];
UIFigure.Name = 'SleepEEGSim Components';
UIFigure.Resize = 'off';

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
% PlotSimulationMenu.MenuSelectedFcn = createCallbackFcn(obj, @asdfadsf, true);
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

% Create BandPowerMenu
BandPowerMenu = uimenu(AddComponentMenu);
BandPowerMenu.Text = 'Band Power';

% Create ArtifactsMenu
ArtifactsMenu = uimenu(AddComponentMenu);
ArtifactsMenu.Text = 'Artifacts';

% Create RemoveComponentMenu
RemoveComponentMenu = uimenu(SimulationOptionsMenu);
RemoveComponentMenu.Text = 'Remove Component';

% Create TabGroup
TabGroup = uitabgroup(UIFigure);
TabGroup.AutoResizeChildren = 'off';
TabGroup.Position = [9 100 962 500];

AperiodicMenu.MenuSelectedFcn = {@(s,e)GUIaddAperiodic(obj, TabGroup)};
SlowWavesMenu.MenuSelectedFcn = {@(s,e)GUIaddSlowWaves(obj, TabGroup)};
ArtifactsMenu.MenuSelectedFcn = {@(s,e)GUIaddArtifacts(obj, TabGroup)};
SpindlesMenu.MenuSelectedFcn = {@(s,e)GUIaddSpindles(obj, TabGroup)};
end

function [Artifacts_AmpMeanEditField, Artifacts_AmpSDEditField, Artifacts_AmpMinEditField, Artifacts_RateEditField] = createArtifactsTab(TabGroup)
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
end

function [LineNoiseTab, LineNoise_UIAxes, LineNoise_FreqEditField, LineNoise_AmpEditField, ...
    LineNoise_WaveformDropDown] = createLineNoiseTab(TabGroup)

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
end

function GUIaddAperiodic(obj, TabGroup)
if isempty(obj.Aperiodic)
    obj.addAperiodic;
    [~, Aperiodic_MagnitudeEditField, Aperiodic_AlphaEditField, Aperiodic_UIAxes] = createAperiodicTab(TabGroup);
    fillAperiodic(Aperiodic_AlphaEditField, Aperiodic_MagnitudeEditField, Aperiodic_UIAxes, obj);
else
    msgbox('Only one aperiodic component currently allowed');
end
end

function GUIaddSlowWaves(obj, TabGroup)
if isempty(obj.Slow_Waves)
    obj.addSlowWaves;
    [~, SlowWaves_AmpMeanEditField, SlowWaves_AmpSDEditField, SlowWaves_DurMeanEditField, ...
        SlowWaves_DurSDEditField, SlowWaves_RateEditField] = createSlowWavesTab(TabGroup);
    fillSlowWaves(SlowWaves_RateEditField, SlowWaves_AmpMeanEditField, SlowWaves_AmpSDEditField, SlowWaves_DurMeanEditField, SlowWaves_DurSDEditField, obj);
else
   msgbox('Only one Slow Wave component currently allowed');
end
end

function GUIaddSArtifacts(obj, tabgroup)
if isempty(obj.Artifacts)
    obj.Artifacts;
    createArtifactsTab(tabgroup);
else
    msgbox('Only one Motion Artifact component currently allowed');
end
end

function GUIaddSpindles(obj, tabgroup)
obj.addSpindles;
createSpindlesTab(tabgroup);
end

function [Aperiodic_AlphaEditField, Aperiodic_MagnitudeEditField] = fillAperiodic(Aperiodic_AlphaEditField, Aperiodic_MagnitudeEditField, Aperiodic_UIAxes, obj)
Aperiodic_AlphaEditField.Value = obj.Aperiodic.Alpha;
Aperiodic_MagnitudeEditField.Value = obj.Aperiodic.Magnitude;
f = linspace(0,60);
p = Aperiodic_MagnitudeEditField.Value./(f.^Aperiodic_AlphaEditField.Value);
plot(Aperiodic_UIAxes,f,pow2db(p),'linewidth',2)
end

function [SlowWaves_RateEditField, SlowWaves_AmpMeanEditField, SlowWaves_AmpSDEditField, SlowWaves_DurMeanEditField, SlowWaves_DurSDEditField] = fillSlowWaves(SlowWaves_RateEditField, SlowWaves_AmpMeanEditField, SlowWaves_AmpSDEditField, SlowWaves_DurMeanEditField, SlowWaves_DurSDEditField, obj)
SlowWaves_RateEditField.Value = obj.Slow_Waves.Rate;
SlowWaves_AmpMeanEditField.Value = obj.Slow_Waves.Amp_mean;
SlowWaves_AmpSDEditField.Value = obj.Slow_Waves.Amp_sd;
SlowWaves_DurMeanEditField.Value = obj.Slow_Waves.Dur_mean;
SlowWaves_DurSDEditField.Value = obj.Slow_Waves.Dur_sd;
end

function [Spindles_FreqSDEditField, Spindles_AmpMeanEditField, Spindles_AmpSDEditField, Spindles_FreqMeanEditField, Spindles_DurMeanEditField, Spindles_DurSDEditField, Spindles_BaselineRateEditField, Spindles_StartTimeEditField, Spindles_ModulationFactEditField, Spindles_PhasePrefEditField, Spindles_MaxTimeEditField, Spindles_TensionEditField, Spindles_ControlPointsEditField, Spindles_SplineValueEditField, Spindles_AmpMinEditField, Spindles_DurMinEditField] = fillSpindles(Spindles_FreqSDEditField, ss, Spindles_AmpMeanEditField, Spindles_AmpSDEditField, Spindles_FreqMeanEditField, Spindles_DurMeanEditField, Spindles_DurSDEditField, Spindles_BaselineRateEditField, Spindles_StartTimeEditField, Spindles_ModulationFactEditField, Spindles_PhasePrefEditField, Spindles_MaxTimeEditField, Spindles_TensionEditField, Spindles_ControlPointsEditField, Spindles_SplineValueEditField, Spindles_AmpMinEditField, Spindles_DurMinEditField, obj)

Spindles_FreqSDEditField(ss).Value = obj.SpindleSets(ss).Freq_sd;
Spindles_AmpMeanEditField(ss).Value = obj.SpindleSets(ss).Amp_mean;
Spindles_AmpSDEditField(ss).Value = obj.SpindleSets(ss).Amp_sd;
Spindles_FreqMeanEditField(ss).Value = obj.SpindleSets(ss).Freq_mean;
Spindles_DurMeanEditField(ss).Value = obj.SpindleSets(ss).Dur_mean;
Spindles_DurSDEditField(ss).Value = obj.SpindleSets(ss).Dur_sd;
Spindles_BaselineRateEditField(ss).Value = obj.SpindleSets(ss).Baseline_rate;
Spindles_StartTimeEditField(ss).Value = obj.SpindleSets(ss).Start_time;
Spindles_ModulationFactEditField(ss).Value = obj.SpindleSets(ss).Modulation_factor;
Spindles_PhasePrefEditField(ss).Value = value2str(obj.SpindleSets(ss).Phase_pref);
Spindles_MaxTimeEditField(ss).Value = obj.SpindleSets(ss).Spline_tmax;
Spindles_TensionEditField(ss).Value = obj.SpindleSets(ss).Tension;
Spindles_ControlPointsEditField(ss).Value = value2str(obj.SpindleSets(ss).Ctrl_pts);
Spindles_SplineValueEditField(ss).Value = value2str(obj.SpindleSets(ss).Theta_spline);
Spindles_AmpMinEditField(ss).Value = obj.SpindleSets(ss).Amp_min;
Spindles_DurMinEditField(ss).Value = obj.SpindleSets(ss).Dur_min;
end