function time_segments = sleep_time_select(time_bounds, hyp_times, hyp_stages, selected_stages, excluded_times)
% SLEEP_TIME_SELECT Subselect regions of times based on time bounds, sleep stages and excluded (artifact) times
%
%   Usage:
%       time_segments = time_select(time_bounds, hyp_times, hyp_stages, selected_stages, excluded_times)
%
%   Input:
%       time_bounds: 1x2 vector of overall time limits - required
%       hyp_times: 1 x H vector - hypnogram_times
%       hyp_stages: 1 x H vector - hypnogram_times
%       selected_stages: vector of stages selected 5-W, 4-REM, 3-N1, 2-N2, 1-N3 (default: all selected)
%       excluded_times: Tx2 matrix of (start,end) times to be excluded from the record
%
%
%   Output:
%       time_segments: Nx2 matrix of time segments
%
%   Example:
%         %Load example data
%         load('/data/preraugp/archive/Lunesta Study/sleep_stages/Lun01-Night1.mat');
% 
%         %Make reduced hypnogram
%         t_inds=unique([1; find(diff(stage_struct.stage)~=0)+1; length(stage_struct.stage)]);
% 
%         hyp_times=stage_struct.time(t_inds);
%         hyp_stages=stage_struct.stage(t_inds);
% 
%         %Set overall time bounds to use
%         time_bounds=[500 25000];
%         %Set specific times to exclude
%         excluded_times=[1000 5000; 10000 11000];
%         %Pick all stages but REM
%         selected_stages=[1:3 5];
% 
%         %Find the time segments
%         time_segments = sleep_time_select(time_bounds, hyp_times, hyp_stages, selected_stages, excluded_times);
% 
%         %Plot
%         figure
%         hypnoplot(hyp_times, hyp_stages);
%         vline(time_segments(:,1)',3,'m'); %Start times
%         vline(time_segments(:,2)',3,'g'); %End times
%         vline(excluded_times(:)',1,'y','--'); %Excluded times
%
%   Copyright 2024 Michael J. Prerau, Ph.D.
%
%   Last modified 11/13/2018
%% ********************************************************************
%Set the initial time segment to the time bounds
if nargin==0
    error('Time bounds is a required input');
elseif nargin>3 && isempty(time_bounds)
    warning('Time bounds set to hypnogram bounds');
    time_bounds=[min(hyp_times) max(hyp_times)+30];
end

%Set time bounds to the initial segment
time_segments=time_bounds;

% Select the time segments for the selected sleep stages
if nargin>3 && ~isempty(hyp_stages) && ~isempty(hyp_times)
    
    %Select all stages by default
    if nargin<4 || isempty(selected_stages)
        selected_stages=1:5;
    end
    
    %Make sure the stages are a column vector
    selected_stages=selected_stages(:);
    hyp_stages=hyp_stages(:)';
    hyp_times=hyp_times(:)';
    
    %Do group OR logical
    start_inds=sum(hyp_stages==selected_stages)>0;
    
    %Find consecutive segments
    [~,inds]=consecutive(~start_inds);
    
    for ii=1:length(inds)
        new_segment=hyp_times([inds{ii}(1) min(inds{ii}(end)+1, length(hyp_times))]);
        time_segments=remove_time_segment(time_segments, new_segment);
    end
end

%Remove each of the excluded segments
if nargin>4
    for ii=1:size(excluded_times,1)
        time_segments=remove_time_segment(time_segments, excluded_times(ii,:));
    end
end

%% Remove a time segment from a list of time ranges
function updated_segments = remove_time_segment(time_segments, new_segment)
updated_segments=[];

for ii=1:size(time_segments,1)
    old_segment=time_segments(ii,:);
    
    switch segment_overlap(old_segment, new_segment)
        case 1
            old_segment(1)=new_segment(2);
            if old_segment(1)<old_segment(2)
                updated_segments=[updated_segments; old_segment];
            end
        case 2
            old_segment(2)=new_segment(1);
            if old_segment(1)<old_segment(2)
                updated_segments=[updated_segments; old_segment];
            end
        case 3
            updated_segments=[updated_segments; old_segment(1) new_segment(1); new_segment(2) old_segment(2)];
        case 0
            updated_segments=[updated_segments; old_segment];
    end
end

%% Identify type of segment overlap
function out=segment_overlap(old_segment, new_segment)

%1: Bottom overlap
if new_segment(1)<old_segment(1) && new_segment(2)>old_segment(1)
    out=1;
    %2: Top overlap
elseif new_segment(1)<old_segment(2) && new_segment(2)>old_segment(2)
    out=2;
    %3: Intersection
elseif new_segment(1)>old_segment(1) && new_segment(2)<old_segment(2)
    out=3;
    %Consumes segment
elseif new_segment(1)<old_segment(1) && new_segment(2)>old_segment(2)
    out=4;
else
    out=0;
end
