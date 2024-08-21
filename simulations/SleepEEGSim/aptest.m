% Create UIFigure and hide until all components are created
UIFigure = uifigure('Visible', 'off');
UIFigure.AutoResizeChildren = 'off';
UIFigure.Position = [100 100 964 494];
UIFigure.Name = 'MATLAB App';
% UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);
%
% % Create GridLayout
% GridLayout = uigridlayout(UIFigure);
% GridLayout.ColumnWidth = {332, '1x'};
% GridLayout.RowHeight = {'1x'};
% GridLayout.ColumnSpacing = 0;
% GridLayout.RowSpacing = 0;
% GridLayout.Padding = [0 0 0 0];
% GridLayout.Scrollable = 'on';
%
% % Create LeftPanel
% LeftPanel = uipanel(GridLayout);
% LeftPanel.Layout.Row = 1;
% LeftPanel.Layout.Column = 1;
%
% % Create RightPanel
% RightPanel = uipanel(GridLayout);
% RightPanel.Layout.Row = 1;
% RightPanel.Layout.Column = 2;

% Create TabGroup
TabGroup = uitabgroup(UIFigure);
TabGroup.Position = [1 54 831 440];

% Create AperiodicEEGTab
AperiodicEEGTab = uitab(TabGroup);
AperiodicEEGTab.Title = 'Aperiodic EEG';

% Create MagnitudeEditFieldLabel
Ap_MagnitudeEditFieldLabel = uilabel(AperiodicEEGTab);
Ap_MagnitudeEditFieldLabel.HorizontalAlignment = 'right';
Ap_MagnitudeEditFieldLabel.Position = [20 345 62 22];
Ap_MagnitudeEditFieldLabel.Text = 'Magnitude';

% Create Ap_MagnitudeEditField
Ap_MagnitudeEditField = uieditfield(AperiodicEEGTab, 'numeric');
Ap_MagnitudeEditField.Position = [123 345 103 22];

% Create AlphaEditFieldLabel
Ap_AlphaEditFieldLabel = uilabel(AperiodicEEGTab);
Ap_AlphaEditFieldLabel.HorizontalAlignment = 'right';
Ap_AlphaEditFieldLabel.Position = [18 377 64 22];
Ap_AlphaEditFieldLabel.Text = 'Alpha';

% Create Ap_AlphaEditField
Ap_AlphaEditField = uieditfield(AperiodicEEGTab, 'numeric');
Ap_AlphaEditField.Position = [123 377 103 22];

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

% Create SlowWavesTab
SlowWavesTab = uitab(TabGroup);
SlowWavesTab.Title = 'Slow Waves';

% Create AmpMeanEditFieldLabel
SW_AmpMeanEditFieldLabel = uilabel(SlowWavesTab);
SW_AmpMeanEditFieldLabel.HorizontalAlignment = 'right';
SW_AmpMeanEditFieldLabel.Position = [15 345 67 22];
SW_AmpMeanEditFieldLabel.Text = 'Amp. Mean';

% Create SW_AmpMeanEditField
SW_AmpMeanEditField = uieditfield(SlowWavesTab, 'numeric');
SW_AmpMeanEditField.Position = [123 345 103 22];

% Create AmpSDEditFieldLabel
SW_AmpSDEditFieldLabel = uilabel(SlowWavesTab);
SW_AmpSDEditFieldLabel.HorizontalAlignment = 'right';
SW_AmpSDEditFieldLabel.Position = [29 313 53 22];
SW_AmpSDEditFieldLabel.Text = 'Amp. SD';

% Create SW_AmpSDEditField
SW_AmpSDEditField = uieditfield(SlowWavesTab, 'numeric');
SW_AmpSDEditField.Position = [123 313 103 22];

