function [] = update_exclusion_keyframe_data(hand, evt, APP)
%% <placeholder>
%

exclusion_tmp_struct = getappdata(APP.MAIN,'exclusion_tmp_struct');
spot_detect = getappdata(APP.MAIN,'spot_detect');

new_man_excl_arr = exclusion_tmp_struct.manualExclusion;
frame_no = exclusion_tmp_struct.frameNo;

spot_detect.manualExclusion{frame_no} = new_man_excl_arr;
setappdata(APP.MAIN,'spot_detect',spot_detect);

overlay = getappdata(APP.MAIN,'OVERLAY');
overlay.spotDetectKFExcl = logical(spot_detect.getExclusionLogicArray(frame_no));
setappdata(APP.MAIN,'OVERLAY',overlay);

update_keyframe_data(APP);

% disp('exclude mechanics completed');
APP.ax2.HitTest = 'on';
APP.ax2.PickableParts = 'all';

set(APP.MAIN,'windowbuttonupfcn','');
set(APP.MAIN,'windowbuttonmotionfcn','');
display_call(APP.remove_signals_button,1,APP);

%
%%%
%%%%%
%%%
%