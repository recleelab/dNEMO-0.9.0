function [] = polygon_handler(hand,evt,APP)
%% main handler for polygon drawing, creation, and storage fxns
%  
%  INPUT: hand -- handle of some graphical component
% 		  evt -- not needed, but user interaction evt
% 		  APP -- main application


%  Step #1 - pulling necessary variables from application
cell_signals = getappdata(APP.MAIN,'cell_signals');
polygon_list = getappdata(APP.MAIN,'polygon_list');
nFrames = get(APP.film_slider,'max');

% quick fix, run exclude w/ the shutdown command 
% exclude_signals(APP.remove_signals_button,1,APP,2);
% end quick fix

% simple switchboard to separate graphical components' responses.
% 

switch hand
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	case APP.add_object_button
		
		starting_to_draw = strcmp('Draw Cell',APP.add_object_button.String);
		
		if starting_to_draw
			master_listener(APP,'cell',1);
			
			% draw new polygon
			new_polygon = impoly(APP.ax2);
			setColor(new_polygon,'yellow');
			pos = getPosition(new_polygon);
			new_polygon.addNewPositionCallback(@(p) polygon_change(new_polygon,APP));
			
			% initializing polydraw_toolbox
			prev_index = APP.film_slider.Value;
			polygon_path = cell(1,APP.film_slider.Max);
			for i=1:size(polygon_path,2)
				polygon_path{i} = pos;
				pseudo_adj_matrix(1,i) = 1;
			end
			pseudo_adj_matrix(2,prev_index) = 1;
			
			polydraw_toolbox = cell(1,3);
			polydraw_toolbox{1,1} = prev_index;
			polydraw_toolbox{1,2} = pseudo_adj_matrix;
			polydraw_toolbox{1,3} = polygon_path;
			setappdata(APP.MAIN,'polydraw_toolbox',polydraw_toolbox);
			master_listener(APP,'cell',2);
			
		else
			master_listener(APP,'cell',3);
			
			polydraw_toolbox = getappdata(APP.MAIN,'polydraw_toolbox');
			polygon_to_insert = polydraw_toolbox{1,3};
			
			% from APP
			polygon_list = getappdata(APP.MAIN,'polygon_list');
			new_idx = size(polygon_list,1) + 1;
			
			[updated_polygon_list] = polygon_insert(polygon_list,polygon_to_insert,new_idx);
			setappdata(APP.MAIN,'polygon_list',updated_polygon_list);
			
			% MISSING - EXCLUSIONS !!!!!!!!!!!
			
			coordinate_signals(APP,'cell',size(updated_polygon_list,1));
			update_user_selection(APP,2);
			
			% run display call to clean up
			display_trajectory_ax(APP);
			display_call(hand,1,APP);
			
		end
	
	%
	%%%
	%
	
	case APP.modify_cell_button
		
        modifying_cell = strcmp('Modify Cell',APP.modify_cell_button.String);
		
        if modifying_cell
            
            curr_idx = APP.created_cell_selection.Value - 1;
			
			% beginning modification of some selected cell
			master_listener(APP,'cell',4)
			
			% grabbing appropriate storage elements
			polygon_list = getappdata(APP.MAIN,'polygon_list');
			selected_polygon = polygon_list{curr_idx};
			num_frames = APP.film_slider.Max;
			frame_no = APP.film_slider.Value;
			
			% repopulating pseudo_adj_mat
			pseudo_adj_matrix = zeros(2,num_frames);
			pseudo_adj_matrix(:,1) = 1;
			if num_frames > 1
				for i=2:num_frames
					prev_pos = selected_polygon{i-1};
					curr_level = pseudo_adj_matrix(1,i-1);
					pos = selected_polygon{i};
					if isequal(prev_pos,pos)
						pseudo_adj_matrix(1,i) = curr_level;
						pseudo_adj_matrix(2,i) = 0;
					else
						new_level = curr_level+1;
						pseudo_adj_matrix(1,i) = new_level;
						pseudo_adj_matrix(2,i) = 1;
					end
				end
			end
			
			% creating impoly and its small storage
			curr_pos = selected_polygon{1,frame_no};
			polygon = impoly(APP.ax2,curr_pos);
			setColor(polygon,'yellow');
			polygon.addNewPositionCallback(@(p) polygon_change(polygon,APP));
			
			polydraw_toolbox = cell(1,3);
			polydraw_toolbox{1,1} = frame_no;
			polydraw_toolbox{1,2} = pseudo_adj_matrix;
			polydraw_toolbox{1,3} = selected_polygon;
			setappdata(APP.MAIN,'polydraw_toolbox',polydraw_toolbox);
            
            % update for modification errors
            hand.Tag = num2str(curr_idx);
			
        else
            
            curr_idx = str2num(hand.Tag);
            
			% ending modification of some selected cell
			master_listener(APP,'cell',3);
			
			polydraw_toolbox = getappdata(APP.MAIN,'polydraw_toolbox');
			polygon_to_insert = polydraw_toolbox{1,3};
			
			[updated_polygon_list] = polygon_insert(polygon_list,polygon_to_insert,curr_idx);
			setappdata(APP.MAIN,'polygon_list',updated_polygon_list);
			
			% MISSING - EXCLUSIONS !!!!!!!!!!!
			
			coordinate_signals(APP,'cell',curr_idx);
			update_user_selection(APP,2);
			
			% run display call to clean up
			APP.create_cell_selection.Value = curr_idx+1;
			display_listener(APP.created_cell_selection,1,APP);
			
		end
	
	%
	%%%
	%
	
	case APP.delete_object_button
		deleting_cell = strcmp('Delete Cell',APP.delete_object_button.String);
		if deleting_cell
			% grab app structures
			polygon_list = getappdata(APP.MAIN,'polygon_list');
			
			% grab relevant information
			curr_cell_idx = APP.created_cell_selection.Value - 1;
			
			[updated_polygon_list] = polygon_delete(polygon_list,curr_cell_idx);
			setappdata(APP.MAIN,'polygon_list',updated_polygon_list);
			
			% MISSING - EXCLUSIONS,SIGNAL ASSIGNMENT UPDATES %%%%%%%%%%%%%%%% !!!!!!!!!!
			
			coordinate_signals(APP,'cell',0);
			update_user_selection(APP,2);
			
			% run display call to clean up
			APP.created_cell_selection.Value = 1;
			display_listener(APP.created_cell_selection,1,APP);
		
		else
			master_listener(APP,'cell',3);
			display_call(APP.delete_object_button,1,APP);
		
		end
	
	%
	%%%
	%
	
	case {APP.film_slider,APP.brightness_slider,APP.contrast_slider,APP.cell_boundary_toggle,APP.created_cell_selection}
		% shifting display, bring up the impoly object once more
		
		polydraw_toolbox = getappdata(APP.MAIN,'polydraw_toolbox');
		prev_index = polydraw_toolbox{1,1};
		current_polygon = polydraw_toolbox{1,3};
		curr_index = APP.film_slider.Value;
		curr_pos = current_polygon{1,curr_index};
		
		polygon = impoly(APP.ax2,curr_pos);
		setColor(polygon,'yellow');
		polygon.addNewPositionCallback(@(p) polygon_change(polygon,APP));
		polydraw_toolbox{1,1} = curr_index;
		setappdata(APP.MAIN,'polydraw_toolbox',polydraw_toolbox);
	
	%
	%%%
	%