% Create DurMeanEditFieldLabel
SW_DurMeanEditFieldLabel = uilabel(SlowWavesTab);
SW_DurMeanEditFieldLabel.HorizontalAlignment = 'right';
SW_DurMeanEditFieldLabel.Position = [22 278 60 22];
SW_DurMeanEditFieldLabel.Text = 'Dur. Mean';

% Create SW_DurMeanEditField
SW_DurMeanEditField = uieditfield(SlowWavesTab, 'numeric');
SW_DurMeanEditField.Position = [123 278 103 22];

% Create DurSDEditFieldLabel
SW_DurSDEditFieldLabel = uilabel(SlowWavesTab);
SW_DurSDEditFieldLabel.HorizontalAlignment = 'right';
SW_DurSDEditFieldLabel.Position = [36 246 46 22];
SW_DurSDEditFieldLabel.Text = 'Dur. SD';

% Create SW_DurSDEditField
SW_DurSDEditField = uieditfield(SlowWavesTab, 'numeric');
SW_DurSDEditField.Position = [123 246 103 22];

% Create RateEditFieldLabel
SW_RateEditFieldLabel = uilabel(SlowWavesTab);
SW_RateEditFieldLabel.HorizontalAlignment = 'right';
SW_RateEditFieldLabel.Position = [18 377 64 22];
SW_RateEditFieldLabel.Text = 'Rate';

% Create SW_RateEditField
SW_RateEditField = uieditfield(SlowWavesTab, 'numeric');
SW_RateEditField.Position = [123 377 103 22];

