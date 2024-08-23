classdef SimApp_exported < matlabsBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        SimulationOptionsMenu           matlab.ui.container.Menu
        PlotSimulationMenu              matlab.ui.container.Menu
        PlotComponentsMenu              matlab.ui.container.Menu
        PlotSpectrumMenu                matlab.ui.container.Menu
        SetActiveComponentsMenu         matlab.ui.container.Menu
        ResimulateMenu                  matlab.ui.container.Menu
        AddComponentMenu                matlab.ui.container.Menu
        AperiodicMenu                   matlab.ui.container.Menu
        SlowWavesMenu                   matlab.ui.container.Menu
        SpindlesMenu                    matlab.ui.container.Menu
        LineNoiseMenu                   matlab.ui.container.Menu
        BandPowerMenu                   matlab.ui.container.Menu
        ArtifactsMenu                   matlab.ui.container.Menu
        RemoveComponentMenu             matlab.ui.container.Menu
        PlotButton                      matlab.ui.control.Button
        TabGroup                        matlab.ui.container.TabGroup
        AperiodicEEGTab                 matlab.ui.container.Tab
        Ap_AlphaEditField               matlab.ui.control.NumericEditField
        AlphaEditFieldLabel             matlab.ui.control.Label
        Ap_MagnitudeEditField           matlab.ui.control.NumericEditField
        MagnitudeEditFieldLabel         matlab.ui.control.Label
        Aperiodic_UIAxes                matlab.ui.control.UIAxes
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
        Spindle_DurMinEditField         matlab.ui.control.NumericEditField
        AmpSDEditField_4Label_3         matlab.ui.control.Label
        Spindle_AmpMinEditField         matlab.ui.control.NumericEditField
        AmpSDEditField_4Label_2         matlab.ui.control.Label
        Spindle_SplineValueEditField    matlab.ui.control.EditField
        SplineValueEditFieldLabel       matlab.ui.control.Label
        Spindle_ControlPointsEditField  matlab.ui.control.EditField
        ControlPointsLabel              matlab.ui.control.Label
        Spindle_TensionEditField        matlab.ui.control.NumericEditField
        TensionEditFieldLabel           matlab.ui.control.Label
        Spindle_MaxTimeEditField        matlab.ui.control.NumericEditField
        MaxTimeEditFieldLabel           matlab.ui.control.Label
        Spindle_PhasePrefEditField      matlab.ui.control.NumericEditField
        PhasePrefEditFieldLabel         matlab.ui.control.Label
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
        Spindle_UIAxes                  matlab.ui.control.UIAxes
        LineNoiseTab                    matlab.ui.container.Tab
        Ln_WaveformDropDown             matlab.ui.control.DropDown
        WaveformDropDownLabel           matlab.ui.control.Label
        Ln_AmpSDEditField               matlab.ui.control.NumericEditField
        AmpSDEditField_3Label_2         matlab.ui.control.Label
        Ln_AmpMeanEditField             matlab.ui.control.NumericEditField
        AmpMeanEditField_3Label_2       matlab.ui.control.Label
        UIAxes                          matlab.ui.control.UIAxes
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

    % Callbacks that handle component events
    methods (Access = private)

        % Menu selected function: PlotSimulationMenu
        function asdfadsf(app, event)
            
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            UIFigure = uifigure('Visible', 'off');
            UIFigure.AutoResizeChildren = 'off';
            UIFigure.Position = [100 100 1125 633];
            UIFigure.Name = 'MATLAB App';
            UIFigure.Resize = 'off';

            % Create SimulationOptionsMenu
            SimulationOptionsMenu = uimenu(UIFigure);
            SimulationOptionsMenu.Text = 'Simulation Options';

            % Create PlotSimulationMenu
            PlotSimulationMenu = uimenu(SimulationOptionsMenu);
            PlotSimulationMenu.MenuSelectedFcn = createCallbackFcn(app, @asdfadsf, true);
            PlotSimulationMenu.Text = 'Plot Simulation';

            % Create PlotComponentsMenu
            PlotComponentsMenu = uimenu(SimulationOptionsMenu);
            PlotComponentsMenu.Text = 'Plot Components';

            % Create PlotSpectrumMenu
            PlotSpectrumMenu = uimenu(SimulationOptionsMenu);
            PlotSpectrumMenu.Text = 'Plot Spectrum';

            % Create SetActiveComponentsMenu
            SetActiveComponentsMenu = uimenu(SimulationOptionsMenu);
            SetActiveComponentsMenu.Text = 'Set Active Components...';

            % Create ResimulateMenu
            ResimulateMenu = uimenu(SimulationOptionsMenu);
            ResimulateMenu.Text = 'Resimulate';

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
            TabGroup.Position = [9 82 962 539];

            % Create AperiodicEEGTab
            AperiodicEEGTab = uitab(TabGroup);
            AperiodicEEGTab.AutoResizeChildren = 'off';
            AperiodicEEGTab.Title = 'Aperiodic EEG';

            % Create Aperiodic_UIAxes
            Aperiodic_UIAxes = uiaxes(AperiodicEEGTab);
            title(Aperiodic_UIAxes, 'Aperiodic EEG')
            xlabel(Aperiodic_UIAxes, 'Frequency (Hz)')
            ylabel(Aperiodic_UIAxes, 'Power (dB)')
            zlabel(Aperiodic_UIAxes, 'Z')
            Aperiodic_UIAxes.Position = [105 12 766 412];

            % Create MagnitudeEditFieldLabel
            MagnitudeEditFieldLabel = uilabel(AperiodicEEGTab);
            MagnitudeEditFieldLabel.HorizontalAlignment = 'right';
            MagnitudeEditFieldLabel.Position = [20 444 62 22];
            MagnitudeEditFieldLabel.Text = 'Magnitude';

            % Create Ap_MagnitudeEditField
            Ap_MagnitudeEditField = uieditfield(AperiodicEEGTab, 'numeric');
            Ap_MagnitudeEditField.Position = [123 444 103 22];

            % Create AlphaEditFieldLabel
            AlphaEditFieldLabel = uilabel(AperiodicEEGTab);
            AlphaEditFieldLabel.HorizontalAlignment = 'right';
            AlphaEditFieldLabel.Position = [18 476 64 22];
            AlphaEditFieldLabel.Text = 'Alpha';

            % Create Ap_AlphaEditField
            Ap_AlphaEditField = uieditfield(AperiodicEEGTab, 'numeric');
            Ap_AlphaEditField.Position = [123 476 103 22];

            % Create BandPowerTab
            BandPowerTab = uitab(TabGroup);
            BandPowerTab.AutoResizeChildren = 'off';
            BandPowerTab.Title = 'Band Power';

            % Create AmplitudeLabel
            AmplitudeLabel = uilabel(BandPowerTab);
            AmplitudeLabel.HorizontalAlignment = 'right';
            AmplitudeLabel.Position = [23 444 59 22];
            AmplitudeLabel.Text = 'Amplitude';

            % Create Band_AmpEditField
            Band_AmpEditField = uieditfield(BandPowerTab, 'numeric');
            Band_AmpEditField.Position = [123 444 103 22];

            % Create FreqRangeLabel
            FreqRangeLabel = uilabel(BandPowerTab);
            FreqRangeLabel.HorizontalAlignment = 'right';
            FreqRangeLabel.Position = [11 476 71 22];
            FreqRangeLabel.Text = 'Freq. Range';

            % Create Band_FreqEditField
            Band_FreqEditField = uieditfield(BandPowerTab, 'numeric');
            Band_FreqEditField.Position = [123 476 103 22];

            % Create SlowWavesTab
            SlowWavesTab = uitab(TabGroup);
            SlowWavesTab.AutoResizeChildren = 'off';
            SlowWavesTab.Title = 'Slow Waves';

            % Create AmpMeanEditField_3Label
            AmpMeanEditField_3Label = uilabel(SlowWavesTab);
            AmpMeanEditField_3Label.HorizontalAlignment = 'right';
            AmpMeanEditField_3Label.Position = [15 444 67 22];
            AmpMeanEditField_3Label.Text = 'Amp. Mean';

            % Create SW_AmpMeanEditField
            SW_AmpMeanEditField = uieditfield(SlowWavesTab, 'numeric');
            SW_AmpMeanEditField.Position = [123 444 103 22];

            % Create AmpSDEditField_3Label
            AmpSDEditField_3Label = uilabel(SlowWavesTab);
            AmpSDEditField_3Label.HorizontalAlignment = 'right';
            AmpSDEditField_3Label.Position = [29 412 53 22];
            AmpSDEditField_3Label.Text = 'Amp. SD';

            % Create SW_AmpSDEditField
            SW_AmpSDEditField = uieditfield(SlowWavesTab, 'numeric');
            SW_AmpSDEditField.Position = [123 412 103 22];

            % Create DurMeanEditField_2Label
            DurMeanEditField_2Label = uilabel(SlowWavesTab);
            DurMeanEditField_2Label.HorizontalAlignment = 'right';
            DurMeanEditField_2Label.Position = [22 377 60 22];
            DurMeanEditField_2Label.Text = 'Dur. Mean';

            % Create SW_DurMeanEditField
            SW_DurMeanEditField = uieditfield(SlowWavesTab, 'numeric');
            SW_DurMeanEditField.Position = [123 377 103 22];

            % Create DurSDEditField_2Label
            DurSDEditField_2Label = uilabel(SlowWavesTab);
            DurSDEditField_2Label.HorizontalAlignment = 'right';
            DurSDEditField_2Label.Position = [36 345 46 22];
            DurSDEditField_2Label.Text = 'Dur. SD';

            % Create SW_DurSDEditField
            SW_DurSDEditField = uieditfield(SlowWavesTab, 'numeric');
            SW_DurSDEditField.Position = [123 345 103 22];

            % Create RateEditField_5Label
            RateEditField_5Label = uilabel(SlowWavesTab);
            RateEditField_5Label.HorizontalAlignment = 'right';
            RateEditField_5Label.Position = [18 476 64 22];
            RateEditField_5Label.Text = 'Rate';

            % Create SW_RateEditField
            SW_RateEditField = uieditfield(SlowWavesTab, 'numeric');
            SW_RateEditField.Position = [123 476 103 22];

            % Create SpindlesTab
            SpindlesTab = uitab(TabGroup);
            SpindlesTab.AutoResizeChildren = 'off';
            SpindlesTab.Title = 'Spindles';

            % Create Spindle_UIAxes
            Spindle_UIAxes = uiaxes(SpindlesTab);
            title(Spindle_UIAxes, 'History Modulation Curve')
            xlabel(Spindle_UIAxes, 'Time Since Last Spindle (s)')
            ylabel(Spindle_UIAxes, 'Modulation Factor')
            zlabel(Spindle_UIAxes, 'Z')
            Spindle_UIAxes.Position = [295 163 625 332];

            % Create FreqSDEditFieldLabel
            FreqSDEditFieldLabel = uilabel(SpindlesTab);
            FreqSDEditFieldLabel.HorizontalAlignment = 'right';
            FreqSDEditFieldLabel.Position = [47 444 52 22];
            FreqSDEditFieldLabel.Text = 'Freq. SD';

            % Create Spindle_FreqSDEditField
            Spindle_FreqSDEditField = uieditfield(SpindlesTab, 'numeric');
            Spindle_FreqSDEditField.Position = [140 444 103 22];

            % Create AmpMeanEditField_4Label
            AmpMeanEditField_4Label = uilabel(SpindlesTab);
            AmpMeanEditField_4Label.HorizontalAlignment = 'right';
            AmpMeanEditField_4Label.Position = [32 412 67 22];
            AmpMeanEditField_4Label.Text = 'Amp. Mean';

            % Create Spindle_AmpMeanEditField
            Spindle_AmpMeanEditField = uieditfield(SpindlesTab, 'numeric');
            Spindle_AmpMeanEditField.Position = [140 412 103 22];

            % Create AmpSDEditField_4Label
            AmpSDEditField_4Label = uilabel(SpindlesTab);
            AmpSDEditField_4Label.HorizontalAlignment = 'right';
            AmpSDEditField_4Label.Position = [46 377 53 22];
            AmpSDEditField_4Label.Text = 'Amp. SD';

            % Create Spindle_AmpSDEditField
            Spindle_AmpSDEditField = uieditfield(SpindlesTab, 'numeric');
            Spindle_AmpSDEditField.Position = [140 377 103 22];

            % Create FreqMeanEditFieldLabel
            FreqMeanEditFieldLabel = uilabel(SpindlesTab);
            FreqMeanEditFieldLabel.HorizontalAlignment = 'right';
            FreqMeanEditFieldLabel.Position = [33 476 66 22];
            FreqMeanEditFieldLabel.Text = 'Freq. Mean';

            % Create Spindle_FreqMeanEditField
            Spindle_FreqMeanEditField = uieditfield(SpindlesTab, 'numeric');
            Spindle_FreqMeanEditField.Position = [140 476 103 22];

            % Create DurMeanEditField_3Label
            DurMeanEditField_3Label = uilabel(SpindlesTab);
            DurMeanEditField_3Label.HorizontalAlignment = 'right';
            DurMeanEditField_3Label.Position = [40 310 60 22];
            DurMeanEditField_3Label.Text = 'Dur. Mean';

            % Create Spindle_DurMeanEditField
            Spindle_DurMeanEditField = uieditfield(SpindlesTab, 'numeric');
            Spindle_DurMeanEditField.Position = [141 310 103 22];

            % Create DurSDEditField_3Label
            DurSDEditField_3Label = uilabel(SpindlesTab);
            DurSDEditField_3Label.HorizontalAlignment = 'right';
            DurSDEditField_3Label.Position = [54 275 46 22];
            DurSDEditField_3Label.Text = 'Dur. SD';

            % Create Spindle_DurSDEditField
            Spindle_DurSDEditField = uieditfield(SpindlesTab, 'numeric');
            Spindle_DurSDEditField.Position = [141 275 103 22];

            % Create BaselineRateEditFieldLabel
            BaselineRateEditFieldLabel = uilabel(SpindlesTab);
            BaselineRateEditFieldLabel.HorizontalAlignment = 'right';
            BaselineRateEditFieldLabel.Position = [21 198 79 22];
            BaselineRateEditFieldLabel.Text = 'Baseline Rate';

            % Create Spindle_BaselineRateEditField
            Spindle_BaselineRateEditField = uieditfield(SpindlesTab, 'numeric');
            Spindle_BaselineRateEditField.Position = [141 198 103 22];

            % Create StartTimeEditFieldLabel
            StartTimeEditFieldLabel = uilabel(SpindlesTab);
            StartTimeEditFieldLabel.HorizontalAlignment = 'right';
            StartTimeEditFieldLabel.Position = [40 163 60 22];
            StartTimeEditFieldLabel.Text = 'Start Time';

            % Create Spindle_StartTimeEditField
            Spindle_StartTimeEditField = uieditfield(SpindlesTab, 'numeric');
            Spindle_StartTimeEditField.Position = [141 163 103 22];

            % Create ModulationFactEditFieldLabel
            ModulationFactEditFieldLabel = uilabel(SpindlesTab);
            ModulationFactEditFieldLabel.HorizontalAlignment = 'right';
            ModulationFactEditFieldLabel.Position = [9 83 95 22];
            ModulationFactEditFieldLabel.Text = 'Modulation Fact.';

            % Create Spindle_ModulationFactEditField
            Spindle_ModulationFactEditField = uieditfield(SpindlesTab, 'numeric');
            Spindle_ModulationFactEditField.Position = [145 83 103 22];

            % Create PhasePrefEditFieldLabel
            PhasePrefEditFieldLabel = uilabel(SpindlesTab);
            PhasePrefEditFieldLabel.HorizontalAlignment = 'right';
            PhasePrefEditFieldLabel.Position = [36 115 67 22];
            PhasePrefEditFieldLabel.Text = 'Phase Pref.';

            % Create Spindle_PhasePrefEditField
            Spindle_PhasePrefEditField = uieditfield(SpindlesTab, 'numeric');
            Spindle_PhasePrefEditField.Position = [144 115 103 22];

            % Create MaxTimeEditFieldLabel
            MaxTimeEditFieldLabel = uilabel(SpindlesTab);
            MaxTimeEditFieldLabel.HorizontalAlignment = 'right';
            MaxTimeEditFieldLabel.Position = [706 84 58 22];
            MaxTimeEditFieldLabel.Text = 'Max Time';

            % Create Spindle_MaxTimeEditField
            Spindle_MaxTimeEditField = uieditfield(SpindlesTab, 'numeric');
            Spindle_MaxTimeEditField.Position = [809 84 103 22];

            % Create TensionEditFieldLabel
            TensionEditFieldLabel = uilabel(SpindlesTab);
            TensionEditFieldLabel.HorizontalAlignment = 'right';
            TensionEditFieldLabel.Position = [721 115 46 22];
            TensionEditFieldLabel.Text = 'Tension';

            % Create Spindle_TensionEditField
            Spindle_TensionEditField = uieditfield(SpindlesTab, 'numeric');
            Spindle_TensionEditField.Position = [808 115 103 22];

            % Create ControlPointsLabel
            ControlPointsLabel = uilabel(SpindlesTab);
            ControlPointsLabel.HorizontalAlignment = 'right';
            ControlPointsLabel.Position = [334 115 85 22];
            ControlPointsLabel.Text = 'Control  Points';

            % Create Spindle_ControlPointsEditField
            Spindle_ControlPointsEditField = uieditfield(SpindlesTab, 'text');
            Spindle_ControlPointsEditField.Position = [434 115 249 22];

            % Create SplineValueEditFieldLabel
            SplineValueEditFieldLabel = uilabel(SpindlesTab);
            SplineValueEditFieldLabel.HorizontalAlignment = 'right';
            SplineValueEditFieldLabel.Position = [347 84 71 22];
            SplineValueEditFieldLabel.Text = 'Spline Value';

            % Create Spindle_SplineValueEditField
            Spindle_SplineValueEditField = uieditfield(SpindlesTab, 'text');
            Spindle_SplineValueEditField.Position = [433 84 250 22];

            % Create AmpSDEditField_4Label_2
            AmpSDEditField_4Label_2 = uilabel(SpindlesTab);
            AmpSDEditField_4Label_2.HorizontalAlignment = 'right';
            AmpSDEditField_4Label_2.Position = [43 342 57 22];
            AmpSDEditField_4Label_2.Text = 'Amp. Min';

            % Create Spindle_AmpMinEditField
            Spindle_AmpMinEditField = uieditfield(SpindlesTab, 'numeric');
            Spindle_AmpMinEditField.Position = [141 342 103 22];

            % Create AmpSDEditField_4Label_3
            AmpSDEditField_4Label_3 = uilabel(SpindlesTab);
            AmpSDEditField_4Label_3.HorizontalAlignment = 'right';
            AmpSDEditField_4Label_3.Position = [50 242 49 22];
            AmpSDEditField_4Label_3.Text = 'Dur. Min';

            % Create Spindle_DurMinEditField
            Spindle_DurMinEditField = uieditfield(SpindlesTab, 'numeric');
            Spindle_DurMinEditField.Position = [140 242 103 22];

            % Create LineNoiseTab
            LineNoiseTab = uitab(TabGroup);
            LineNoiseTab.AutoResizeChildren = 'off';
            LineNoiseTab.Title = 'Line Noise';

            % Create UIAxes
            UIAxes = uiaxes(LineNoiseTab);
            title(UIAxes, 'Line Noise')
            xlabel(UIAxes, 'Time (s)')
            ylabel(UIAxes, 'Amplitdue mV')
            zlabel(UIAxes, 'Z')
            UIAxes.Position = [29 75 917 268];

            % Create AmpMeanEditField_3Label_2
            AmpMeanEditField_3Label_2 = uilabel(LineNoiseTab);
            AmpMeanEditField_3Label_2.HorizontalAlignment = 'right';
            AmpMeanEditField_3Label_2.Position = [21 444 61 22];
            AmpMeanEditField_3Label_2.Text = 'Frequency';

            % Create Ln_AmpMeanEditField
            Ln_AmpMeanEditField = uieditfield(LineNoiseTab, 'numeric');
            Ln_AmpMeanEditField.Position = [123 444 103 22];

            % Create AmpSDEditField_3Label_2
            AmpSDEditField_3Label_2 = uilabel(LineNoiseTab);
            AmpSDEditField_3Label_2.HorizontalAlignment = 'right';
            AmpSDEditField_3Label_2.Position = [29 412 53 22];
            AmpSDEditField_3Label_2.Text = 'Amp. SD';

            % Create Ln_AmpSDEditField
            Ln_AmpSDEditField = uieditfield(LineNoiseTab, 'numeric');
            Ln_AmpSDEditField.Position = [123 412 103 22];

            % Create WaveformDropDownLabel
            WaveformDropDownLabel = uilabel(LineNoiseTab);
            WaveformDropDownLabel.HorizontalAlignment = 'right';
            WaveformDropDownLabel.Position = [23 476 59 22];
            WaveformDropDownLabel.Text = 'Waveform';

            % Create Ln_WaveformDropDown
            Ln_WaveformDropDown = uidropdown(LineNoiseTab);
            Ln_WaveformDropDown.Items = {'Sin', 'Sawtooth', 'Square'};
            Ln_WaveformDropDown.Position = [123 476 103 22];
            Ln_WaveformDropDown.Value = 'Sin';

            % Create ArtifactsTab
            ArtifactsTab = uitab(TabGroup);
            ArtifactsTab.AutoResizeChildren = 'off';
            ArtifactsTab.Title = 'Artifacts';

            % Create AmpMeanEditField_2Label
            AmpMeanEditField_2Label = uilabel(ArtifactsTab);
            AmpMeanEditField_2Label.HorizontalAlignment = 'right';
            AmpMeanEditField_2Label.Position = [15 444 67 22];
            AmpMeanEditField_2Label.Text = 'Amp. Mean';

            % Create Art_AmpMeanEditField
            Art_AmpMeanEditField = uieditfield(ArtifactsTab, 'numeric');
            Art_AmpMeanEditField.Position = [123 444 103 22];

            % Create AmpSDEditField_2Label
            AmpSDEditField_2Label = uilabel(ArtifactsTab);
            AmpSDEditField_2Label.HorizontalAlignment = 'right';
            AmpSDEditField_2Label.Position = [29 412 53 22];
            AmpSDEditField_2Label.Text = 'Amp. SD';

            % Create Art_AmpSDEditField
            Art_AmpSDEditField = uieditfield(ArtifactsTab, 'numeric');
            Art_AmpSDEditField.Position = [123 412 103 22];

            % Create AmpMinEditFieldLabel
            AmpMinEditFieldLabel = uilabel(ArtifactsTab);
            AmpMinEditFieldLabel.HorizontalAlignment = 'right';
            AmpMinEditFieldLabel.Position = [25 377 57 22];
            AmpMinEditFieldLabel.Text = 'Amp. Min';

            % Create Art_AmpMinEditField
            Art_AmpMinEditField = uieditfield(ArtifactsTab, 'numeric');
            Art_AmpMinEditField.Position = [123 377 103 22];

            % Create RateEditField_4Label
            RateEditField_4Label = uilabel(ArtifactsTab);
            RateEditField_4Label.HorizontalAlignment = 'right';
            RateEditField_4Label.Position = [18 476 64 22];
            RateEditField_4Label.Text = 'Rate';

            % Create Art_RateEditField
            Art_RateEditField = uieditfield(ArtifactsTab, 'numeric');
            Art_RateEditField.Position = [123 476 103 22];

            % Create PlotButton
            PlotButton = uibutton(UIFigure, 'push');
            PlotButton.FontSize = 18;
            PlotButton.Position = [443 30 121 29];
            PlotButton.Text = 'Plot';

            % Show the figure after all components are created
            UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = SimApp_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(UIFigure)
        end
    end
end