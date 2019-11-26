function [] = centroid_overlay_mod(APP, frameArray, z_slices, num_arg)
%% <placeholder>
%

APP_PARAM = getappdata(APP.MAIN,'APP_PARAM');
frame_limit = APP_PARAM.FRAME_LIMIT;
overseg = APP_PARAM.OVERSEG;

if ~isempty(num_arg)
    
    % pull relevant values from APP
    frame_no = APP.film_slider.Value;
    threshold = APP.current_threshold_slider.Value;
    
    if isempty(z_slices) || z_slices==1
        % TWO DIM
    else
        % THREE DIM
        image = frameArray{frame_no};
        [spotInfo] = overlay_three_dim(image, threshold, frame_limit, overseg);
        signal_search_toolbox = {spotInfo};
        setappdata(APP.MAIN,'signal_search_toolbox',signal_search_toolbox);
    end
    
end

%
%%%
%%%%%
%%%
%