% Create SpindleTab
for ss = 1:length(obj.SpindleSets)
    SpindleTab(ss) = uitab(TabGroup); %#ok<*SAGROW>
    SpindleTab(ss).Title = ['Spindles ' num2str(obj.SpindleSets(ss).Freq_mean) 'Hz'];

    % Create FreqSDEditFieldLabel
    Sp_FreqSDEditFieldLabel(ss) = uilabel(SpindleTab(ss));
    Sp_FreqSDEditFieldLabel(ss).HorizontalAlignment = 'right';
    Sp_FreqSDEditFieldLabel(ss).Position = [30 345 52 22];
    Sp_FreqSDEditFieldLabel(ss).Text = 'Freq. SD';

    % Create Sp_FreqSDEditField(ss)
    Sp_FreqSDEditField(ss) = uieditfield(SpindleTab(ss), 'numeric');
    Sp_FreqSDEditField(ss).Position = [123 345 103 22];

    % Create AmpMeanEditFieldLabel
    Sp_AmpMeanEditFieldLabel(ss) = uilabel(SpindleTab(ss));
    Sp_AmpMeanEditFieldLabel(ss).HorizontalAlignment = 'right';
    Sp_AmpMeanEditFieldLabel(ss).Position = [15 313 67 22];
    Sp_AmpMeanEditFieldLabel(ss).Text = 'Amp. Mean';

    % Create Sp_AmpMeanEditField(ss)
    Sp_AmpMeanEditField(ss) = uieditfield(SpindleTab(ss), 'numeric');
    Sp_AmpMeanEditField(ss).Position = [123 313 103 22];

    % Create AmpSDEditFieldLabel
    Sp_AmpSDEditFieldLabel(ss) = uilabel(SpindleTab(ss));
    Sp_AmpSDEditFieldLabel(ss).HorizontalAlignment = 'right';
    Sp_AmpSDEditFieldLabel(ss).Position = [29 278 53 22];
    Sp_AmpSDEditFieldLabel(ss).Text = 'Amp. SD';

    % Create Sp_AmpSDEditField(ss)
    Sp_AmpSDEditField(ss) = uieditfield(SpindleTab(ss), 'numeric');
    Sp_AmpSDEditField(ss).Position = [123 278 103 22];

    % Create FreqMeanEditFieldLabel
    Sp_FreqMeanEditFieldLabel(ss) = uilabel(SpindleTab(ss));
    Sp_FreqMeanEditFieldLabel(ss).HorizontalAlignment = 'right';
    Sp_FreqMeanEditFieldLabel(ss).Position = [16 377 66 22];
    Sp_FreqMeanEditFieldLabel(ss).Text = 'Freq. Mean';

    % Create Sp_FreqMeanEditField(ss)
    Sp_FreqMeanEditField(ss) = uieditfield(SpindleTab(ss), 'numeric');
    Sp_FreqMeanEditField(ss).Position = [123 377 103 22];

    % Create DurMeanEditFieldLabel
    Sp_DurMeanEditFieldLabel(ss) = uilabel(SpindleTab(ss));
    Sp_DurMeanEditFieldLabel(ss).HorizontalAlignment = 'right';
    Sp_DurMeanEditFieldLabel(ss).Position = [23 246 60 22];
    Sp_DurMeanEditFieldLabel(ss).Text = 'Dur. Mean';

    % Create Sp_DurMeanEditField(ss)
    Sp_DurMeanEditField(ss) = uieditfield(SpindleTab(ss), 'numeric');
    Sp_DurMeanEditField(ss).Position = [124 246 103 22];

    % Create DurSDEditFieldLabel
    Sp_DurSDEditFieldLabel(ss) = uilabel(SpindleTab(ss));
    Sp_DurSDEditFieldLabel(ss).HorizontalAlignment = 'right';
    Sp_DurSDEditFieldLabel(ss).Position = [37 211 46 22];
    Sp_DurSDEditFieldLabel(ss).Text = 'Dur. SD';

    % Create Sp_DurSDEditField(ss)
    Sp_DurSDEditField(ss) = uieditfield(SpindleTab(ss), 'numeric');
    Sp_DurSDEditField(ss).Position = [124 211 103 22];

    % Create BaselineRateEditFieldLabel
    Sp_BaselineRateEditFieldLabel(ss) = uilabel(SpindleTab(ss));
    Sp_BaselineRateEditFieldLabel(ss).HorizontalAlignment = 'right';
    Sp_BaselineRateEditFieldLabel(ss).Position = [5 164 79 22];
    Sp_BaselineRateEditFieldLabel(ss).Text = 'Baseline Rate';

    % Create Sp_BaselineRateEditField(ss)
    Sp_BaselineRateEditField(ss) = uieditfield(SpindleTab(ss), 'numeric');
    Sp_BaselineRateEditField(ss).Position = [125 164 103 22];

    % Create StartTimeEditFieldLabel
    Sp_StartTimeEditFieldLabel(ss) = uilabel(SpindleTab(ss));
    Sp_StartTimeEditFieldLabel(ss).HorizontalAlignment = 'right';
    Sp_StartTimeEditFieldLabel(ss).Position = [24 129 60 22];
    Sp_StartTimeEditFieldLabel(ss).Text = 'Start Time';

    % Create Sp_StartTimeEditField(ss)
    Sp_StartTimeEditField(ss) = uieditfield(SpindleTab(ss), 'numeric');
    Sp_StartTimeEditField(ss).Position = [125 129 103 22];

    % Create ModulationFactEditFieldLabel
    Sp_ModulationFactEditFieldLabel(ss) = uilabel(SpindleTab(ss));
    Sp_ModulationFactEditFieldLabel(ss).HorizontalAlignment = 'right';
    Sp_ModulationFactEditFieldLabel(ss).Position = [232 345 95 22];
    Sp_ModulationFactEditFieldLabel(ss).Text = 'Modulation Fact.';

    % Create Sp_ModulationFactEditField
    Sp_ModulationFactEditField(ss) = uieditfield(SpindleTab(ss), 'numeric');
    Sp_ModulationFactEditField(ss).Position = [368 345 103 22];

    % Create ControlPointsEditFieldLabel
    Sp_ControlPointsEditFieldLabel(ss) = uilabel(SpindleTab(ss));
    Sp_ControlPointsEditFieldLabel(ss).HorizontalAlignment = 'right';
    Sp_ControlPointsEditFieldLabel(ss).Position = [248 278 81 22];
    Sp_ControlPointsEditFieldLabel(ss).Text = 'Control Points';

    % Create Sp_ControlPointsEditField(ss)
    Sp_ControlPointsEditField(ss) = uieditfield(SpindleTab(ss), 'numeric');
    Sp_ControlPointsEditField(ss).Position = [370 278 103 22];

    % Create SplineThetaEditFieldLabel
    Sp_SplineThetaEditFieldLabel(ss) = uilabel(SpindleTab(ss));
    Sp_SplineThetaEditFieldLabel(ss).HorizontalAlignment = 'right';
    Sp_SplineThetaEditFieldLabel(ss).Position = [257 243 72 22];
    Sp_SplineThetaEditFieldLabel(ss).Text = 'Spline Theta';

    % Create Sp_SplineThetaEditField(ss)
    Sp_SplineThetaEditField(ss) = uieditfield(SpindleTab(ss), 'numeric');
    Sp_SplineThetaEditField(ss).Position = [370 243 103 22];

    % Create PhasePrefEditFieldLabel
    Sp_PhasePrefEditFieldLabel(ss) = uilabel(SpindleTab(ss));
    Sp_PhasePrefEditFieldLabel(ss).HorizontalAlignment = 'right';
    Sp_PhasePrefEditFieldLabel(ss).Position = [260 377 67 22];
    Sp_PhasePrefEditFieldLabel(ss).Text = 'Phase Pref.';

    % Create Sp_PhasePrefEditField(ss)
    Sp_PhasePrefEditField(ss) = uieditfield(SpindleTab(ss), 'numeric');
    Sp_PhasePrefEditField(ss).Position = [368 377 103 22];

    % Create MaxTimeEditFieldLabel
    Sp_MaxTimeEditFieldLabel(ss) = uilabel(SpindleTab(ss));
    Sp_MaxTimeEditFieldLabel(ss).HorizontalAlignment = 'right';
    Sp_MaxTimeEditFieldLabel(ss).Position = [272 211 58 22];
    Sp_MaxTimeEditFieldLabel(ss).Text = 'Max Time';

    % Create Sp_MaxTimeEditField(ss)
    Sp_MaxTimeEditField(ss) = uieditfield(SpindleTab(ss), 'numeric');
    Sp_MaxTimeEditField(ss).Position = [371 211 103 22];

    % Create TensionEditFieldLabel
    Sp_TensionEditFieldLabel(ss) = uilabel(SpindleTab(ss));
    Sp_TensionEditFieldLabel(ss).HorizontalAlignment = 'right';
    Sp_TensionEditFieldLabel(ss).Position = [284 176 46 22];
    Sp_TensionEditFieldLabel(ss).Text = 'Tension';

    % Create Sp_TensionEditField(ss)
    Sp_TensionEditField(ss) = uieditfield(SpindleTab(ss), 'numeric');
    Sp_TensionEditField(ss).Position = [371 176 103 22];
