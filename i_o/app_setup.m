function [] = app_setup(APP, IMG)
%% function to handle app startup with new image loaded into workspace
%

disp('setting up application');

T = IMG.T;
Z = IMG.Z;

imHeight = IMG.Height;
imWidth = IMG.Width;

setappdata(APP.MAIN,'IMG',IMG);

% setup data storage - exclusion array
excluded_array = cell([1 T]);
setappdata(APP.MAIN,'excluded_array',excluded_array);

% setup data storage - cell signals coordination array
cell_signals = {};
setappdata(APP.MAIN,'cell_signals',cell_signals);

% setup data storage - polygon list
polygon_list = [];
setappdata(APP.MAIN,'polygon_list',polygon_list);

% setup data storage - FCFS coordination array
FCFS = cell([1 T]);
setappdata(APP.MAIN,'FCFS',FCFS);

% setup data storage - Keyframe storage
KEYFRAMES = cell([1]);
setappdata(APP.MAIN,'KEYFRAMES',KEYFRAMES);

% setup data storage - keyframe reference array
keyframe_ref_array = [];
setappdata(APP.MAIN,'keyframe_ref_array',keyframe_ref_array);

% figure startup - b/c sliders
APP.brightness_slider.Enable = 'on';
APP.contrast_slider.Enable = 'on';

% figure startup - movie slider
if T == 1
    APP.film_slider.Value = 1;
    APP.film_slider.Enable = 'off';
    APP.film_slider.Visible = 'off';
    APP.film_slider.Max = 1;
else
    APP.film_slider.Min = 1;
    APP.film_slider.Max = T;
    APP.film_slider.SliderStep = [1/T 1/T];
    APP.film_slider.Enable = 'on';
    APP.film_slider.Visible = 'on';
end

% figure startup - Z slicer
curr_z = APP.z_slice_slider.Max;
if APP.z_slice_slider.Value > Z
    APP.z_slice_slider.Value = Z;
end
APP.z_slice_slider.Max = Z;

% figure startup - keyframe operation
% APP.add_keyframe_button.Enable = 'on';
% APP.add_spots_button.Enable = 'on';
APP.current_threshold_display.Enable = 'on';
APP.current_threshold_slider.Enable = 'on';
APP.quick_detect_button.Enable = 'on';
APP.full_detect_button.Enable = 'on';
APP.create_keyframe_button.Enable = 'on';
APP.add_object_button.Enable = 'on';

% figure startup - cell drawing operation
% APP.add_object_button.Enable = 'on';

% figure startup - axes
APP.ax2.XLim = [0.5 imWidth+0.5];
APP.ax2.YLim = [0.5 imHeight+0.5];

% figure startup - reset necessary values
setappdata(APP.MAIN,'spot_detect',[]);
setappdata(APP.MAIN,'OVERLAY',[]);
update_keyframe_data(APP);

% histogram clearing
cla(APP.hist_ax);
APP.hist_ax_min_box.String = '';
APP.hist_ax_max_box.String = '';
APP.feature_select_dropdown.Enable = 'off';

% clearing trajectory axis
cla(APP.trajectory_ax);

display_call(APP.film_slider,1,APP);
axis_display_sync(APP,APP.ax1,APP.ax2);
linkaxes([APP.ax1,APP.ax2]);

%
%%%
%%%%%
%%%
%