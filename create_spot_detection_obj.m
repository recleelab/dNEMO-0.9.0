function [] = create_spot_detection_obj(hand, evt, APP)
%% <placeholder>
%

% pull current overlay object
overlay = getappdata(APP.MAIN,'OVERLAY');

% pull current spot detect object
spot_detect = getappdata(APP.MAIN,'spot_detect');

% pull IMG
IMG = getappdata(APP.MAIN,'IMG');

mod_overlay_flag = 0;

if isempty(overlay)
    mod_overlay_flag = 1;
    tmp_app_param = getappdata(APP.MAIN,'APP_PARAM');
    tmp_app_param.USER_THRESH = APP.current_threshold_slider.Value;
    tmp_app_param.FRAME_NO = IMG.CurrFrameNo;
    overlay = TMP_OVERLAY([],tmp_app_param);
    overlay.bgOff = tmp_app_param.NUM_PIX_OFF;
    overlay.bgPix = tmp_app_param.NUM_PIX_BG;
    assignin('base','lite_overlay',overlay);
end



% check to see if spot_detect is empty
if isempty(spot_detect)
    
    % create new spot detection
    spot_detect = SPOT_DETECT(IMG, overlay);
    if ~mod_overlay_flag
        spot_detect = spot_detect.addFeatureSelection(overlay);
    else
        spot_detect.featureFields = {'MEAN','MEDIAN','SUM','SIZE','MAX'};
    end
    setappdata(APP.MAIN,'spot_detect',spot_detect);

else
    
    % warning IF wavelet data is going to change things dramatically
    [wav_change_flag] = spot_detect.checkWavChange(overlay);
    if wav_change_flag
        
        init_string = strcat('Warning. Indicated parameters will override',...
            {' '},'current spot detection settings. Any manual exclusions /',...
            {' '},'inclusions will be deleted for the current keyframe.',...
            {' '},'Do you wish to continue?');
        
        answer = questdlg(init_string, 'Spot Detection Parameter Update',...
            'Yes','No','No');
        switch answer
            case 'Yes'
                spot_detect = spot_detect.modifyWavData(IMG, overlay);
                spot_detect = spot_detect.modifyBGData(IMG, overlay);
            case 'No'
                %todo
        end
        
    end
    
    % update spot detection accordingly
    disp('adding feature selection');
    spot_detect = spot_detect.addFeatureSelection(overlay);
    setappdata(APP.MAIN,'spot_detect',spot_detect);
    
    
end

if mod_overlay_flag
    % display_call overlay initialization copied here
    % populate new overlay object
    curr_frame_no = IMG.CurrFrameNo;
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
    setappdata(APP.MAIN,'OVERLAY',new_overlay);
    spot_filter_histogram_setup(APP);
    display_call(APP.film_slider,1,APP);
end

new_overlay = getappdata(APP.MAIN,'OVERLAY');
new_overlay.spotDetectFlag = 1;
new_overlay.spotDetectKFExcl = logical(spot_detect.pullFeatureExclLogicArr(IMG.CurrFrameNo));
setappdata(APP.MAIN,'OVERLAY',new_overlay);

% double check cell signals
coordinate_spots_to_cells(APP);
update_keyframe_data(APP);

% enable certain components
APP.add_object_button.Enable = 'on';

% disable certain components
% APP.quick_detect_button.Enable = 'off';
% APP.full_detect_button.Enable = 'off';
% APP.create_keyframe_button.Enable = 'off';

%
%%%
%%%%%
%%%
%