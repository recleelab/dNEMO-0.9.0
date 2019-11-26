function [] = inspector_call(hand,evt,APP)
%% fxn for initialization of the inspector tool
%  
% 

% pull highlighted object
prev_click = findobj('tag','selected_point');
if ~isempty(prev_click)
    pt_clicked = [prev_click.XData,prev_click.YData];
else
    pt_clicked = [];
end

% update for IMG class
IMG = getappdata(APP.MAIN,'IMG');
frame_no = round(APP.film_slider.Value);
curr_image = im2double(IMG.getCurrFrame());

% check which process we're in the middle of
%{
[processes,~,~] = display_check(APP);
switch processes(1)
    case 0
        % main spot structure - todo
    case 1
        % quick / full detect, pull overlay
        overlay = getappdata(APP.MAIN,'OVERLAY');
        spotInfo = overlay.spotInfo;
end
%}

overlay = getappdata(APP.MAIN,'OVERLAY');
spotInfo = overlay.spotInfo;

% make the call to create the inspection gui
% INSPECT = create_inspection_figure(curr_image,spotInfo,pt_clicked);
INSPECT = tmp_inspect_fig(curr_image,spotInfo,pt_clicked);
waitfor(INSPECT.figure_handle,'Name');

%% changes required past this point !!!!!

% grab relevant information from INSPECT
% param_struct = getappdata(INSPECT.figure_handle,'param_struct');
app_arg = getappdata(INSPECT.figure_handle,'apply_kf_arg');
curr_frame_no = frame_no;
switch app_arg
    case 0
        % do nothing
    case 1
        % pull spot_detect
        spot_detect = getappdata(APP.MAIN,'spot_detect');
        
        % populate new overlay object
        spotInfo = spot_detect.spotInfoArr{curr_frame_no};
        overlay_param = spot_detect.getOverlayParam(curr_frame_no);
        % bg_off = overlay_param.BG_OFF;
        bg_off = INSPECT.offset_slider.Value;
        % bg_pix = overlay_param.BG_PIX;
        bg_pix = INSPECT.background_slider.Value;

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
        % setappdata(APP.MAIN,'OVERLAY',new_overlay);
        
        spot_detect = spot_detect.modifyBGData(IMG, new_overlay);
        setappdata(APP.MAIN,'spot_detect',spot_detect);
        
end

close(INSPECT.figure_handle);
delete('INSPECT');
update_keyframe_data(APP);
display_call(APP.film_slider,1,APP);

%{
% use current keyframe and spotInfo to update
incl_excl = KF.incl_excl;
switch app_arg
    
    case 1
        curr_incl_excl = incl_excl{frame_no};
        new_incl_excl = quick_incl_excl(curr_incl_excl,curr_image,spotInfo,param_struct);
        incl_excl{frame_no} = new_incl_excl;
        KF.incl_excl = incl_excl;
        KEYFRAMES{current_keyframe,1} = KF;
        setappdata(APP.MAIN,'KEYFRAMES',KEYFRAMES);
        
        close(INSPECT.figure_handle);
        delete('INSPECT');
        
        display_call(APP.film_slider,1,APP);
    
    case 2
        %todo
end

% additional callback handling for on/off for figure
%}

%
%%%
%%%%%
%%%
%