classdef app1_converted_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        LeftPanel                       matlab.ui.container.Panel
        RightPanel                      matlab.ui.container.Panel
        TabGroup                        matlab.ui.container.TabGroup
        AperiodicEEGTab                 matlab.ui.container.Tab
        Ap_AlphaEditField               matlab.ui.control.NumericEditField
        Ap_AlphaEditFieldLabel             matlab.ui.control.Label
        Ap_MagnitudeEditField           matlab.ui.control.NumericEditField
        Ap_MagnitudeEditFieldLabel         matlab.ui.control.Label
        BandPowerTab                    matlab.ui.container.Tab
        Band_FreqEditField              matlab.ui.control.NumericEditField
        Band_FreqRangeLabel                  matlab.ui.control.Label
        Band_AmpEditField               matlab.ui.control.NumericEditField
        Band_AmplitudeLabel                  matlab.ui.control.Label
        SlowWavesTab                    matlab.ui.container.Tab
        SW_RateEditField                matlab.ui.control.NumericEditField
        SW_RateEditFieldLabel            matlab.ui.control.Label
        SW_DurSDEditField               matlab.ui.control.NumericEditField
        SW_DurSDEditFieldLabel           matlab.ui.control.Label
        SW_DurMeanEditField             matlab.ui.control.NumericEditField
        SW_DurMeanEditFieldLabel         matlab.ui.control.Label
        SW_AmpSDEditField               matlab.ui.control.NumericEditField
        SW_AmpSDEditFieldLabel           matlab.ui.control.Label
        SW_AmpMeanEditField             matlab.ui.control.NumericEditField
        SW_AmpMeanEditFieldLabel         matlab.ui.control.Label
        SpindlesTab                     matlab.ui.container.Tab
        Spindle_TensionEditField        matlab.ui.control.NumericEditField
        Spindle_TensionEditFieldLabel           matlab.ui.control.Label
        Spindle_MaxTimeEditField        matlab.ui.control.NumericEditField
        Spindle_MaxTimeEditFieldLabel           matlab.ui.control.Label
        Spindle_PhasePrefEditField      matlab.ui.control.NumericEditField
        Spindle_PhasePrefEditFieldLabel         matlab.ui.control.Label
        Spindle_SplineThetaEditField    matlab.ui.control.NumericEditField
        Spindle_SplineThetaEditFieldLabel       matlab.ui.control.Label
        Spindle_ControlPointsEditField  matlab.ui.control.NumericEditField
        Spindle_ControlPointsEditFieldLabel     matlab.ui.control.Label
        Spindle_Spindle_ModulationFactEditField  matlab.ui.control.NumericEditField
        Spindle_ModulationFactEditFieldLabel    matlab.ui.control.Label
        Spindle_StartTimeEditField      matlab.ui.control.NumericEditField
        Spindle_StartTimeEditFieldLabel         matlab.ui.control.Label
        Spindle_BaselineRateEditField   matlab.ui.control.NumericEditField
        Spindle_BaselineRateEditFieldLabel      matlab.ui.control.Label
        Spindle_DurSDEditField          matlab.ui.control.NumericEditField
        Spindle_DurSDEditFieldLabel           matlab.ui.control.Label
        Spindle_DurMeanEditField        matlab.ui.control.NumericEditField
        Spindle_DurMeanEditFieldLabel         matlab.ui.control.Label
        Spindle_FreqMeanEditField       matlab.ui.control.NumericEditField
        Spindle_FreqMeanEditFieldLabel          matlab.ui.control.Label
        Spindle_AmpSDEditField          matlab.ui.control.NumericEditField
        Spindle_AmpSDEditFieldLabel           matlab.ui.control.Label
        Spindle_AmpMeanEditField        matlab.ui.control.NumericEditField
        Spindle_AmpMeanEditFieldLabel         matlab.ui.control.Label
        Spindle_FreqSDEditField         matlab.ui.control.NumericEditField
        Spindle_FreqSDEditFieldLabel            matlab.ui.control.Label
        LineNoiseTab                    matlab.ui.container.Tab
        Ln_WaveformDropDown             matlab.ui.control.DropDown
        Ln_WaveformDropDownLabel           matlab.ui.control.Label
        Ln_AmpSDEditField               matlab.ui.control.NumericEditField
        Ln_AmpSDEditFieldLabel         matlab.ui.control.Label
        Ln_AmpMeanEditField             matlab.ui.control.NumericEditField
        Ln_AmpMeanEditFieldLabel       matlab.ui.control.Label
        ArtifactsTab                    matlab.ui.container.Tab
        Art_RateEditField               matlab.ui.control.NumericEditField
        Art_RateEditFieldLabel            matlab.ui.control.Label
        Art_AmpMinEditField             matlab.ui.control.NumericEditField
        Art_AmpMinEditFieldLabel            matlab.ui.control.Label
        Art_AmpSDEditField              matlab.ui.control.NumericEditField
        Art_AmpSDEditFieldLabel           matlab.ui.control.Label
        Art_AmpMeanEditField            matlab.ui.control.NumericEditField
        Art_AmpMeanEditFieldLabel         matlab.ui.control.Label
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {494, 494};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {332, '1x'};
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 2;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [100 100 964 494];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {332, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Create TabGroup
            app.TabGroup = uitabgroup(app.RightPanel);
            app.TabGroup.Position = [1 54 631 440];

            % Create AperiodicEEGTab
            app.AperiodicEEGTab = uitab(app.TabGroup);
            app.AperiodicEEGTab.Title = 'Aperiodic EEG';

            % Create MagnitudeEditFieldLabel
            app.Ap_MagnitudeEditFieldLabel = uilabel(app.AperiodicEEGTab);
            app.Ap_MagnitudeEditFieldLabel.HorizontalAlignment = 'right';
            app.Ap_MagnitudeEditFieldLabel.Position = [20 345 62 22];
            app.Ap_MagnitudeEditFieldLabel.Text = 'Magnitude';

            % Create Ap_MagnitudeEditField
            app.Ap_MagnitudeEditField = uieditfield(app.AperiodicEEGTab, 'numeric');
            app.Ap_MagnitudeEditField.Position = [123 345 103 22];

            % Create AlphaEditFieldLabel
            app.Ap_AlphaEditFieldLabel = uilabel(app.AperiodicEEGTab);
            app.Ap_AlphaEditFieldLabel.HorizontalAlignment = 'right';
            app.Ap_AlphaEditFieldLabel.Position = [18 377 64 22];
            app.Ap_AlphaEditFieldLabel.Text = 'Alpha';

            % Create Ap_AlphaEditField
            app.Ap_AlphaEditField = uieditfield(app.AperiodicEEGTab, 'numeric');
            app.Ap_AlphaEditField.Position = [123 377 103 22];

            % Create BandPowerTab
            app.BandPowerTab = uitab(app.TabGroup);
            app.BandPowerTab.Title = 'Band Power';

            % Create AmplitudeLabel
            app.Band_AmplitudeLabel = uilabel(app.BandPowerTab);
            app.Band_AmplitudeLabel.HorizontalAlignment = 'right';
            app.Band_AmplitudeLabel.Position = [23 345 59 22];
            app.Band_AmplitudeLabel.Text = 'Amplitude';

            % Create Band_AmpEditField
            app.Band_AmpEditField = uieditfield(app.BandPowerTab, 'numeric');
            app.Band_AmpEditField.Position = [123 345 103 22];

            % Create FreqRangeLabel
            app.Band_FreqRangeLabel = uilabel(app.BandPowerTab);
            app.Band_FreqRangeLabel.HorizontalAlignment = 'right';
            app.Band_FreqRangeLabel.Position = [11 377 71 22];
            app.Band_FreqRangeLabel.Text = 'Freq. Range';

            % Create Band_FreqEditField
            app.Band_FreqEditField = uieditfield(app.BandPowerTab, 'numeric');
            app.Band_FreqEditField.Position = [123 377 103 22];

            % Create SlowWavesTab
            app.SlowWavesTab = uitab(app.TabGroup);
            app.SlowWavesTab.Title = 'Slow Waves';

            % Create AmpMeanEditField_3Label
            app.SW_AmpMeanEditFieldLabel = uilabel(app.SlowWavesTab);
            app.SW_AmpMeanEditFieldLabel.HorizontalAlignment = 'right';
            app.SW_AmpMeanEditFieldLabel.Position = [15 345 67 22];
            app.SW_AmpMeanEditFieldLabel.Text = 'Amp. Mean';

            % Create SW_AmpMeanEditField
            app.SW_AmpMeanEditField = uieditfield(app.SlowWavesTab, 'numeric');
            app.SW_AmpMeanEditField.Position = [123 345 103 22];

            % Create AmpSDEditField_3Label
            app.SW_AmpSDEditFieldLabel = uilabel(app.SlowWavesTab);
            app.SW_AmpSDEditFieldLabel.HorizontalAlignment = 'right';
            app.SW_AmpSDEditFieldLabel.Position = [29 313 53 22];
            app.SW_AmpSDEditFieldLabel.Text = 'Amp. SD';

            % Create SW_AmpSDEditField
            app.SW_AmpSDEditField = uieditfield(app.SlowWavesTab, 'numeric');
            app.SW_AmpSDEditField.Position = [123 313 103 22];

            % Create DurMeanEditField_2Label
            app.SW_DurMeanEditFieldLabel = uilabel(app.SlowWavesTab);
            app.SW_DurMeanEditFieldLabel.HorizontalAlignment = 'right';
            app.SW_DurMeanEditFieldLabel.Position = [22 278 60 22];
            app.SW_DurMeanEditFieldLabel.Text = 'Dur. Mean';

            % Create SW_DurMeanEditField
            app.SW_DurMeanEditField = uieditfield(app.SlowWavesTab, 'numeric');
            app.SW_DurMeanEditField.Position = [123 278 103 22];

            % Create DurSDEditField_2Label
            app.SW_DurSDEditFieldLabel = uilabel(app.SlowWavesTab);
            app.SW_DurSDEditFieldLabel.HorizontalAlignment = 'right';
            app.SW_DurSDEditFieldLabel.Position = [36 246 46 22];
            app.SW_DurSDEditFieldLabel.Text = 'Dur. SD';

            % Create SW_DurSDEditField
            app.SW_DurSDEditField = uieditfield(app.SlowWavesTab, 'numeric');
            app.SW_DurSDEditField.Position = [123 246 103 22];

            % Create RateEditField_5Label
            app.SW_RateEditFieldLabel = uilabel(app.SlowWavesTab);
            app.SW_RateEditFieldLabel.HorizontalAlignment = 'right';
            app.SW_RateEditFieldLabel.Position = [18 377 64 22];
            app.SW_RateEditFieldLabel.Text = 'Rate';

            % Create SW_RateEditField
            app.SW_RateEditField = uieditfield(app.SlowWavesTab, 'numeric');
            app.SW_RateEditField.Position = [123 377 103 22];

            % Create SpindlesTab
            app.SpindlesTab = uitab(app.TabGroup);
            app.SpindlesTab.Title = 'Spindles';

            % Create FreqSDEditFieldLabel
            app.Spindle_FreqSDEditFieldLabel = uilabel(app.SpindlesTab);
            app.Spindle_FreqSDEditFieldLabel.HorizontalAlignment = 'right';
            app.Spindle_FreqSDEditFieldLabel.Position = [30 345 52 22];
            app.Spindle_FreqSDEditFieldLabel.Text = 'Freq. SD';

            % Create Spindle_FreqSDEditField
            app.Spindle_FreqSDEditField = uieditfield(app.SpindlesTab, 'numeric');
            app.Spindle_FreqSDEditField.Position = [123 345 103 22];

            % Create AmpMeanEditField_4Label
            app.Spindle_AmpMeanEditFieldLabel = uilabel(app.SpindlesTab);
            app.Spindle_AmpMeanEditFieldLabel.HorizontalAlignment = 'right';
            app.Spindle_AmpMeanEditFieldLabel.Position = [15 313 67 22];
            app.Spindle_AmpMeanEditFieldLabel.Text = 'Amp. Mean';

            % Create Spindle_AmpMeanEditField
            app.Spindle_AmpMeanEditField = uieditfield(app.SpindlesTab, 'numeric');
            app.Spindle_AmpMeanEditField.Position = [123 313 103 22];

            % Create AmpSDEditField_4Label
            app.Spindle_AmpSDEditFieldLabel = uilabel(app.SpindlesTab);
            app.Spindle_AmpSDEditFieldLabel.HorizontalAlignment = 'right';
            app.Spindle_AmpSDEditFieldLabel.Position = [29 278 53 22];
            app.Spindle_AmpSDEditFieldLabel.Text = 'Amp. SD';

            % Create Spindle_AmpSDEditField
            app.Spindle_AmpSDEditField = uieditfield(app.SpindlesTab, 'numeric');
            app.Spindle_AmpSDEditField.Position = [123 278 103 22];

            % Create FreqMeanEditFieldLabel
            app.Spindle_FreqMeanEditFieldLabel = uilabel(app.SpindlesTab);
            app.Spindle_FreqMeanEditFieldLabel.HorizontalAlignment = 'right';
            app.Spindle_FreqMeanEditFieldLabel.Position = [16 377 66 22];
            app.Spindle_FreqMeanEditFieldLabel.Text = 'Freq. Mean';

            % Create Spindle_FreqMeanEditField
            app.Spindle_FreqMeanEditField = uieditfield(app.SpindlesTab, 'numeric');
            app.Spindle_FreqMeanEditField.Position = [123 377 103 22];

            % Create DurMeanEditField_3Label
            app.Spindle_DurMeanEditFieldLabel = uilabel(app.SpindlesTab);
            app.Spindle_DurMeanEditFieldLabel.HorizontalAlignment = 'right';
            app.Spindle_DurMeanEditFieldLabel.Position = [23 246 60 22];
            app.Spindle_DurMeanEditFieldLabel.Text = 'Dur. Mean';

            % Create Spindle_DurMeanEditField
            app.Spindle_DurMeanEditField = uieditfield(app.SpindlesTab, 'numeric');
            app.Spindle_DurMeanEditField.Position = [124 246 103 22];

            % Create DurSDEditField_3Label
            app.Spindle_DurSDEditFieldLabel = uilabel(app.SpindlesTab);
            app.Spindle_DurSDEditFieldLabel.HorizontalAlignment = 'right';
            app.Spindle_DurSDEditFieldLabel.Position = [37 211 46 22];
            app.Spindle_DurSDEditFieldLabel.Text = 'Dur. SD';

            % Create Spindle_DurSDEditField
            app.Spindle_DurSDEditField = uieditfield(app.SpindlesTab, 'numeric');
            app.Spindle_DurSDEditField.Position = [124 211 103 22];

            % Create BaselineRateEditFieldLabel
            app.Spindle_BaselineRateEditFieldLabel = uilabel(app.SpindlesTab);
            app.Spindle_BaselineRateEditFieldLabel.HorizontalAlignment = 'right';
            app.Spindle_BaselineRateEditFieldLabel.Position = [5 164 79 22];
            app.Spindle_BaselineRateEditFieldLabel.Text = 'Baseline Rate';

            % Create Spindle_BaselineRateEditField
            app.Spindle_BaselineRateEditField = uieditfield(app.SpindlesTab, 'numeric');
            app.Spindle_BaselineRateEditField.Position = [125 164 103 22];

            % Create StartTimeEditFieldLabel
            app.Spindle_StartTimeEditFieldLabel = uilabel(app.SpindlesTab);
            app.Spindle_StartTimeEditFieldLabel.HorizontalAlignment = 'right';
            app.Spindle_StartTimeEditFieldLabel.Position = [24 129 60 22];
            app.Spindle_StartTimeEditFieldLabel.Text = 'Start Time';

            % Create Spindle_StartTimeEditField
            app.Spindle_StartTimeEditField = uieditfield(app.SpindlesTab, 'numeric');
            app.Spindle_StartTimeEditField.Position = [125 129 103 22];

            % Create ModulationFactEditFieldLabel
            app.Spindle_ModulationFactEditFieldLabel = uilabel(app.SpindlesTab);
            app.Spindle_ModulationFactEditFieldLabel.HorizontalAlignment = 'right';
            app.Spindle_ModulationFactEditFieldLabel.Position = [232 345 95 22];
            app.Spindle_ModulationFactEditFieldLabel.Text = 'Modulation Fact.';

            % Create Spindle_ModulationFactEditField
            app.Spindle_Spindle_ModulationFactEditField = uieditfield(app.SpindlesTab, 'numeric');
            app.Spindle_Spindle_ModulationFactEditField.Position = [368 345 103 22];

            % Create ControlPointsEditFieldLabel
            app.Spindle_ControlPointsEditFieldLabel = uilabel(app.SpindlesTab);
            app.Spindle_ControlPointsEditFieldLabel.HorizontalAlignment = 'right';
            app.Spindle_ControlPointsEditFieldLabel.Position = [248 278 81 22];
            app.Spindle_ControlPointsEditFieldLabel.Text = 'Control Points';

            % Create Spindle_ControlPointsEditField
            app.Spindle_ControlPointsEditField = uieditfield(app.SpindlesTab, 'numeric');
            app.Spindle_ControlPointsEditField.Position = [370 278 103 22];

            % Create SplineThetaEditFieldLabel
            app.Spindle_SplineThetaEditFieldLabel = uilabel(app.SpindlesTab);
            app.Spindle_SplineThetaEditFieldLabel.HorizontalAlignment = 'right';
            app.Spindle_SplineThetaEditFieldLabel.Position = [257 243 72 22];
            app.Spindle_SplineThetaEditFieldLabel.Text = 'Spline Theta';

            % Create Spindle_SplineThetaEditField
            app.Spindle_SplineThetaEditField = uieditfield(app.SpindlesTab, 'numeric');
            app.Spindle_SplineThetaEditField.Position = [370 243 103 22];

            % Create PhasePrefEditFieldLabel
            app.Spindle_PhasePrefEditFieldLabel = uilabel(app.SpindlesTab);
            app.Spindle_PhasePrefEditFieldLabel.HorizontalAlignment = 'right';
            app.Spindle_PhasePrefEditFieldLabel.Position = [260 377 67 22];
            app.Spindle_PhasePrefEditFieldLabel.Text = 'Phase Pref.';

            % Create Spindle_PhasePrefEditField
            app.Spindle_PhasePrefEditField = uieditfield(app.SpindlesTab, 'numeric');
            app.Spindle_PhasePrefEditField.Position = [368 377 103 22];

            % Create MaxTimeEditFieldLabel
            app.Spindle_MaxTimeEditFieldLabel = uilabel(app.SpindlesTab);
            app.Spindle_MaxTimeEditFieldLabel.HorizontalAlignment = 'right';
            app.Spindle_MaxTimeEditFieldLabel.Position = [272 211 58 22];
            app.Spindle_MaxTimeEditFieldLabel.Text = 'Max Time';

            % Create Spindle_MaxTimeEditField
            app.Spindle_MaxTimeEditField = uieditfield(app.SpindlesTab, 'numeric');
            app.Spindle_MaxTimeEditField.Position = [371 211 103 22];

            % Create TensionEditFieldLabel
            app.Spindle_TensionEditFieldLabel = uilabel(app.SpindlesTab);
            app.Spindle_TensionEditFieldLabel.HorizontalAlignment = 'right';
            app.Spindle_TensionEditFieldLabel.Position = [284 176 46 22];
            app.Spindle_TensionEditFieldLabel.Text = 'Tension';

            % Create Spindle_TensionEditField
            app.Spindle_TensionEditField = uieditfield(app.SpindlesTab, 'numeric');
            app.Spindle_TensionEditField.Position = [371 176 103 22];

            % Create LineNoiseTab
            app.LineNoiseTab = uitab(app.TabGroup);
            app.LineNoiseTab.Title = 'Line Noise';

            % Create AmpMeanEditField_3Label_2
            app.Ln_AmpMeanEditFieldLabel = uilabel(app.LineNoiseTab);
            app.Ln_AmpMeanEditFieldLabel.HorizontalAlignment = 'right';
            app.Ln_AmpMeanEditFieldLabel.Position = [21 345 61 22];
            app.Ln_AmpMeanEditFieldLabel.Text = 'Frequency';

            % Create Ln_AmpMeanEditField
            app.Ln_AmpMeanEditField = uieditfield(app.LineNoiseTab, 'numeric');
            app.Ln_AmpMeanEditField.Position = [123 345 103 22];

            % Create AmpSDEditField_3Label_2
            app.Ln_AmpSDEditFieldLabel = uilabel(app.LineNoiseTab);
            app.Ln_AmpSDEditFieldLabel.HorizontalAlignment = 'right';
            app.Ln_AmpSDEditFieldLabel.Position = [29 313 53 22];
            app.Ln_AmpSDEditFieldLabel.Text = 'Amp. SD';

            % Create Ln_AmpSDEditField
            app.Ln_AmpSDEditField = uieditfield(app.LineNoiseTab, 'numeric');
            app.Ln_AmpSDEditField.Position = [123 313 103 22];

            % Create WaveformDropDownLabel
            app.Ln_WaveformDropDownLabel = uilabel(app.LineNoiseTab);
            app.Ln_WaveformDropDownLabel.HorizontalAlignment = 'right';
            app.Ln_WaveformDropDownLabel.Position = [23 377 59 22];
            app.Ln_WaveformDropDownLabel.Text = 'Waveform';

            % Create Ln_WaveformDropDown
            app.Ln_WaveformDropDown = uidropdown(app.LineNoiseTab);
            app.Ln_WaveformDropDown.Items = {'Sin', 'Sawtooth', 'Square'};
            app.Ln_WaveformDropDown.Position = [123 377 103 22];
            app.Ln_WaveformDropDown.Value = 'Sin';

            % Create ArtifactsTab
            app.ArtifactsTab = uitab(app.TabGroup);
            app.ArtifactsTab.Title = 'Artifacts';

            % Create AmpMeanEditField_2Label
            app.Art_AmpMeanEditFieldLabel = uilabel(app.ArtifactsTab);
            app.Art_AmpMeanEditFieldLabel.HorizontalAlignment = 'right';
            app.Art_AmpMeanEditFieldLabel.Position = [15 345 67 22];
            app.Art_AmpMeanEditFieldLabel.Text = 'Amp. Mean';

            % Create Art_AmpMeanEditField
            app.Art_AmpMeanEditField = uieditfield(app.ArtifactsTab, 'numeric');
            app.Art_AmpMeanEditField.Position = [123 345 103 22];

            % Create AmpSDEditField_2Label
            app.Art_AmpSDEditFieldLabel = uilabel(app.ArtifactsTab);
            app.Art_AmpSDEditFieldLabel.HorizontalAlignment = 'right';
            app.Art_AmpSDEditFieldLabel.Position = [29 313 53 22];
            app.Art_AmpSDEditFieldLabel.Text = 'Amp. SD';

            % Create Art_AmpSDEditField
            app.Art_AmpSDEditField = uieditfield(app.ArtifactsTab, 'numeric');
            app.Art_AmpSDEditField.Position = [123 313 103 22];

            % Create AmpMinEditFieldLabel
            app.Art_AmpMinEditFieldLabel = uilabel(app.ArtifactsTab);
            app.Art_AmpMinEditFieldLabel.HorizontalAlignment = 'right';
            app.Art_AmpMinEditFieldLabel.Position = [25 278 57 22];
            app.Art_AmpMinEditFieldLabel.Text = 'Amp. Min';

            % Create Art_AmpMinEditField
            app.Art_AmpMinEditField = uieditfield(app.ArtifactsTab, 'numeric');
            app.Art_AmpMinEditField.Position = [123 278 103 22];

            % Create RateEditField_4Label
            app.Art_RateEditFieldLabel = uilabel(app.ArtifactsTab);
            app.Art_RateEditFieldLabel.HorizontalAlignment = 'right';
            app.Art_RateEditFieldLabel.Position = [18 377 64 22];
            app.Art_RateEditFieldLabel.Text = 'Rate';

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
        function app = app1_converted_exported

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