end

% Create LineNoiseTab
LineNoiseTab = uitab(TabGroup);
LineNoiseTab.Title = 'Line Noise';

% Create AmpMeanEditFieldLabel
Ln_AmpMeanEditFieldLabel = uilabel(LineNoiseTab);
Ln_AmpMeanEditFieldLabel.HorizontalAlignment = 'right';
Ln_AmpMeanEditFieldLabel.Position = [21 345 61 22];
Ln_AmpMeanEditFieldLabel.Text = 'Frequency';

% Create Ln_AmpMeanEditField
Ln_AmpMeanEditField = uieditfield(LineNoiseTab, 'numeric');
Ln_AmpMeanEditField.Position = [123 345 103 22];

% Create AmpSDEditFieldLabel
Ln_AmpSDEditFieldLabel = uilabel(LineNoiseTab);
Ln_AmpSDEditFieldLabel.HorizontalAlignment = 'right';
Ln_AmpSDEditFieldLabel.Position = [29 313 53 22];
Ln_AmpSDEditFieldLabel.Text = 'Amp. SD';

% Create Ln_AmpSDEditField
Ln_AmpSDEditField = uieditfield(LineNoiseTab, 'numeric');
Ln_AmpSDEditField.Position = [123 313 103 22];

% Create WaveformDropDownLabel
Ln_WaveformDropDownLabel = uilabel(LineNoiseTab);
Ln_WaveformDropDownLabel.HorizontalAlignment = 'right';
Ln_WaveformDropDownLabel.Position = [23 377 59 22];
Ln_WaveformDropDownLabel.Text = 'Waveform';

