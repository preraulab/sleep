# sleep

Sleep EEG analysis toolbox from the Prerau Laboratory — scoring I/O, hypnograms, slow-wave extraction, sleep-stage simulators, and scoring-agreement statistics.

Developed by the [Prerau Laboratory](https://prerau.bwh.harvard.edu/) at Brigham and Women's Hospital / Harvard Medical School.

## What's here

| Area | Files |
|---|---|
| Staging I/O | `read_staging.m` — read delimited staging files (CSV/TSV) |
| Hypnogram visualization | `hypnoplot.m` — publication-quality hypnograms with stage bands, REM highlight, overnight axis |
| Slow-wave extraction | `extract_SW.m` — detect and characterize slow waves (SOs) from EEG (band-pass, artifact-aware, stage-gated, zero-crossing + amplitude threshold) |
| Simulations | `simulations/ECG_sim.m`, `simulations/SleepEEGSim` (submodule — full lifespan sleep EEG simulator) |
| Scoring agreement | `stage_comparisons/kappa.m` (Cohen / Fleiss κ), `stage_comparisons/ICC.m` (intraclass correlation) |

See the [published API reference](https://preraulab.github.io/sleep/) or `help <function>` at the MATLAB prompt.

## Quick start

```matlab
addpath(genpath('/path/to/sleep'));

% Read staging and plot a hypnogram
[staging, annotations] = read_staging('study.csv', 1, 2);
figure; hypnoplot(staging.time, staging.stage);

% Extract slow waves from 0.5-4 Hz EEG during N2/N3
[SOfilt, SOt, SOphase, amps, durs, stg, tSW] = extract_SW(eeg, Fs, stage_times, stage_vals);
```

## Install

```matlab
addpath(genpath('/path/to/sleep'));
```

The `simulations/SleepEEGSim` submodule provides a full-lifespan sleep EEG simulator and is populated via:

```bash
git submodule update --init --recursive
```

## Dependencies

MATLAB R2020a+. No required toolboxes. `extract_SW` uses the Prerau Lab [`artifact_detection`](https://github.com/preraulab/artifact_detection), [`multitaper_toolbox`](https://github.com/preraulab/multitaper_toolbox), and utility packages.

## Citation

See [`CITATION.cff`](CITATION.cff).

## License

BSD 3-Clause. See [`LICENSE`](LICENSE).
