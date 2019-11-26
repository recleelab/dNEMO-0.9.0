function [] = polygon_create(hand, evt, APP)
%% <placeholder>
%

% axis not responding
APP.ax2.PickableParts = 'visible';
APP.ax2.HitTest = 'on';
% end axis not responding

% addendum for canceling
% hand.String = 'Cancel Cell Creation';
% hand.Callback = {@polygon_cancel, APP};
% end addendum for canceling

new_polygon = impoly(APP.ax2);
setColor(new_polygon,'yellow');
pos = getPosition(new_polygon);
curr_frame = APP.film_slider.Value;
max_num_frames = APP.film_slider.Max;

new_cell = TMP_CELL(pos, max_num_frames, curr_frame);

polygon_list = getappdata(APP.MAIN,'polygon_list');
if isempty(polygon_list)
    polygon_list = cell(1);
	polygon_list{1,1} = new_cell;
else
    polygon_list = cat(1,polygon_list,{new_cell});
end

setappdata(APP.MAIN,'polygon_list',polygon_list);

% update cell signals
coordinate_spots_to_cells(APP);

% update keyframing map
APP.keyframing_map.Enable = 'on';
update_keyframe_data(APP);

% update cell selection
update_cell_selection_dropdown(APP);

% display call
cla(APP.ax2);
APP.cell_boundary_toggle.Value = 1;
display_call(hand, 1, APP);

%
%%%
%%%%%
%%%
%