% Create Ln_WaveformDropDown
Ln_WaveformDropDown = uidropdown(LineNoiseTab);
Ln_WaveformDropDown.Items = {'Sin', 'Sawtooth', 'Square'};
Ln_WaveformDropDown.Position = [123 377 103 22];
Ln_WaveformDropDown.Value = 'Sin';

% Create ArtifactsTab
ArtifactsTab = uitab(TabGroup);
ArtifactsTab.Title = 'Artifacts';

% Create AmpMeanEditFieldLabel
Art_AmpMeanEditFieldLabel = uilabel(ArtifactsTab);
Art_AmpMeanEditFieldLabel.HorizontalAlignment = 'right';
Art_AmpMeanEditFieldLabel.Position = [15 345 67 22];
Art_AmpMeanEditFieldLabel.Text = 'Amp. Mean';

% Create Art_AmpMeanEditField
Art_AmpMeanEditField = uieditfield(ArtifactsTab, 'numeric');
Art_AmpMeanEditField.Position = [123 345 103 22];

% Create AmpSDEditFieldLabel
Art_AmpSDEditFieldLabel = uilabel(ArtifactsTab);
Art_AmpSDEditFieldLabel.HorizontalAlignment = 'right';
Art_AmpSDEditFieldLabel.Position = [29 313 53 22];
Art_AmpSDEditFieldLabel.Text = 'Amp. SD';

% Create Art_AmpSDEditField
Art_AmpSDEditField = uieditfield(ArtifactsTab, 'numeric');
Art_AmpSDEditField.Position = [123 313 103 22];

% Create AmpMinEditFieldLabel
Art_AmpMinEditFieldLabel = uilabel(ArtifactsTab);
Art_AmpMinEditFieldLabel.HorizontalAlignment = 'right';
Art_AmpMinEditFieldLabel.Position = [25 278 57 22];
Art_AmpMinEditFieldLabel.Text = 'Amp. Min';

% Create Art_AmpMinEditField
Art_AmpMinEditField = uieditfield(ArtifactsTab, 'numeric');
Art_AmpMinEditField.Position = [123 278 103 22];

% Create RateEditFieldLabel
Art_RateEditFieldLabel = uilabel(ArtifactsTab);
Art_RateEditFieldLabel.HorizontalAlignment = 'right';
Art_RateEditFieldLabel.Position = [18 377 64 22];
Art_RateEditFieldLabel.Text = 'Rate';

% Create Art_RateEditField
Art_RateEditField = uieditfield(ArtifactsTab, 'numeric');
Art_RateEditField.Position = [123 377 103 22];

%Update Aperiodic
if ~isempty(obj.Aperiodic)
    Ap_AlphaEditField.Value = obj.Aperiodic.Alpha;
    Ap_MagnitudeEditField.Value = obj.Aperiodic.Magnitude;
end

aperiodicCallback =  {@updateAperiodic, obj, Ap_AlphaEditField, Ap_MagnitudeEditField};
Ap_AlphaEditField.ValueChangedFcn = aperiodicCallback;
Ap_MagnitudeEditField.ValueChangedFcn = aperiodicCallback;

