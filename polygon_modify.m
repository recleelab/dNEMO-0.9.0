function [] = polygon_modify(hand, evt, APP)
%% <placeholder>
%

% pull current cells
polygon_list = getappdata(APP.MAIN,'polygon_list');

% get current frame number
frame_no = APP.film_slider.Value;

% pull current kf mapping pointer
%{
curr_sel_string = APP.keyframing_map.String{APP.keyframing_map.Value};

while ~contains(curr_sel_string,{'[+]','[-]'})
    curr_sel_string = APP.keyframing_map.String{APP.keyframing_map.Value - 1};
end

some_tokens = strsplit(curr_sel_string,' ');
cell_idx = str2num(some_tokens{3});
%}

cell_idx = APP.created_cell_selection.Value - 1;

APP.keyframing_map.Enable = 'off';
APP.ax2.PickableParts = 'visible';
APP.ax2.HitTest = 'on';

curr_cell = polygon_list{cell_idx};
curr_pos = curr_cell.polygons{frame_no};
adj_mat = curr_cell.pseudoAdjMatrix;

polygon = impoly(APP.ax2, curr_pos);
setColor(polygon,'yellow');
polygon.addNewPositionCallback(@(p) polygon_change(polygon, APP, cell_idx));

% handle termination case
APP.modify_cell_button.String = 'Update Cell Keyframe';
APP.modify_cell_button.Callback = {@terminate_polygon_modification, APP};

% handle cancellation case
APP.add_object_button.Enable = 'on';
APP.add_object_button.String = 'Cancel Cell Modify';
APP.add_object_button.Callback = {@cancel_polygon_modification, APP};


%
%%%
%%%%%
%%%
%

function polygon_change(polygon, APP, cell_idx)
%% callback function assigned to the polygon so that if user changes it, 
%  coordinates and movement are accurately measured.
%
%  Step 1 - grab the polygon's position, now changed, and the frame at
%  which it occurred
%
pos = getPosition(polygon);
curr_idx = APP.film_slider.Value;

%  Step 2 - pull current cell data
polygon_list = getappdata(APP.MAIN,'polygon_list');
curr_cell = polygon_list{cell_idx};

%  Step 3 - assign changes to current index 
curr_cell = curr_cell.updatePolygons(pos, curr_idx);
polygon_list{cell_idx} = curr_cell;
setappdata(APP.MAIN,'polygon_list',polygon_list);

%
%%%
%%%%%
%%%
%

function [] = terminate_polygon_modification(hand, evt, APP)
%% <placeholder>
%

coordinate_spots_to_cells(APP);

APP.keyframing_map.Enable = 'on';
APP.keyframing_map.Value = 1;
update_keyframe_data(APP);

APP.add_object_button.String = 'Add Cell';
APP.add_object_button.Callback = {@polygon_create, APP};
APP.add_object_button.Enable = 'on';

APP.modify_cell_button.String = 'Modify Cell';
APP.modify_cell_button.Callback = {@polygon_modify, APP};

cla(APP.ax2);
display_call(APP.keyframing_map, 1, APP);

%
%%%
%%%%%
%%%
%

function [] = cancel_polygon_modification(hand, evt, APP)
%% <placeholder>
%

APP.keyframing_map.Enable = 'on';
APP.keyframing_map.Value = 1;
update_keyframe_data(APP);

APP.add_object_button.String = 'Add Cell';
APP.add_object_button.Callback = {@polygon_create, APP};
APP.add_object_button.Enable = 'on';

APP.modify_cell_button.String = 'Modify Cell';
APP.modify_cell_button.Callback = {@polygon_modify, APP};

cla(APP.ax2);
display_call(APP.keyframing_map, 1, APP);

%
%%%
%%%%%
%%%
%