function [] = delete_exclusion_keyframe_data(hand, evt, APP)
%% <placeholder>
%

spot_detect = getappdata(APP.MAIN,'spot_detect');
sel_string = APP.keyframing_map.String{APP.keyframing_map.Value};
spot_detect = spot_detect.removeManualExclusion(sel_string);
setappdata(APP.MAIN,'spot_detect',spot_detect);

% handle overlay object
overlay = getappdata(APP.MAIN,'OVERLAY');
overlay.spotDetectKFExcl = spot_detect.getExclusionLogicArray(overlay.frameNo);
setappdata(APP.MAIN,'OVERLAY',overlay);

update_keyframe_data(APP);
display_call(APP.keyframing_map,1,APP);

%
%%%
%%%%%
%%%
%