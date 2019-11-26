function [] = feature_modify(hand, evt, APP)
%% <placeholder>
%

% spot_detect + display_call populates
% UPDATE CENTROID OVERLAY, HAVE IT ROUTE THROUGH DISPLAY CALL
APP.frame_signal_toggle.Value = 1;
% display_call(hand, evt, APP);

% HISTOGRAM UPDATE / SETUP HERE
spot_filter_histogram_setup(APP);

% turn on full creation button
APP.create_keyframe_button.Enable = 'on';
APP.create_keyframe_button.Callback = {@update_spot_detect_feature_select, APP};

%
%%%
%%%%%
%%%
%