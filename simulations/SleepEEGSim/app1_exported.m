classdef app1_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        TabGroup                        matlab.ui.container.TabGroup
        AperiodicEEGTab                 matlab.ui.container.Tab
        Ap_AlphaEditField               matlab.ui.control.NumericEditField
        AlphaEditFieldLabel             matlab.ui.control.Label
        Ap_MagnitudeEditField           matlab.ui.control.NumericEditField
        MagnitudeEditFieldLabel         matlab.ui.control.Label
        BandPowerTab                    matlab.ui.container.Tab
        Band_FreqEditField              matlab.ui.control.NumericEditField
        FreqRangeLabel                  matlab.ui.control.Label
        Band_AmpEditField               matlab.ui.control.NumericEditField
        AmplitudeLabel                  matlab.ui.control.Label
        SlowWavesTab                    matlab.ui.container.Tab
        SW_RateEditField                matlab.ui.control.NumericEditField
        RateEditField_5Label            matlab.ui.control.Label
        SW_DurSDEditField               matlab.ui.control.NumericEditField
        DurSDEditField_2Label           matlab.ui.control.Label
        SW_DurMeanEditField             matlab.ui.control.NumericEditField
        DurMeanEditField_2Label         matlab.ui.control.Label
        SW_AmpSDEditField               matlab.ui.control.NumericEditField
        AmpSDEditField_3Label           matlab.ui.control.Label
        SW_AmpMeanEditField             matlab.ui.control.NumericEditField
        AmpMeanEditField_3Label         matlab.ui.control.Label
        SpindlesTab                     matlab.ui.container.Tab
        Spindle_TensionEditField        matlab.ui.control.NumericEditField
        TensionEditFieldLabel           matlab.ui.control.Label
        Spindle_MaxTimeEditField        matlab.ui.control.NumericEditField
        MaxTimeEditFieldLabel           matlab.ui.control.Label
        Spindle_PhasePrefEditField      matlab.ui.control.NumericEditField
        PhasePrefEditFieldLabel         matlab.ui.control.Label
        Spindle_SplineThetaEditField    matlab.ui.control.NumericEditField
        SplineThetaEditFieldLabel       matlab.ui.control.Label
        Spindle_ControlPointsEditField  matlab.ui.control.NumericEditField
        ControlPointsEditFieldLabel     matlab.ui.control.Label
        Spindle_ModulationFactEditField  matlab.ui.control.NumericEditField
        ModulationFactEditFieldLabel    matlab.ui.control.Label
        Spindle_StartTimeEditField      matlab.ui.control.NumericEditField
        StartTimeEditFieldLabel         matlab.ui.control.Label
        Spindle_BaselineRateEditField   matlab.ui.control.NumericEditField
        BaselineRateEditFieldLabel      matlab.ui.control.Label
        Spindle_DurSDEditField          matlab.ui.control.NumericEditField
        DurSDEditField_3Label           matlab.ui.control.Label
        Spindle_DurMeanEditField        matlab.ui.control.NumericEditField
        DurMeanEditField_3Label         matlab.ui.control.Label
        Spindle_FreqMeanEditField       matlab.ui.control.NumericEditField
        FreqMeanEditFieldLabel          matlab.ui.control.Label
        Spindle_AmpSDEditField          matlab.ui.control.NumericEditField
        AmpSDEditField_4Label           matlab.ui.control.Label
        Spindle_AmpMeanEditField        matlab.ui.control.NumericEditField
        AmpMeanEditField_4Label         matlab.ui.control.Label
        Spindle_FreqSDEditField         matlab.ui.control.NumericEditField
        FreqSDEditFieldLabel            matlab.ui.control.Label
        LineNoiseTab                    matlab.ui.container.Tab
        Ln_WaveformDropDown             matlab.ui.control.DropDown
        WaveformDropDownLabel           matlab.ui.control.Label
        Ln_AmpSDEditField               matlab.ui.control.NumericEditField
        AmpSDEditField_3Label_2         matlab.ui.control.Label
        Ln_AmpMeanEditField             matlab.ui.control.NumericEditField
        AmpMeanEditField_3Label_2       matlab.ui.control.Label
        ArtifactsTab                    matlab.ui.container.Tab
        Art_RateEditField               matlab.ui.control.NumericEditField
        RateEditField_4Label            matlab.ui.control.Label
        Art_AmpMinEditField             matlab.ui.control.NumericEditField
        AmpMinEditFieldLabel            matlab.ui.control.Label
        Art_AmpSDEditField              matlab.ui.control.NumericEditField
        AmpSDEditField_2Label           matlab.ui.control.Label
        Art_AmpMeanEditField            matlab.ui.control.NumericEditField
        AmpMeanEditField_2Label         matlab.ui.control.Label
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 964 494];
            app.UIFigure.Name = 'MATLAB App';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [2 55 963 440];

            % Create AperiodicEEGTab
            app.AperiodicEEGTab = uitab(app.TabGroup);
            app.AperiodicEEGTab.Title = 'Aperiodic EEG';

            % Create MagnitudeEditFieldLabel
            app.MagnitudeEditFieldLabel = uilabel(app.AperiodicEEGTab);
            app.MagnitudeEditFieldLabel.HorizontalAlignment = 'right';
            app.MagnitudeEditFieldLabel.Position = [20 345 62 22];
            app.MagnitudeEditFieldLabel.Text = 'Magnitude';

            % Create Ap_MagnitudeEditField
            app.Ap_MagnitudeEditField = uieditfield(app.AperiodicEEGTab, 'numeric');
            app.Ap_MagnitudeEditField.Position = [123 345 103 22];

            % Create AlphaEditFieldLabel
            app.AlphaEditFieldLabel = uilabel(app.AperiodicEEGTab);
            app.AlphaEditFieldLabel.HorizontalAlignment = 'right';
            app.AlphaEditFieldLabel.Position = [18 377 64 22];
            app.AlphaEditFieldLabel.Text = 'Alpha';

            % Create Ap_AlphaEditField
            app.Ap_AlphaEditField = uieditfield(app.AperiodicEEGTab, 'numeric');
            app.Ap_AlphaEditField.Position = [123 377 103 22];

            % Create BandPowerTab
            app.BandPowerTab = uitab(app.TabGroup);
            app.BandPowerTab.Title = 'Band Power';

            % Create AmplitudeLabel
            app.AmplitudeLabel = uilabel(app.BandPowerTab);
            app.AmplitudeLabel.HorizontalAlignment = 'right';
            app.AmplitudeLabel.Position = [23 345 59 22];
            app.AmplitudeLabel.Text = 'Amplitude';

            % Create Band_AmpEditField
            app.Band_AmpEditField = uieditfield(app.BandPowerTab, 'numeric');
            app.Band_AmpEditField.Position = [123 345 103 22];

            % Create FreqRangeLabel
            app.FreqRangeLabel = uilabel(app.BandPowerTab);
            app.FreqRangeLabel.HorizontalAlignment = 'right';
            app.FreqRangeLabel.Position = [11 377 71 22];
            app.FreqRangeLabel.Text = 'Freq. Range';

            % Create Band_FreqEditField
            app.Band_FreqEditField = uieditfield(app.BandPowerTab, 'numeric');
            app.Band_FreqEditField.Position = [123 377 103 22];

            % Create SlowWavesTab
            app.SlowWavesTab = uitab(app.TabGroup);
            app.SlowWavesTab.Title = 'Slow Waves';

            % Create AmpMeanEditField_3Label
            app.AmpMeanEditField_3Label = uilabel(app.SlowWavesTab);
            app.AmpMeanEditField_3Label.HorizontalAlignment = 'right';
            app.AmpMeanEditField_3Label.Position = [15 345 67 22];
            app.AmpMeanEditField_3Label.Text = 'Amp. Mean';

            % Create SW_AmpMeanEditField
            app.SW_AmpMeanEditField = uieditfield(app.SlowWavesTab, 'numeric');
            app.SW_AmpMeanEditField.Position = [123 345 103 22];

            % Create AmpSDEditField_3Label
            app.AmpSDEditField_3Label = uilabel(app.SlowWavesTab);
            app.AmpSDEditField_3Label.HorizontalAlignment = 'right';
            app.AmpSDEditField_3Label.Position = [29 313 53 22];
            app.AmpSDEditField_3Label.Text = 'Amp. SD';

            % Create SW_AmpSDEditField
            app.SW_AmpSDEditField = uieditfield(app.SlowWavesTab, 'numeric');
            app.SW_AmpSDEditField.Position = [123 313 103 22];

            % Create DurMeanEditField_2Label
            app.DurMeanEditField_2Label = uilabel(app.SlowWavesTab);
            app.DurMeanEditField_2Label.HorizontalAlignment = 'right';
            app.DurMeanEditField_2Label.Position = [22 278 60 22];
            app.DurMeanEditField_2Label.Text = 'Dur. Mean';

            % Create SW_DurMeanEditField
            app.SW_DurMeanEditField = uieditfield(app.SlowWavesTab, 'numeric');
            app.SW_DurMeanEditField.Position = [123 278 103 22];

            % Create DurSDEditField_2Label
            app.DurSDEditField_2Label = uilabel(app.SlowWavesTab);
            app.DurSDEditField_2Label.HorizontalAlignment = 'right';
            app.DurSDEditField_2Label.Position = [36 246 46 22];
            app.DurSDEditField_2Label.Text = 'Dur. SD';

            % Create SW_DurSDEditField
            app.SW_DurSDEditField = uieditfield(app.SlowWavesTab, 'numeric');
            app.SW_DurSDEditField.Position = [123 246 103 22];

            % Create RateEditField_5Label
            app.RateEditField_5Label = uilabel(app.SlowWavesTab);
            app.RateEditField_5Label.HorizontalAlignment = 'right';
            app.RateEditField_5Label.Position = [18 377 64 22];
            app.RateEditField_5Label.Text = 'Rate';

            % Create SW_RateEditField
            app.SW_RateEditField = uieditfield(app.SlowWavesTab, 'numeric');
            app.SW_RateEditField.Position = [123 377 103 22];

            % Create SpindlesTab
            app.SpindlesTab = uitab(app.TabGroup);
            app.SpindlesTab.Title = 'Spindles';

            % Create FreqSDEditFieldLabel
            app.FreqSDEditFieldLabel = uilabel(app.SpindlesTab);
            app.FreqSDEditFieldLabel.HorizontalAlignment = 'right';
            app.FreqSDEditFieldLabel.Position = [30 345 52 22];
            app.FreqSDEditFieldLabel.Text = 'Freq. SD';

            % Create Spindle_FreqSDEditField
            app.Spindle_FreqSDEditField = uieditfield(app.SpindlesTab, 'numeric');
            app.Spindle_FreqSDEditField.Position = [123 345 103 22];

            % Create AmpMeanEditField_4Label
            app.AmpMeanEditField_4Label = uilabel(app.SpindlesTab);
            app.AmpMeanEditField_4Label.HorizontalAlignment = 'right';
            app.AmpMeanEditField_4Label.Position = [15 313 67 22];
            app.AmpMeanEditField_4Label.Text = 'Amp. Mean';

            % Create Spindle_AmpMeanEditField
            app.Spindle_AmpMeanEditField = uieditfield(app.SpindlesTab, 'numeric');
            app.Spindle_AmpMeanEditField.Position = [123 313 103 22];

            % Create AmpSDEditField_4Label
            app.AmpSDEditField_4Label = uilabel(app.SpindlesTab);
            app.AmpSDEditField_4Label.HorizontalAlignment = 'right';
            app.AmpSDEditField_4Label.Position = [29 278 53 22];
            app.AmpSDEditField_4Label.Text = 'Amp. SD';

            % Create Spindle_AmpSDEditField
            app.Spindle_AmpSDEditField = uieditfield(app.SpindlesTab, 'numeric');
            app.Spindle_AmpSDEditField.Position = [123 278 103 22];

            % Create FreqMeanEditFieldLabel
            app.FreqMeanEditFieldLabel = uilabel(app.SpindlesTab);
            app.FreqMeanEditFieldLabel.HorizontalAlignment = 'right';
            app.FreqMeanEditFieldLabel.Position = [16 377 66 22];
            app.FreqMeanEditFieldLabel.Text = 'Freq. Mean';

            % Create Spindle_FreqMeanEditField
            app.Spindle_FreqMeanEditField = uieditfield(app.SpindlesTab, 'numeric');
            app.Spindle_FreqMeanEditField.Position = [123 377 103 22];

            % Create DurMeanEditField_3Label
            app.DurMeanEditField_3Label = uilabel(app.SpindlesTab);
            app.DurMeanEditField_3Label.HorizontalAlignment = 'right';
            app.DurMeanEditField_3Label.Position = [23 246 60 22];
            app.DurMeanEditField_3Label.Text = 'Dur. Mean';

            % Create Spindle_DurMeanEditField
            app.Spindle_DurMeanEditField = uieditfield(app.SpindlesTab, 'numeric');
            app.Spindle_DurMeanEditField.Position = [124 246 103 22];

            % Create DurSDEditField_3Label
            app.DurSDEditField_3Label = uilabel(app.SpindlesTab);
            app.DurSDEditField_3Label.HorizontalAlignment = 'right';
            app.DurSDEditField_3Label.Position = [37 211 46 22];
            app.DurSDEditField_3Label.Text = 'Dur. SD';

            % Create Spindle_DurSDEditField
            app.Spindle_DurSDEditField = uieditfield(app.SpindlesTab, 'numeric');
            app.Spindle_DurSDEditField.Position = [124 211 103 22];

            % Create BaselineRateEditFieldLabel
            app.BaselineRateEditFieldLabel = uilabel(app.SpindlesTab);
            app.BaselineRateEditFieldLabel.HorizontalAlignment = 'right';
            app.BaselineRateEditFieldLabel.Position = [5 164 79 22];
            app.BaselineRateEditFieldLabel.Text = 'Baseline Rate';

            % Create Spindle_BaselineRateEditField
            app.Spindle_BaselineRateEditField = uieditfield(app.SpindlesTab, 'numeric');
            app.Spindle_BaselineRateEditField.Position = [125 164 103 22];

            % Create StartTimeEditFieldLabel
            app.StartTimeEditFieldLabel = uilabel(app.SpindlesTab);
            app.StartTimeEditFieldLabel.HorizontalAlignment = 'right';
            app.StartTimeEditFieldLabel.Position = [24 129 60 22];
            app.StartTimeEditFieldLabel.Text = 'Start Time';

            % Create Spindle_StartTimeEditField
            app.Spindle_StartTimeEditField = uieditfield(app.SpindlesTab, 'numeric');
            app.Spindle_StartTimeEditField.Position = [125 129 103 22];

            % Create ModulationFactEditFieldLabel
            app.ModulationFactEditFieldLabel = uilabel(app.SpindlesTab);
            app.ModulationFactEditFieldLabel.HorizontalAlignment = 'right';
            app.ModulationFactEditFieldLabel.Position = [232 345 95 22];
            app.ModulationFactEditFieldLabel.Text = 'Modulation Fact.';

            % Create Spindle_ModulationFactEditField
            app.Spindle_ModulationFactEditField = uieditfield(app.SpindlesTab, 'numeric');
            app.Spindle_ModulationFactEditField.Position = [368 345 103 22];

            % Create ControlPointsEditFieldLabel
            app.ControlPointsEditFieldLabel = uilabel(app.SpindlesTab);
            app.ControlPointsEditFieldLabel.HorizontalAlignment = 'right';
            app.ControlPointsEditFieldLabel.Position = [248 278 81 22];
            app.ControlPointsEditFieldLabel.Text = 'Control Points';

            % Create Spindle_ControlPointsEditField
            app.Spindle_ControlPointsEditField = uieditfield(app.SpindlesTab, 'numeric');
            app.Spindle_ControlPointsEditField.Position = [370 278 103 22];

            % Create SplineThetaEditFieldLabel
            app.SplineThetaEditFieldLabel = uilabel(app.SpindlesTab);
            app.SplineThetaEditFieldLabel.HorizontalAlignment = 'right';
            app.SplineThetaEditFieldLabel.Position = [257 243 72 22];
            app.SplineThetaEditFieldLabel.Text = 'Spline Theta';

            % Create Spindle_SplineThetaEditField
            app.Spindle_SplineThetaEditField = uieditfield(app.SpindlesTab, 'numeric');
            app.Spindle_SplineThetaEditField.Position = [370 243 103 22];

            % Create PhasePrefEditFieldLabel
            app.PhasePrefEditFieldLabel = uilabel(app.SpindlesTab);
            app.PhasePrefEditFieldLabel.HorizontalAlignment = 'right';
            app.PhasePrefEditFieldLabel.Position = [260 377 67 22];
            app.PhasePrefEditFieldLabel.Text = 'Phase Pref.';

            % Create Spindle_PhasePrefEditField
            app.Spindle_PhasePrefEditField = uieditfield(app.SpindlesTab, 'numeric');
            app.Spindle_PhasePrefEditField.Position = [368 377 103 22];

            % Create MaxTimeEditFieldLabel
            app.MaxTimeEditFieldLabel = uilabel(app.SpindlesTab);
            app.MaxTimeEditFieldLabel.HorizontalAlignment = 'right';
            app.MaxTimeEditFieldLabel.Position = [272 211 58 22];
            app.MaxTimeEditFieldLabel.Text = 'Max Time';

            % Create Spindle_MaxTimeEditField
            app.Spindle_MaxTimeEditField = uieditfield(app.SpindlesTab, 'numeric');
            app.Spindle_MaxTimeEditField.Position = [371 211 103 22];

            % Create TensionEditFieldLabel
            app.TensionEditFieldLabel = uilabel(app.SpindlesTab);
            app.TensionEditFieldLabel.HorizontalAlignment = 'right';
            app.TensionEditFieldLabel.Position = [284 176 46 22];
            app.TensionEditFieldLabel.Text = 'Tension';

            % Create Spindle_TensionEditField
            app.Spindle_TensionEditField = uieditfield(app.SpindlesTab, 'numeric');
            app.Spindle_TensionEditField.Position = [371 176 103 22];

            % Create LineNoiseTab
            app.LineNoiseTab = uitab(app.TabGroup);
            app.LineNoiseTab.Title = 'Line Noise';

            % Create AmpMeanEditField_3Label_2
            app.AmpMeanEditField_3Label_2 = uilabel(app.LineNoiseTab);
            app.AmpMeanEditField_3Label_2.HorizontalAlignment = 'right';
            app.AmpMeanEditField_3Label_2.Position = [21 345 61 22];
            app.AmpMeanEditField_3Label_2.Text = 'Frequency';

            % Create Ln_AmpMeanEditField
            app.Ln_AmpMeanEditField = uieditfield(app.LineNoiseTab, 'numeric');
            app.Ln_AmpMeanEditField.Position = [123 345 103 22];

            % Create AmpSDEditField_3Label_2
            app.AmpSDEditField_3Label_2 = uilabel(app.LineNoiseTab);
            app.AmpSDEditField_3Label_2.HorizontalAlignment = 'right';
            app.AmpSDEditField_3Label_2.Position = [29 313 53 22];
            app.AmpSDEditField_3Label_2.Text = 'Amp. SD';

            % Create Ln_AmpSDEditField
            app.Ln_AmpSDEditField = uieditfield(app.LineNoiseTab, 'numeric');
            app.Ln_AmpSDEditField.Position = [123 313 103 22];

            % Create WaveformDropDownLabel
            app.WaveformDropDownLabel = uilabel(app.LineNoiseTab);
            app.WaveformDropDownLabel.HorizontalAlignment = 'right';
            app.WaveformDropDownLabel.Position = [23 377 59 22];
            app.WaveformDropDownLabel.Text = 'Waveform';

            % Create Ln_WaveformDropDown
            app.Ln_WaveformDropDown = uidropdown(app.LineNoiseTab);
            app.Ln_WaveformDropDown.Items = {'Sin', 'Sawtooth', 'Square'};
            app.Ln_WaveformDropDown.Position = [123 377 103 22];
            app.Ln_WaveformDropDown.Value = 'Sin';

            % Create ArtifactsTab
            app.ArtifactsTab = uitab(app.TabGroup);
            app.ArtifactsTab.Title = 'Artifacts';

            % Create AmpMeanEditField_2Label
            app.AmpMeanEditField_2Label = uilabel(app.ArtifactsTab);
            app.AmpMeanEditField_2Label.HorizontalAlignment = 'right';
            app.AmpMeanEditField_2Label.Position = [15 345 67 22];
            app.AmpMeanEditField_2Label.Text = 'Amp. Mean';

            % Create Art_AmpMeanEditField
            app.Art_AmpMeanEditField = uieditfield(app.ArtifactsTab, 'numeric');
            app.Art_AmpMeanEditField.Position = [123 345 103 22];

            % Create AmpSDEditField_2Label
            app.AmpSDEditField_2Label = uilabel(app.ArtifactsTab);
            app.AmpSDEditField_2Label.HorizontalAlignment = 'right';
            app.AmpSDEditField_2Label.Position = [29 313 53 22];
            app.AmpSDEditField_2Label.Text = 'Amp. SD';

            % Create Art_AmpSDEditField
            app.Art_AmpSDEditField = uieditfield(app.ArtifactsTab, 'numeric');
            app.Art_AmpSDEditField.Position = [123 313 103 22];

            % Create AmpMinEditFieldLabel
            app.AmpMinEditFieldLabel = uilabel(app.ArtifactsTab);
            app.AmpMinEditFieldLabel.HorizontalAlignment = 'right';
            app.AmpMinEditFieldLabel.Position = [25 278 57 22];
            app.AmpMinEditFieldLabel.Text = 'Amp. Min';

            % Create Art_AmpMinEditField
            app.Art_AmpMinEditField = uieditfield(app.ArtifactsTab, 'numeric');
            app.Art_AmpMinEditField.Position = [123 278 103 22];

            % Create RateEditField_4Label
            app.RateEditField_4Label = uilabel(app.ArtifactsTab);
            app.RateEditField_4Label.HorizontalAlignment = 'right';
            app.RateEditField_4Label.Position = [18 377 64 22];
            app.RateEditField_4Label.Text = 'Rate';

            % Create Art_RateEditField
            app.Art_RateEditField = uieditfield(app.ArtifactsTab, 'numeric');
            app.Art_RateEditField.Position = [123 377 103 22];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = app1_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end