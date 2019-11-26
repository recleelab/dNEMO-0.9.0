function [] = coordinate_signals(APP,string_arg,insertion_idx)
%% fxn meant for handling cell signal assignment
% 

% pull storage structures from application
KEYFRAMES = getappdata(APP.MAIN,'KEYFRAMES');
kf_ref_arr = getappdata(APP.MAIN,'keyframe_ref_array');
polygon_list = getappdata(APP.MAIN,'polygon_list');
cell_signals = getappdata(APP.MAIN,'cell_signals');

% confirm both keyframes and cells exist, if not return
if isstruct(KEYFRAMES{1})==0 || isempty(polygon_list)
	cell_signals = [];
	setappdata(APP.MAIN,'cell_signals',cell_signals);
	return;
end

% confirmation both keyframes and cells are present
disp('coordinating signals to defined cells');

% delineate between keyframe and cell creation call
switch string_arg
	
	case 'keyframe'
		% came from keyframe creation / modification / deletion
		% inserting new column into cell_signals
		
		if insertion_idx == 1 && isempty(cell_signals)
			% iterate through present cells, assigning signals accordingly
			cell_signals = cell(size(polygon_list,1),1);
			for i=1:size(polygon_list,1)
				[cell_signals_in_polygon] = cell_signal_assignment(KEYFRAMES{insertion_idx},polygon_list{i});
				cell_signals{i,insertion_idx} = cell_signals_in_polygon;
			end
			
		elseif insertion_idx > size(cell_signals,2)
			% inserting new keyframe, assign to cells
			new_col = cell(size(polygon_list,1),1);
			for i=1:size(polygon_list,1)
				[cell_signals_in_polygon] = cell_signal_assignment(KEYFRAMES{insertion_idx},polygon_list{i});
				new_col{i,1} = cell_signals_in_polygon;
			end
			cell_signals = cat(2,cell_signals,new_col);
		
		else
			% modified existing keyframe -- update for all cells, then update relevant 
			% storage as necessary
			for i=1:size(polygon_list,1)
				[cell_signals_in_polygon] = cell_signal_assignment(KEYFRAMES{insertion_idx},polygon_list{i});
				cell_signals{i,insertion_idx} = cell_signals_in_polygon;
			end
		end
	
	case 'cell'
		% came from cell creation / modification / deletion
		% inserting new row into cell_signals
		
		if insertion_idx == 1 && isempty(cell_signals)
			% iterate through KEYFRAMES, assigning based
			disp('first cell created.');
			cell_signals = cell(1,size(KEYFRAMES,1));
			for i=1:size(KEYFRAMES,1)
				[cell_signals_in_polygon] = cell_signal_assignment(KEYFRAMES{i},polygon_list{insertion_idx});
				cell_signals{insertion_idx,i} = cell_signals_in_polygon;
			end
		
		elseif insertion_idx > size(cell_signals,1)
			% inserting a new cell
			new_row = cell(1,size(KEYFRAMES,1));
			for i=1:size(KEYFRAMES,1)
				[cell_signals_in_polygon] = cell_signal_assignment(KEYFRAMES{i},polygon_list{insertion_idx});
				new_row{1,i} = cell_signals_in_polygon;
			end
			cell_signals = cat(1,cell_signals,new_row);
        elseif insertion_idx == 0
            % cell was deleted, but cells remain (as it got here) - iterate
            % through cell_signal_assignment + fcfs afterwards
            cell_signals = cell(size(polygon_list,1),size(KEYFRAMES,1));
            for i=1:size(KEYFRAMES,1)
                for j=1:size(polygon_list,1)
                    [cell_signals_in_polygon] = cell_signal_assignment(KEYFRAMES{i},polygon_list{j});
                    cell_signals{j,i} = cell_signals_in_polygon;
                end
            end
		else
			% modified existing cell -- update @ cell, then update all relevant storage 
			% as necessary
			for i=1:size(KEYFRAMES,1)
				[cell_signals_in_polygon] = cell_signal_assignment(KEYFRAMES{i},polygon_list{insertion_idx});
				cell_signals{insertion_idx,i} = cell_signals_in_polygon;
			end
		end
	
end	

updated_cell_signals = fcfs(cell_signals);

setappdata(APP.MAIN,'cell_signals',updated_cell_signals);

%
%%%
%%%%%
%%%
%

function [cell_signals] = cell_signal_assignment(keyframe,polygon)
% returns cell array of size 1 x nFrames coordinating 
% keyframe signal information with polygon
% 

spotInfo = keyframe.spotInfo;
cell_signals = cell(1,size(polygon,2));


% signals stored as binary matrices of same length as the centroids, based on whether
% they are within the polygon AND whether they are included under current keyframe 
% parameters. can be updated w/ FCFS commands and exclusion commands AFTER initial
% assignment here in coordinate_signals.m / cell_signal_assignment.m

for n=1:size(polygon,2)
	
	curr_spotInfo = spotInfo{n};
	curr_polygon = polygon{n};
	
	if ~isempty(curr_spotInfo)
		
		kf_centroids = curr_spotInfo.objCoords;
		centroids_in_cell = inpolygon(kf_centroids(:,1),kf_centroids(:,2),curr_polygon(:,1),curr_polygon(:,2));
		
		% update: removing signals excluded by keyframe for size or intensity
		% incl_excl = curr_spotInfo.incl_excl;
		% centroids_in_cell(~incl_excl) = 0;
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
%% updates to make sure that signals only counted once per frame when 
%  being assigned to cells.
%  idea is ot go through each keyframe and remove signals so they aren't
%  counted more than once
%  

% iterating through each keyframe
for first_idx=1:size(cell_signals,2)
    
    initial_listing = cell_signals{1,first_idx};
    
    % working through each subsequent cell for the keyframe
    for second_idx=2:size(cell_signals,1)
        curr_listing = cell_signals{second_idx,first_idx};
        
        % ...then have to iterate through each entry w/in the listing. it's
        % ugly, but it'll work. and you don't have the luxury of time.
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