end

%
%%%
%%%%%
%%%
%

function polygon_change(polygon,APP)
%% callback function assigned to the polygon so that
%  if the user moves it, the coordinates and movements
%  are accurately and efficiently measured.

%  Step 1 - grab the polygon's position, now changed, 
%           and the index at which the change occurred.
pos = getPosition(polygon);
curr_idx = APP.film_slider.Value;

%  Step 2 - pull polydraw toolbox from the APP
polydraw_toolbox = getappdata(APP.MAIN,'polydraw_toolbox');
[prev_index,pseudo_adj_matrix,actual_polygon_paths] = polydraw_toolbox{[1,2,3]};

%  Step 3 - assign changes to current index
highest_level = max(pseudo_adj_matrix(1,:));
next_level = highest_level + 1;
actual_polygon_paths{1,curr_idx} = pos;
pseudo_adj_matrix(1,curr_idx) = next_level;
pseudo_adj_matrix(2,curr_idx) = 1;

%  Step 4 - loop through to apply changes AS LONG AS movie longer than 1 frame
if size(pseudo_adj_matrix,2) > 1
	next_keyframe_found = 0;
	count = curr_idx + 1;

	while next_keyframe_found == 0
		
		tmp_val = pseudo_adj_matrix(2,count);
		if tmp_val == 0 & count < length(pseudo_adj_matrix);
			pseudo_adj_matrix(1,count) = next_level;
			actual_polygon_paths{1,count} = pos;
			count = count + 1;
		else % if count == length(pseudo_adj_matrix)
			if tmp_val == 0
				endpoint = length(pseudo_adj_matrix);
				actual_polygon_paths{1,endpoint} = pos;
				next_keyframe_found = 1;
			else
		 		next_keyframe_found = 1;
			end
		end

	end
end

polydraw_toolbox{1,1} = prev_index;
polydraw_toolbox{1,2} = pseudo_adj_matrix;
polydraw_toolbox{1,3} = actual_polygon_paths;
setappdata(APP.MAIN,'polydraw_toolbox',polydraw_toolbox);
