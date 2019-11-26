function [] = file_reload(hand,evt,APP)
%% 
%  confirm that there's an image in the axis, otherwise reload will fail.
% 

ax_1_children = allchild(APP.ax1);
if isempty(ax_1_children)
    return;
end

[filename,filepath,~] = uigetfile('*.mat');
if filename == 0
    return;
end
init_folder = cd(filepath);
% RELOAD = load(filename,'KEYFRAMES','keyframe_ref_array','cell_signals','polygon_list');
RELOAD = load(filename,'KEYFRAMES','cell_signals','polygon_list');

spot_detect = SPOT_DETECT(RELOAD.KEYFRAMES);
setappdata(APP.MAIN,'spot_detect',spot_detect);
setappdata(APP.MAIN,'cell_signals',RELOAD.cell_signals);
setappdata(APP.MAIN,'polygon_list',RELOAD.polygon_list);

%{
% addendum -- confirm incl_excl is logical
for KF_IDX=1:length(RELOAD.KEYFRAMES)
    
    curr_kf = RELOAD.KEYFRAMES{KF_IDX};
    curr_incl_excl = curr_kf.incl_excl;
    
    for ii=1:length(curr_incl_excl)
        tmp = curr_incl_excl{ii};
        if ~islogical(tmp)
            curr_incl_excl{ii} = logical(tmp);
        end
    end
    
    curr_kf.incl_excl = curr_incl_excl;
    RELOAD.KEYFRAMES{KF_IDX} = curr_kf;
    
end
%}

% setappdata(APP.MAIN,'KEYFRAMES',RELOAD.KEYFRAMES);
% setappdata(APP.MAIN,'keyframe_ref_array',RELOAD.keyframe_ref_array);
% setappdata(APP.MAIN,'cell_signals',RELOAD.cell_signals);
% setappdata(APP.MAIN,'polygon_list',RELOAD.polygon_list);
% APP.keyframe_map.Tag = '0';
clear RELOAD;
cd(init_folder);

% update_user_selection(APP,1);
update_user_selection(APP,2);
APP.frame_signal_toggle.Enable = 'on';
APP.frame_signal_toggle.Value = 1;

curr_frame_no = APP.film_slider.Value;

% populate new overlay object
spotInfo = spot_detect.spotInfoArr{curr_frame_no};
overlay_param = spot_detect.getOverlayParam(curr_frame_no);
bg_off = overlay_param.BG_OFF;
bg_pix = overlay_param.BG_PIX;

tmp_min_maxes = spot_detect.featureMinMaxes;
curr_mins = squeeze(tmp_min_maxes(1,curr_frame_no,:)).';
curr_maxes = squeeze(tmp_min_maxes(2,curr_frame_no,:)).';

new_overlay = TMP_OVERLAY(spotInfo, overlay_param);
new_overlay = new_overlay.updateSpotFeatures(bg_off, bg_pix);
new_overlay.spotFeatureMin = curr_mins;
new_overlay.spotFeatureMax = curr_maxes;
new_overlay.spotDetectFlag = 1;
% new_overlay.spotDetectKFExcl = logical(spot_detect.pullFeatureExclLogicArr(curr_frame_no));
new_overlay.spotDetectKFExcl = logical(spot_detect.getExclusionLogicArray(curr_frame_no));
setappdata(APP.MAIN,'OVERLAY',new_overlay);

update_keyframe_data(APP);
display_call(APP.film_slider,1,APP);


