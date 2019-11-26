function [] = polygon_remove(hand, evt, APP)
%% <placeholder>
%

polygon_list = getappdata(APP.MAIN,'polygon_list');

% pull current kf mapping pointer
curr_sel_string = APP.keyframing_map.String{APP.keyframing_map.Value};

while ~contains(curr_sel_string,{'[+]','[-]'})
    curr_sel_string = APP.keyframing_map.String{APP.keyframing_map.Value - 1};
end

some_tokens = strsplit(curr_sel_string,' ');
del_idx = str2num(some_tokens{3});

msgbox_string = strcat('Delete Cell #',num2str(del_idx),'?');
del_answer = questdlg(msgbox_string,'Delete Selected Cell','Yes','No','No');
del_comp = strcmp('Yes',del_answer);

if del_comp
	
	% remove cell
	num_cells = size(polygon_list,1);
	if del_idx == 1 && num_cells == 1
		% no more cells - revert relevant storage structures
		updated_polygon_list = [];
	else
		% removing one cell - update relevant structures
		updated_polygon_list = cell(num_cells-1,1);
		% CELL SIGNALS TOO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!!!!!!!!!!!!!!!!
		
		for i=1:size(polygon_list,1)
			if i < del_idx
				% insert into new struct @ same location
				updated_polygon_list{i} = polygon_list{i};
			elseif i > del_idx
				% insert into new struct @ (loc - 1)
				updated_polygon_list{i-1} = polygon_list{i};
			else
				% del_idx == i, do nothing
			end
		end
	end
	
else
	
	% return identical polygon list
	updated_polygon_list = polygon_list;

end

setappdata(APP.MAIN,'polygon_list',updated_polygon_list);

% update cell selection
update_cell_selection_dropdown(APP);

% update keyframing map
APP.keyframing_map.Value = 1;
update_keyframe_data(APP);

coordinate_spots_to_cells(APP);

display_call(APP.keyframing_map,1,APP);
%
%%%
%%%%%
%%%
%