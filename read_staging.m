function [staging, annotations] = read_staging(file_name, time_col, stage_col, stage_vals, header_lines, start_time, epoch_dur, plot_on)
%READ_STAGING  Read sleep staging data from a CSV file
%
%   Usage:
%       [staging, annotations] = read_staging(file_name, time_col, stage_col, stage_vals, header_lines, start_time, epoch_dur, plot_on)
%
%   Input:
%       file_name   : string - path to CSV file -- required
%       time_col    : integer - column number for time data (1-based) -- required
%       stage_col   : integer - column number for stage data (1-based) -- required
%       stage_vals  : 1x7 cell array of strings or cell arrays with stage strings (default: predefined mapping)
%       header_lines: integer - number of header lines to skip (default: 0)
%       start_time  : string in 'HH:MM:SS' format (default: nan) - reference start time
%       epoch_dur   : scalar - epoch duration in seconds, if time is epoch index (default: 30)
%       plot_on     : logical - if true, plot hypnogram with hypnoplot (default: true)
%
%   Output:
%       staging     : struct with fields:
%                       - times : vector of times in seconds
%                       - vals  : vector of stage values (0-6)
%       annotations : struct with fields (only for unmatched entries):
%                       - times      : vector of times in seconds
%                       - annotation : cell array of annotation strings
%
%   Notes:
%       Sleep stage notation:
%           Artifact = 6, Wake = 5, REM = 4, N1 = 3, N2 = 2, N3 = 1, Unknown = 0
%       If the time column is ascending integers, it is treated as epoch numbers,
%       and converted into seconds using epoch_dur. In this case, the first stage
%       time is aligned at start_time + epoch_dur (or epoch_dur if no start_time given).
%
%   Example:
%       [staging, annotations] = read_staging('hypnogram.csv', 1, 2);
%
%   Copyright 2025

    % ---------------- Default stage mappings ----------------
    default_stage_vals = {{'art', 'artifact', 'A', '6'}, ...
                          {'wake', 'W', '5'}, ...
                          {'REM', 'R', '4'}, ...
                          {'N1', 'Stage 1', '1'}, ...
                          {'N2', 'Stage 2', '2'}, ...
                          {'N3', 'Stage 3', '3'}, ...
                          {'Unk', 'U', 'Unknown', '0'}};

    % ---------------- Input checks ----------------
    if nargin < 4 || isempty(stage_vals) || (isnumeric(stage_vals) && isnan(stage_vals))
        stage_vals = default_stage_vals;
    end
    if nargin < 5 || isempty(header_lines), header_lines = 0; end
    if nargin < 6 || isempty(start_time), start_time = NaN; end
    if nargin < 7 || isempty(epoch_dur), epoch_dur = 30; end
    if nargin < 8 || isempty(plot_on), plot_on = true; end

    if ~exist(file_name, 'file')
        error('File "%s" does not exist.', file_name);
    end

    if ~(isscalar(time_col) && isnumeric(time_col) && time_col > 0)
        error('time_col must be a positive integer.');
    end
    if ~(isscalar(stage_col) && isnumeric(stage_col) && stage_col > 0)
        error('stage_col must be a positive integer.');
    end

    % Convert simple 1x7 string array into cell-of-cells
    if iscell(stage_vals) && length(stage_vals) == 7 && ~iscell(stage_vals{1})
        stage_vals = cellfun(@(x) {x}, stage_vals, 'UniformOutput', false);
    end

       % ---------------- Read CSV ----------------
    % Read everything as strings so nothing is dropped
    raw_data = readcell(file_name, 'Delimiter', ',', 'NumHeaderLines', header_lines);

    % Validate enough columns exist
    num_cols = size(raw_data, 2);
    if time_col > num_cols
        error('time_col (%d) exceeds number of columns (%d).', time_col, num_cols);
    end
    if stage_col > num_cols
        error('stage_col (%d) exceeds number of columns (%d).', stage_col, num_cols);
    end

    time_data  = string(raw_data(:, time_col));
    stage_data = string(raw_data(:, stage_col));

    % ---------------- Time conversion ----------------
    times_seconds = convert_time_to_seconds(time_data, start_time, epoch_dur);

    % ---------------- Stage processing ----------------
    [stage_values, unmatched_idx] = process_stage_data(stage_data, stage_vals);

    % ---------------- Outputs ----------------
    staging.times = times_seconds(:);
    staging.vals  = stage_values(:);

    if isempty(unmatched_idx)
        annotations = struct([]); % return empty
    else
        annotations.times = times_seconds(unmatched_idx);
        annotations.annotation = stage_data(unmatched_idx);
    end

    % ---------------- Optional plotting ----------------
    if plot_on
        figure;
        hypnoplot(staging.times, staging.vals);
    end
