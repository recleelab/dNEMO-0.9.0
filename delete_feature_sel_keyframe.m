function [] = delete_feature_sel_keyframe(hand, evt, APP)
%% <placeholder>
%

spot_detect = getappdata(APP.MAIN,'spot_detect');
sel_string = APP.keyframing_map.String{APP.keyframing_map.Value};

spot_detect = spot_detect.removeFeatureSelection(sel_string);
setappdata(APP.MAIN,'spot_detect',spot_detect);
assignin('base','spot_detect_after_remove',spot_detect);

new_overlay = getappdata(APP.MAIN,'OVERLAY');
new_overlay.spotDetectFlag = 1;
new_overlay.spotDetectKFExcl = logical(spot_detect.pullFeatureExclLogicArr(new_overlay.frameNo));
setappdata(APP.MAIN,'OVERLAY',new_overlay);

update_keyframe_data(APP);
display_call(APP.film_slider, 1, APP);

%
%%%
%%%%%
%%%
%