%Update Slow Waves
if ~isempty(obj.Slow_Waves)
    SW_RateEditField.Value = obj.Slow_Waves.Rate;
    SW_AmpMeanEditField.Value = obj.Slow_Waves.Amp_mean;
    SW_AmpSDEditField.Value = obj.Slow_Waves.Amp_sd;
    SW_DurMeanEditField.Value = obj.Slow_Waves.Dur_mean;
    SW_DurSDEditField.Value = obj.Slow_Waves.Dur_sd;
end

SWCallback = {@updateSlowWaves, obj, SW_RateEditField, SW_AmpMeanEditField, SW_AmpSDEditField, SW_DurMeanEditField, SW_DurSDEditField};;

SW_RateEditField.ValueChangedFcn = SWCallback;
SW_AmpSDEditField.ValueChangedFcn = SWCallback;
SW_AmpMeanEditField.ValueChangedFcn = SWCallback;
SW_DurSDEditField.ValueChangedFcn = SWCallback;
SW_DurMeanEditField.ValueChangedFcn = SWCallback;

%Update Artifacts
if ~isempty(obj.Artifacts)
    Art_RateEditField.Value = obj.Artifacts.Rate;
    Art_AmpMeanEditField.Value = obj.Artifacts.Amp_mean;
    Art_AmpSDEditField.Value = obj.Artifacts.Amp_sd;
    Art_AmpMinEditField.Value = obj.Artifacts.Amp_min;
end

artCallback =  {@updateArtifacts, obj, Art_RateEditField, Art_AmpMeanEditField, Art_AmpSDEditField, Art_AmpMinEditField};

Art_RateEditField.ValueChangedFcn = artCallback;
Art_AmpMeanEditField.ValueChangedFcn = artCallback;
Art_AmpSDEditField.ValueChangedFcn = artCallback;
Art_AmpMinEditField.ValueChangedFcn = artCallback;

%Update Spindles
for ss = 1:length(obj.SpindleSets)
    Sp_FreqMeanEditField(ss).Value = obj.SpindleSets(ss).Freq_mean;
    Sp_FreqSDEditField(ss).Value = obj.SpindleSets(ss).Freq_sd;
    Sp_AmpMeanEditField(ss).Value = obj.SpindleSets(ss).Amp_mean;
    Sp_AmpSDEditField(ss).Value = obj.SpindleSets(ss).Amp_sd;
    Sp_DurMeanEditField(ss).Value = obj.SpindleSets(ss).Dur_mean;
    Sp_DurSDEditField(ss).Value = obj.SpindleSets(ss).Dur_sd;
    Sp_BaselineRateEditField(ss).Value = obj.SpindleSets(ss).Baseline_rate;
    Sp_StartTimeEditField(ss).Value = obj.SpindleSets(ss).Start_time;
    Sp_PhasePrefEditField(ss).Value = obj.SpindleSets(ss).Phase_pref;
    Sp_ModulationFactEditField(ss).Value = obj.SpindleSets(ss).Modulation_factor;
    % Sp_ControlPointsEditField(ss).Value = obj.SpindleSets(ss).Ctrl_pts;
    % Sp_SplineThetaEditField(ss).Value = obj.SpindleSets(ss).Theta_spline;
    Sp_MaxTimeEditField(ss).Value = obj.SpindleSets(ss).Spline_tmax;
    Sp_TensionEditField(ss).Value = obj.SpindleSets(ss).Tension;
    
    % Sp_DurMinEditField(ss).Value = obj.SpindleSets(ss).Dur_min;
    % Sp_AmpMinEditField(ss).Value = obj.SpindleSets(ss).Amp_min;
end


spindleCallback = {@updateSpindles, obj, Sp_TensionEditField, Sp_MaxTimeEditField, Sp_PhasePrefEditField, ...
    Sp_SplineThetaEditField, Sp_ControlPointsEditField, Sp_ModulationFactEditField, Sp_StartTimeEditField,...
    Sp_BaselineRateEditField, Sp_DurSDEditField, Sp_DurMeanEditField, Sp_FreqMeanEditField, Sp_AmpSDEditField,...
    Sp_AmpMeanEditField, Sp_FreqSDEditField};

