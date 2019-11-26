function [] = update_spot_detect_feature_select(hand, evt, APP)
%% <placeholder>
%

curr_overlay = getappdata(APP.MAIN,'OVERLAY');
spot_detect = getappdata(APP.MAIN,'spot_detect');

spot_detect = spot_detect.addFeatureSelection(curr_overlay);
setappdata(APP.MAIN,'spot_detect',spot_detect);
update_keyframe_data(APP);

APP.create_keyframe_button.Callback = {@create_spot_detection_obj, APP};
APP.create_keyframe_button.Enable = 'off';

%
%%%
%%%%%
%%%
%