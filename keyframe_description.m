function [string_array] = keyframe_description(APP,num_arg)
%% fxn meant to take in current spot filter graphical component values
%  and output some string array describing the current factors
% 

% tmp param
APP_PARAM = getappdata(APP.MAIN,'APP_PARAM');

% num_arg either 1 or 2 -- 1 is 2D, 2 is 3D, I know it's confusing, it'll be okay.

% keyframe starts at frame:
line_01 = string(strcat('Beginning at frame',{' '},APP.start_frame_input.String));

% keyframe ends at frame:
line_02 = string(strcat('Ending at frame',{' '},APP.end_frame_input.String));

% wavelet threshold
line_03 = string(strcat('Wavelet transform threshold:',{' '},APP.current_threshold_display.String));

% # of slices signal must appear in
line_04 = string(strcat('Signals accepted when appearing in more than',{' '},...
    num2str(APP_PARAM.FRAME_LIMIT),{' '},'slices')); 

% accepting signals with corrected intensity > 
% line_05 = string(strcat('Signals accepted with intensity >',{' '},APP.hist_ax_intensity_measure.String));

% combine
string_array = [line_01; line_02; line_03; line_04];
% string_array = [line_01; line_02];