for ss = 1:length(obj.SpindleSets)
    Sp_TensionEditField(ss).ValueChangedFcn = spindleCallback;
    Sp_MaxTimeEditField(ss).ValueChangedFcn = spindleCallback;
    Sp_PhasePrefEditField(ss).ValueChangedFcn = spindleCallback;
    Sp_SplineThetaEditField(ss).ValueChangedFcn = spindleCallback;
    Sp_ControlPointsEditField(ss).ValueChangedFcn = spindleCallback;
    Sp_ModulationFactEditField(ss).ValueChangedFcn = spindleCallback;
    Sp_StartTimeEditField(ss).ValueChangedFcn = spindleCallback;
    Sp_BaselineRateEditField(ss).ValueChangedFcn = spindleCallback;
    Sp_DurSDEditField(ss).ValueChangedFcn = spindleCallback;
    Sp_DurMeanEditField(ss).ValueChangedFcn = spindleCallback;
    Sp_FreqMeanEditField(ss).ValueChangedFcn = spindleCallback;
    Sp_AmpSDEditField(ss).ValueChangedFcn = spindleCallback;
    Sp_AmpMeanEditField(ss).ValueChangedFcn = spindleCallback;
    Sp_FreqSDEditField(ss).ValueChangedFcn = spindleCallback;
end

% Show the figure after all components are created
UIFigure.Visible = 'on';

function updateAperiodic(~,~,obj, alphafield, magfield)
obj.Aperiodic.Alpha = alphafield.Value;
obj.Aperiodic.Magnitude = magfield.Value;
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

function updateSpindles(~,~,obj, Sp_TensionEditField, Sp_MaxTimeEditField, Sp_PhasePrefEditField, ...
    Sp_SplineThetaEditField, Sp_ControlPointsEditField, Sp_ModulationFactEditField, Sp_StartTimeEditField,...
    Sp_BaselineRateEditField, Sp_DurSDEditField, Sp_DurMeanEditField, Sp_FreqMeanEditField, Sp_AmpSDEditField,...
    Sp_AmpMeanEditField, Sp_FreqSDEditField)

for ss = 1:length(obj.SpindleSets)
    obj.SpindleSets(ss).Freq_mean = Sp_FreqMeanEditField(ss).Value;
    obj.SpindleSets(ss).Freq_sd = Sp_FreqSDEditField(ss).Value;
    obj.SpindleSets(ss).Amp_mean = Sp_AmpMeanEditField(ss).Value;
    obj.SpindleSets(ss).Amp_sd = Sp_AmpSDEditField(ss).Value;
    obj.SpindleSets(ss).Dur_mean = Sp_DurMeanEditField(ss).Value;
    obj.SpindleSets(ss).Dur_sd = Sp_DurSDEditField(ss).Value;
    obj.SpindleSets(ss).Baseline_rate = Sp_BaselineRateEditField(ss).Value;
    obj.SpindleSets(ss).Start_time = Sp_StartTimeEditField(ss).Value;
    obj.SpindleSets(ss).Phase_pref = Sp_PhasePrefEditField(ss).Value;
    obj.SpindleSets(ss).Modulation_factor = Sp_ModulationFactEditField(ss).Value;
    obj.SpindleSets(ss).Ctrl_pts = Sp_ControlPointsEditField(ss).Value;
    obj.SpindleSets(ss).Theta_spline = Sp_SplineThetaEditField(ss).Value;
    obj.SpindleSets(ss).Spline_tmax = Sp_MaxTimeEditField(ss).Value;
    obj.SpindleSets(ss).Tension = Sp_TensionEditField(ss).Value;



    % obj.SpindleSets(ss).Dur_min =
    % obj.SpindleSets(ss).Amp_min =
end
end






