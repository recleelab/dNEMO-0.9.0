function [] = coordinate_spots_to_cells(APP)
%% <placeholder>
%

% pull quick-access cell_signals structure
cell_signals = getappdata(APP.MAIN,'cell_signals');

% pull cell storage structure
polygon_list = getappdata(APP.MAIN,'polygon_list');
if isempty(polygon_list)
    cell_signals = {};
    setappdata(APP.MAIN,'cell_signals',cell_signals);
    cla(APP.trajectory_ax);
    return;
end

% pull spot_detect structure
spot_detect = getappdata(APP.MAIN,'spot_detect');
if isempty(spot_detect)
    return;
end

for cell_idx=1:length(polygon_list)
    if size(cell_signals,1) < size(polygon_list,1) && ~isempty(cell_signals)
        [cell_signals_in_polygon] = cell_signal_assignment(spot_detect, polygon_list{size(polygon_list,1)});
        cell_signals = cat(1,cell_signals,{cell_signals_in_polygon});
    else
        % cell either modified or removed, re-run entire list
        cell_signals = {};
        for cell_idx=1:size(polygon_list)
            [cell_signals_in_polygon] = cell_signal_assignment(spot_detect, polygon_list{cell_idx});
            cell_signals = cat(1,cell_signals, {cell_signals_in_polygon});
        end
    end
end
if size(cell_signals,1) > 1
    updated_cell_signals = fcfs(cell_signals);
    setappdata(APP.MAIN,'cell_signals',updated_cell_signals);
else
    setappdata(APP.MAIN,'cell_signals',cell_signals);
end

%
%%%
%%%%%
%%%
%

function [cell_signals] = cell_signal_assignment(spot_detect_obj, tmp_cell_obj)
%% <placeholder>
%

spotInfo = spot_detect_obj.spotInfoArr;
polygons = tmp_cell_obj.polygons;

for n=1:size(polygons,2)
    curr_spotInfo = spotInfo{n};
    curr_polygon = polygons{n};
    
    if ~isempty(curr_spotInfo)
        kf_centroids = curr_spotInfo.objCoords;
        centroids_in_cell = inpolygon(kf_centroids(:,1),kf_centroids(:,2),curr_polygon(:,1),curr_polygon(:,2));
        cell_signals{n} = centroids_in_cell;
    else
        cell_signals{n} = [];
    end
end

%
%%%
%%%%%
%%%
%

function [cell_signals] = fcfs(cell_signals)
%% <placeholder>
%

for first_idx=1:size(cell_signals,2)
    initial_listing = cell_signals{1,first_idx};
    
    % working through each subsequent cell for the keyframe
    for second_idx=2:size(cell_signals,1)
        curr_listing = cell_signals{second_idx,first_idx};
        
        for third_idx = 1:size(curr_listing,2)
            
            root_frame = initial_listing{third_idx};
            curr_frame = curr_listing{third_idx};
            if ~isempty(root_frame) && ~isempty(curr_frame)
                curr_frame(root_frame==1) = 0;
                root_frame(curr_frame==1) = 1;
            end
            curr_listing{third_idx} = curr_frame;
            initial_listing{third_idx} = root_frame;
            
        end
        
        % initial listing won't get saved -- curr_listing gets reassigned.
        cell_signals{second_idx,first_idx} = curr_listing;
        
    end
end

%
%%%
%%%%%
%%%
%