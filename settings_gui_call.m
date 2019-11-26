function [] = settings_gui_call(hand, evt, APP)
%% <placeholder>
%

% pull current application parameters
APP_PARAM = getappdata(APP.MAIN,'APP_PARAM');

% pass along application parameters to current gui
settings_gui_handle = settings_gui(APP_PARAM);
original_name = settings_gui_handle.Name;
waitfor(settings_gui_handle,'name','shutting down');

% pull updated information
CURR_PARAM = getappdata(settings_gui_handle,'CURR_PARAM');
setappdata(APP.MAIN,'APP_PARAM',CURR_PARAM);
delete(settings_gui_handle);

% do a display_check call to see if you're in the middle of keyframe
% creation / adjustment
[process_check,~,~] = display_check(APP);
if process_check==1
    
    %{
    % check to see if frame_lim changed -- if not, don't re-run wavelet
    tmp_toolbox = getappdata(APP.MAIN,'signal_search_toolbox');
    prev_param = tmp_toolbox{5};
    if isempty(prev_param)
        centroid_overlay2(APP, 1);
    end
    %
    
    if CURR_PARAM.FRAME_LIMIT ~= prev_param.FRAME_LIMIT || CURR_PARAM.WAV_LEVEL ~= prev_param.WAV_LEVEL
        centroid_overlay2(APP, 1);
    end
    
    if CURR_PARAM.FRAME_LIMIT == prev_param.FRAME_LIMIT && CURR_PARAM.WAV_LEVEL == prev_param.WAV_LEVEL
        disp('should update histogram');
        cla(APP.hist_ax);
        centroid_overlay2(APP, 2);
    end
    %}
    
end

%
%%%
%%%%%
%%%
%