function [] = wavelet_threshold_callback(hand, evt, APP)
%% <placeholder>
%

switch hand
    
    case APP.current_threshold_display
        
        displayed_thresh = get(APP.current_threshold_display,'string');
		displayed_thresh = str2double(displayed_thresh);
		displayed_thresh = ceil(20*displayed_thresh) / 20;
        
        ovr_min = APP.current_threshold_slider.Min;
		ovr_max = APP.current_threshold_slider.Max;
		if displayed_thresh >= ovr_min && displayed_thresh <= ovr_max
			set(APP.current_threshold_display,'string',num2str(displayed_thresh));
			set(APP.current_threshold_slider,'value',displayed_thresh);
		else
			if displayed_thresh < ovr_min
				set(APP.current_threshold_display,'string',num2str(ovr_min));
				set(APP.current_threshold_slider,'value',ovr_min);
			else
				set(APP.current_threshold_display,'string',num2str(ovr_max));
				set(APP.current_threshold_slider,'value',ovr_max);
			end
		end
        
    case APP.current_threshold_slider
        
        slider_thresh = get(APP.current_threshold_slider,'val');
		slider_thresh = ceil(20*slider_thresh) / 20;
		set(APP.current_threshold_display,'string',num2str(slider_thresh));
		set(APP.current_threshold_slider,'value',slider_thresh);
        
end

%
%%%
%%%%%
%%%
%