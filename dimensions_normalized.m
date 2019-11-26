function [SCR,PAN,TRAJ,SIG,OBJ,USEL] = dimensions_normalized()
%% function to handle for different screen sizes
%  in general, these measurements are meant to allow for more precise 
%  handling of the figure's different panels and axes and etc.
%  
%  returns a set of values for figure measurements based on screen size
%  
%  NOTE_01: measurements and positioning of components in app are 
%           done using pixel values as units
%
%  NOTE_02: manipulations to axis measurements here will be passed onto
%           methods adjusting axes for accurate locations for displaying 
%           signal coordinates
% 
%  set of measurements layout:
%  SCR = main figure, axes measurements
%  

screen = get(0,'screensize');
screen_width = screen(1,3);
screen_height = screen(1,4);

SCR = zeros(5,4);
PAN = zeros(4,4);
TRAJ = zeros(4,4);
SIG = zeros(18,4);
OBJ = zeros(12,4);
% IMADJ = zeros(8,4);
USEL = zeros(13,4);

%% main figure, axes, and slider measurements
SCR(1,:) = [0.05 0.05 0.88 0.8675]; 	   % APP.MAIN
SCR(2,:) = [0.01 0.04 0.58 0.94];	   % APP.ax1
SCR(3,:) = [0.01 0.005 0.58 0.025];    % APP.film_slider
SCR(4,:) = [0.5825 0.25 0.025 0.5];      % APP.z_slice_slider
% SCR(5,:) = [0.56 0.045 0.02 0.02]; 	% APP.curr_frame_display

%% main panel measurements
PAN(1,:) = [0.61 0.75 0.38 0.24]; % APP.signal_filter_panel
PAN(2,:) = [0.61 0.55 0.38 0.1995]; % APP.cell_creation_panel
PAN(3,:) = [0.61 0.4005 0.38 0.1495]; % APP.user_selection_panel

%% trajectory / sig vis measurements
TRAJ(1,:) = [0.66 0.075 0.28 0.3]; % APP.trajectory_ax, APP.signal_visualization_box
TRAJ(2,:) = [0.945 0.1312 0.045 0.1686]; % APP.sig_traj_bg
TRAJ(3,:) = [0.01 0.51 0.98 0.48]; % APP.sig_traj_rb1
TRAJ(4,:) = [0.01 0.01 0.98 0.48]; % APP.sig_traj_rb2

%% signal filter panel measurements
SIG(1,:) = [0.05 0.275 0.485 0.44];          % APP.hist_ax
SIG(2,:) = [0.05 0.8 0.12 0.18];              % APP.current_threshold_label
SIG(3,:) = [0.18 0.8 0.075 0.18];             % APP.current_threshold_display
SIG(4,:) = [0.3 0.8 0.235 0.15];              % APP.current_threshold_slider
SIG(5,:) = [0.55 0.8 0.12 0.18];              % APP.start_frame_label
SIG(6,:) = [0.68 0.8 0.075 0.18];             % APP.start_frame_input
SIG(7,:) = [0.76 0.8 0.12 0.18];              % APP.end_frame_label
SIG(8,:) = [0.89 0.8 0.075 0.18];             % APP.end_frame_input
SIG(9,:) = [0.83 0.1 0.15 0.35];              % APP.create_keyframe_button
% SIG(10,:) = [0.43 0.455 0.1 0.12];            % APP.hist_ax_intensity_measure
SIG(11,:) = [0.55 0.495 0.1 0.12];     % APP.hist_ax_min_box
SIG(12,:) = [0.55 0.275 0.1 0.12];     % APP.hist_ax_max_box
SIG(13,:) = [0.56 0.495 0.075 0.2];         % APP.hist_ax_min_label
SIG(14,:) = [0.56 0.275 0.075 0.2];      % APP.hist_ax_max_label
SIG(15,:) = [0.05 0.05 0.485 0.15];			  % APP.hist_ax_bg
SIG(16,:) = [0.245 0.12 0.345 0.5];			  % APP.hist_ax_bg_01
SIG(17,:) = [0.605 0.12 0.345 0.5];			  % APP.hist_ax_bg_02

%% cell and keyframe panel measurements
OBJ(1,:) = [0.02 0.7 0.18 0.26];    % APP.add_object_button
OBJ(2,:) = [0.02 0.42 0.18 0.26];    % APP.modify_cell_button
OBJ(3,:) = [0.02 0.15 0.18 0.26];   % APP.delete_object_button
OBJ(4,:) = [0.22 0.7 0.18 0.26];   % APP.add_keyframe_button
OBJ(5,:) = [0.22 0.42 0.18 0.26];   % APP.modify_keyframe_button
OBJ(6,:) = [0.22 0.15 0.18 0.26];   % APP.del_keyframe_button 
OBJ(7,:) = [0.45 0.15 0.53 0.7];     % APP.keyframe_information_box, APP.keyframe_map
OBJ(8,:) = [0.46 0.82 0.235 0.14];   % APP.curr_keyframe_details
OBJ(9,:) = [0.725 0.82 0.245 0.14]; 	% APP.all_keyframe_details
OBJ(10,:) = [0.45 0.82 0.265 0.16]; 	% APP.curr_keyframe_details_pan
OBJ(11,:) = [0.715 0.82 0.265 0.16]; 	% APP.all_keyframe_details_pan
OBJ(12,:) = [0.45 0.04 0.53 0.1]; 	% APP.