end

% ============================================================
function times_seconds = convert_time_to_seconds(time_data, start_time, epoch_dur)
    numeric_data = str2double(time_data);

    % Case 1: epoch numbers (ascending integers)
    if all(~isnan(numeric_data)) && all(mod(numeric_data,1)==0) && all(diff(numeric_data) >= 0)
        epoch_nums = numeric_data(:);
        if ischar(start_time) || isstring(start_time)
            st = regexp(char(start_time), '^(\d{1,2}):(\d{2}):(\d{2})$', 'tokens');
            if ~isempty(st)
                hh = str2double(st{1}{1});
                mm = str2double(st{1}{2});
                ss = str2double(st{1}{3});
                start_sec = hh*3600 + mm*60 + ss;
            else
                start_sec = 0;
            end
        else
            start_sec = 0;
        end
        times_seconds = start_sec + epoch_nums * epoch_dur;
        return;
    end

    % Case 2: general numeric values
    if all(~isnan(numeric_data))
        times_seconds = numeric_data;
        return;
    end

    % Case 3: HH:MM:SS strings
    raw_seconds = nan(size(time_data));
    for i = 1:numel(time_data)
        tstr = strtrim(char(time_data(i)));
        parts = regexp(tstr, '^(\d{1,2}):(\d{2}):(\d{2})$', 'tokens');
        if ~isempty(parts)
            hh = str2double(parts{1}{1});
            mm = str2double(parts{1}{2});
            ss = str2double(parts{1}{3});
            raw_seconds(i) = hh*3600 + mm*60 + ss;
        end
    end

    raw_seconds = handle_midnight_crossover(raw_seconds);

    if ischar(start_time) || isstring(start_time)
        st = regexp(char(start_time), '^(\d{1,2}):(\d{2}):(\d{2})$', 'tokens');
        if ~isempty(st)
            hh = str2double(st{1}{1});
            mm = str2double(st{1}{2});
            ss = str2double(st{1}{3});
            ref_sec = hh*3600 + mm*60 + ss;
            times_seconds = raw_seconds - ref_sec;
            return;
        end
    end

    % Default: relative to first timestamp
    first_valid = raw_seconds(find(~isnan(raw_seconds),1,'first'));
    times_seconds = raw_seconds - first_valid;
end

% ============================================================
function adjusted_times = handle_midnight_crossover(raw_seconds)
    adjusted_times = raw_seconds;
    day_sec = 24*3600;
    for i = 2:length(adjusted_times)
        if adjusted_times(i) < adjusted_times(i-1) - 12*3600
            adjusted_times(i:end) = adjusted_times(i:end) + day_sec;
        end
    end
end

% ============================================================
function [stage_values, unmatched_idx] = process_stage_data(stage_data, stage_vals)
    stage_numbers = [6, 5, 4, 3, 2, 1, 0]; % Artifact → Unknown
    stage_values = nan(size(stage_data));   % start unassigned

    for stage_idx = 1:length(stage_vals)
        strs = lower(string(stage_vals{stage_idx}));
        for i = 1:length(stage_data)
            cur = lower(string(stage_data(i)));
            if any(contains(cur, strs))
                stage_values(i) = stage_numbers(stage_idx);
            end
        end
    end

    unmatched_idx = find(isnan(stage_values));
    stage_values(unmatched_idx) = 6; % default unmatched to Artifact
end
