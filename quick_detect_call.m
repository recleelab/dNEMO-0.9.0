function [] = quick_detect_call(hand, evt, APP)
%% callback for APP.quick_detect_button
%

% TMP - still figuring out ordering for this
APP.current_threshold_slider.Enable = 'on';
% END TMP

% pull current image
IMG = getappdata(APP.MAIN,'IMG');
curr_frame = im2double(IMG.getCurrFrame());

% pull current parameters
tmp_app_param = getappdata(APP.MAIN,'APP_PARAM');

% hardcode oversegmentation check to 0 (quick detect exclusive)
tmp_app_param.OVERSEG = 0;

% pull current wavelet threshold
user_threshold = APP.current_threshold_slider.Value;

% w/ waitbar
[spotInfo, interrupt_flag] = spot_finder_interruptible_mod(curr_frame, tmp_app_param, user_threshold);

if interrupt_flag
    return;
end

tmp_app_param.USER_THRESH = user_threshold;
tmp_app_param.FRAME_NO = IMG.CurrFrameNo;

% ASSIGN SIGNAL INFO
bg_off = tmp_app_param.NUM_PIX_OFF;
bg_pix = tmp_app_param.NUM_PIX_BG;

if bg_pix
    
    tmp_waitbar = waitbar(0,'Applying background correction.');
    
    if IMG.Z == 1
        [BG_VALS,~] = two_dim_bg_calc(curr_frame, spotInfo, bg_off, bg_pix);
        spotInfo.BG_VALS = BG_VALS;
    else
        [BG_VALS,~] = assign_bg_pixels(curr_frame, spotInfo, bg_off, bg_pix);
        spotInfo.BG_VALS = BG_VALS;
    end
    
    delete(tmp_waitbar);
end

quick_overlay = TMP_OVERLAY(spotInfo, tmp_app_param);
quick_overlay = quick_overlay.updateSpotFeatures(bg_off, bg_pix);
disp('features updated');

% CHECK for PRE-EXISTING OVERLAY OBJECT
prev_overlay = getappdata(APP.MAIN,'OVERLAY');
if ~isempty(prev_overlay)
    % get previous minima
    prev_min = prev_overlay.spotFeatureMin;
    quick_overlay.spotFeatureMin = prev_min;
    prev_max = prev_overlay.spotFeatureMax;
    quick_overlay.spotFeatureMax = prev_max;
end
setappdata(APP.MAIN,'OVERLAY',quick_overlay);

% UPDATE CENTROID OVERLAY, HAVE IT ROUTE THROUGH DISPLAY CALL
APP.frame_signal_toggle.Value = 1;
display_call(hand, evt, APP);

% HISTOGRAM UPDATE / SETUP HERE
spot_filter_histogram_setup(APP);

% turn on full creation button
APP.create_keyframe_button.Enable = 'on';

%
%%%
%%%%%
%%%
%