%% user selection panel measurements
USEL(1,:) = [0.02 0.745 0.2 0.195];    % APP.b_label
USEL(2,:) = [0.02 0.7 0.21 0.075];    % APP.brightness_slider
USEL(3,:) = [0.02 0.295 0.2 0.195];     % APP.c_label
USEL(4,:) = [0.02 0.25 0.21 0.075];    % APP.contrast_slider
USEL(5,:) = [0.28 0.8 0.4 0.18];    % APP.frame_signal_toggle
USEL(6,:) = [0.28 0.55 0.4 0.18];    % APP.cell_signal_toggle
USEL(7,:) = [0.28 0.30 0.4 0.18];    % APP.cell_boundary_toggle
USEL(8,:) = [0.28 0.05 0.4 0.18];     % APP.excluded_signal_toggle
USEL(9,:) = [0.7 0.745 0.2 0.195];    % APP.cell_label
USEL(10,:) = [0.7 0.7 0.21 0.075];    % APP.created_cell_selection
USEL(11,:) = [0.7 0.25 0.21 0.195];    % APP.remove_signals_button
% USEL(12,:) = [];    % APP.keyframe_label
% USEL(13,:) = [];     % APP.curr_keyframe_selection


%{
%% case 01: normal desktop used @ PITT CSB
%  measurements are 1080P (1920 x 1080)
if screen_width == 1920 && screen_height == 1080
	
	% main figure, axes measurements
	SCR(1,:) = [192 108 1536 864]; % APP.MAIN
	SCR(2,:) = [10 35 960 810];    % APP.ax1
	SCR(3,:) = [10 35 960 810];    % APP.ax2
	SCR(4,:) = [10 15 960 15];     % APP.film_slider
	
	% main panel measurements
	PAN(1,:) = [1000 702 510 150]; % APP.signal_filter_panel
	PAN(2,:) = [1000 500 510 200]; % APP.cell_creation_panel
	PAN(3,:) = [1000 348 510 150]; % APP.adjustment_panel
	PAN(4,:) = [1000 52 150 275];  % APP.user_selection_panel
	
	% trajectory axis measurements
	TRAJ(1,:) = [1225 75 250 250]; % APP.trajectory_ax
	
	% signal filter panel component measurements
	SIG(1,:) = [5 78 60 40];       % APP.current_threshold_label
	SIG(2,:) = [75 95 40 30];      % APP.current_threshold_display
	SIG(3,:) = [130 97 225 25];    % APP.current_threshold_slider
	SIG(4,:) = [5 38 60 40];       % APP.size_search_label
	SIG(5,:) = [75 55 40 30];      % APP.min_size_input
	SIG(6,:) = [185 55 40 30];     % APP.max_size_input
	SIG(7,:) = [5 8 60 40];        % APP.intensity_search_label
	SIG(8,:) = [75 15 40 30];      % APP.min_intensity_input
	SIG(9,:) = [185 15 40 30];     % APP.max_intensity_input
	SIG(10,:) = [120 38 60 40];    % APP.to_01_label
	SIG(11,:) = [120 8 60 40];     % APP.to_02_label
	SIG(12,:) = [365 10 120 35];   % APP.create_keyframe_button
	SIG(13,:) = [365 85 80 40];   % APP.start_frame_label
	SIG(14,:) = [445 95 40 30];   % APP.start_frame_input
	SIG(15,:) = [240 55 125 30];   % APP.blurry_filter_toggle
    
	
	% objects created panel
	OBJ(1,:) = [20 125 120 35];    % APP.add_object_button
	OBJ(2,:) = [20 35 120 35];    % APP.delete_object_button
	OBJ(3,:) = [290 10 185 150];   % APP.keyframe_information_box
	OBJ(4,:) = [145 125 120 35];   % APP.add_keyframe_button
	OBJ(5,:) = [145 35 120 35];   % APP.del_keyframe_button
	OBJ(6,:) = [290 160 180 20];   % APP.curr_keyframe_details_label 
	OBJ(7,:) = [20 80 120 35];     % APP.modify_cell_button
	OBJ(8,:) = [145 80 120 35];   % APP.modify_keyframe_button
	
	
	% image adjustment panel
	IMADJ(1,:) = [275 108 60 30];  % APP.b_label
	IMADJ(2,:) = [275 103 200 20]; % APP.brightness_slider
	IMADJ(3,:) = [275 68 60 30];   % APP.c_label
	IMADJ(4,:) = [275 58 200 20];  % APP.contrast_slider
	IMADJ(5,:) = [25 45 200 30];   % APP.cell_boundary_toggle
	IMADJ(6,:) = [25 15 200 30];   % APP.excluded_signal_toggle
	IMADJ(7,:) = [25 75 200 30];   % APP.cell_signal_toggle
	IMADJ(8,:) = [25 105 200 30];  % APP.frame_signal_toggle
	
	% user selection panel
	USEL(1,:) = [15 225 60 20];    % APP.cell_label
	USEL(2,:) = [15 135 60 20];    % APP.keyframe_label
	USEL(3,:) = [15 140 100 85];     % APP.created_cell_selection
	USEL(4,:) = [15 50 100 85];    % APP.curr_keyframe_selection
	USEL(5,:) = [15 10 120 40];    % APP.remove_signals_button
	

end
%% case 02: 15.4' 2015 Macbook Pro, used by the author
%  measurements are 1440 x 900
if screen_width == 1440 && screen_height == 900
	
	% main figure, axes measurements
	SCR(1,:) = [72 90 1296 720]; % APP.MAIN
	SCR(2,:) = [10 35 720 675];    % APP.ax1
	SCR(3,:) = [10 35 720 675];    % APP.ax2
	SCR(4,:) = [10 15 720 15];     % APP.film_slider
	
	% main panel measurements 
	PAN(1,:) = [750 560 510 150]; % APP.signal_filter_panel
	PAN(2,:) = [750 390 510 165]; % APP.cell_creation_panel
	PAN(3,:) = [750 250 510 135]; % APP.adjustment_panel
	PAN(4,:) = [750 25 150 220];  % APP.user_selection_panel
	
	% trajectory axis measurements 
	TRAJ(1,:) = [1000 25 210 210]; % APP.trajectory_ax, APP.signal_visualization_box
    TRAJ(2,:) = [1235 105 30 100]; % APP.sig_traj_bg
	
	% signal filter panel component measurements 
	SIG(1,:) = [5 90 60 25];       % APP.current_threshold_label
	SIG(2,:) = [75 95 40 30];      % APP.current_threshold_display
	SIG(3,:) = [130 97 225 25];    % APP.current_threshold_slider
	SIG(4,:) = [5 38 60 40];       % APP.size_search_label
	SIG(5,:) = [75 55 40 30];      % APP.min_size_input
	SIG(6,:) = [185 55 40 30];     % APP.max_size_input
	SIG(7,:) = [5 8 60 40];        % APP.intensity_search_label
	SIG(8,:) = [75 15 40 30];      % APP.min_intensity_input
	SIG(9,:) = [185 15 40 30];     % APP.max_intensity_input
	SIG(10,:) = [120 38 60 40];    % APP.to_01_label
	SIG(11,:) = [120 8 60 40];     % APP.to_02_label
	SIG(12,:) = [365 10 120 35];   % APP.create_keyframe_button
	SIG(13,:) = [365 85 80 40];   % APP.start_frame_label
	SIG(14,:) = [445 95 40 30];   % APP.start_frame_input
    SIG(15,:) = [240 55 125 30];   % APP.blurry_filter_toggle
    SIG(16,:) = [370 45 70 40];   % APP.end_frame_label
    SIG(17,:) = [445 55 40 30];   % APP.end_frame_input
	
	% objects created panel 
	OBJ(1,:) = [20 100 120 35];    % APP.add_object_button
	OBJ(2,:) = [20 15 120 35];    % APP.delete_object_button
	OBJ(3,:) = [290 10 185 125];   % APP.keyframe_information_box
	OBJ(4,:) = [145 100 120 35];   % APP.add_keyframe_button
	OBJ(5,:) = [145 15 120 35];   % APP.del_keyframe_button
	OBJ(6,:) = [290 135 180 20];   % APP.curr_keyframe_details_label 
	OBJ(7,:) = [20 60 120 35];     % APP.modify_cell_button
	OBJ(8,:) = [145 60 120 35];   % APP.modify_keyframe_button
	
	
	% image adjustment panel 
	IMADJ(1,:) = [275 93 60 30];  % APP.b_label
	IMADJ(2,:) = [275 88 200 20]; % APP.brightness_slider
	IMADJ(3,:) = [275 53 60 30];   % APP.c_label
	IMADJ(4,:) = [275 38 200 20];  % APP.contrast_slider
	IMADJ(5,:) = [25 35 200 30];   % APP.cell_boundary_toggle
	IMADJ(6,:) = [25 5 200 30];   % APP.excluded_signal_toggle
	IMADJ(7,:) = [25 65 200 30];   % APP.cell_signal_toggle
	IMADJ(8,:) = [25 95 200 30];  % APP.frame_signal_toggle
	
	% user selection panel 
	USEL(1,:) = [15 150 60 20];    % APP.cell_label
	USEL(2,:) = [15 90 60 20];    % APP.keyframe_label
	USEL(3,:) = [15 100 100 50];     % APP.created_cell_selection
	USEL(4,:) = [15 40 100 50];    % APP.curr_keyframe_selection
	USEL(5,:) = [15 10 120 40];    % APP.remove_signals_button
    USEL(6,:) = [95 170 40 30];    % APP.curr_frame_display
    USEL(7,:) = [15 175 80 20];    % APP.curr_frame_label
	
end
%}