function [] = keyframe_handler(hand,evt,APP)
%% fxn meant to handle keyframe creation, deletion, modification, and storage
%  
%  all image axis / signal axis display elements handled via display_call.m, which
%  has purview to pass back to this fxn. 
%  
%  addendum: 

%  grabbing elements from application: 
KEYFRAMES = getappdata(APP.MAIN,'KEYFRAMES');

%{
raw_image_data = getappdata(APP.MAIN,'raw_image_data');
if size(raw_image_data,2) == 3
	[frameArray,minPix,maxPix] = raw_image_data{[1,2,3]};
	z_slices = [];
else
 	[frameArray,minPix,maxPix,z_slices] = raw_image_data{[1,2,3,4]};
end
%}

IMG = getappdata(APP.MAIN,'IMG');
z_slices = IMG.Z;
if isempty(z_slices) || z_slices == 1
    z_slices = [];
end
IMG = IMG.setCurrFrame(round(APP.film_slider.Value));

%% switch based on component called 
%  

switch hand
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	case APP.add_keyframe_button
		% BEGINNING / ENDING KEYFRAME CREATION
		
		test_string = 'Add Keyframe';
		curr_string = get(APP.add_keyframe_button,'string');
		where_are_we = strcmp(test_string,curr_string);
		
		if where_are_we == 1
			% beginning
			disp('beginning keyframe creation');
			master_listener(APP,'keyframe',1);
			signal_search_toolbox = cell(1,6); 
			setappdata(APP.MAIN,'signal_search_toolbox',signal_search_toolbox);
			
			% just starting out, need to do centroid_overlay
			hold on
			% centroid_overlay(APP,IMG,z_slices,1);
            centroid_overlay2(APP, 1);
			hold off

		else
			% ending
			disp('ending keyframe creation');
			master_listener(APP,'keyframe',2);
			display_call(APP.film_slider,1,APP);
		end
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	case APP.create_keyframe_button
		% SAVING KEYFRAME TO STORAGE
		
		if isempty(KEYFRAMES{1})
			insertion_pt = 1;
		else
			insertion_pt = size(KEYFRAMES,1)+1;
		end
		
		keyframe_insert(APP,insertion_pt);
		master_listener(APP,'keyframe',2);
		display_call(APP.film_slider,1,APP);
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	case APP.modify_keyframe_button
		% MODIFYING EXISTING KEYFRAME
		
		curr_string = APP.modify_keyframe_button.String;
		test_string = 'Modify Keyframe';
		starting_to_mod = strcmp(test_string,curr_string);
		
		if starting_to_mod
			% BEGINNING MODIFICATION
			master_listener(APP,'keyframe',3);
            
            % pull relevant features from current keyframe
            % only going to be called on specific keyframe
            keyframe_ref_array = getappdata(APP.MAIN,'keyframe_ref_array');
            curr_kf_idx = APP.keyframe_selection.Value - 1;
            curr_frame_no = APP.film_slider.Value;

            % find value in ref array for this particular frame
            prev_data_check = keyframe_ref_array(curr_kf_idx,curr_frame_no);

            if prev_data_check==0
                % repopulate with warning to check
                % [prev_param, thresh_level, frame_range] = pull_kf_param(KEYFRAMES{curr_kf_idx});
            else
                % repopulate and proceed
                [prev_param, thresh_level, frame_range] = pull_kf_param(KEYFRAMES{curr_kf_idx});
                setappdata(APP.MAIN,'APP_PARAM',prev_param);
                APP.current_threshold_slider.Value = thresh_level;
                APP.current_threshold_display.String = num2str(thresh_level);
                APP.start_frame_input.String = num2str(frame_range(1));
                APP.end_frame_input.String = num2str(frame_range(2));
                hold on
                centroid_overlay(APP,IMG,z_slices,1);
                hold off
                % parameter warning if not current parameter match
            end
            
		else
			% TERMINATING MODIFICATION - 
            insertion_idx = APP.keyframe_selection.Value - 1;
            keyframe_insert(APP, insertion_idx);
			master_listener(APP,'keyframe',2);
            display_call(APP.film_slider,1,APP);
        end
        
        %{
        % pull relevant features from current keyframe
        % only going to be called on specific keyframe
        keyframe_ref_array = getappdata(APP.MAIN,'keyframe_ref_array');
        curr_kf_idx = APP.keyframe_selection.Value - 1;
        curr_frame_no = APP.film_slider.Value;
        
        % find value in ref array for this particular frame
        prev_data_check = keyframe_ref_array(curr_kf_idx,curr_frame_no);
        
        if prev_data_check==0
            % repopulate with warning to check
            % [prev_param, thresh_level, frame_range] = pull_kf_param(KEYFRAMES{curr_kf_idx});
        else
            % repopulate and proceed
            [prev_param, thresh_level, frame_range] = pull_kf_param(KEYFRAMES{curr_kf_idx});
            setappdata(APP.MAIN,'APP_PARAM',prev_param);
            APP.current_threshold_slider.Value = thresh_level;
            APP.current_threshold_display.String = num2str(thresh_level);
            APP.start_frame_input.String = num2str(frame_range(1));
            APP.end_frame_input.String = num2str(frame_range(2));
            centroid_overlay(APP,frameArray,z_slices,1);
            % parameter warning if not current parameter match
        end
        %}
        
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	case APP.film_slider
		% DISPLAY COMPONENT, EITHER USER MANIPULATES OR PASSED IN FROM display_call.m
		
		% threshold = get(APP.current_threshold_slider,'value');
		% frame_no = get(APP.film_slider,'value');
		% set(APP.start_frame_input,'string',num2str(frame_no));
		if APP.frame_signal_toggle.Value == 1
			%todo
		end
		
		% centroid_overlay(APP,IMG,z_slices,1)
        centroid_overlay2(APP,1);
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	case APP.current_threshold_display
		% THRESHOLD ENTERED BY USER
		
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
		
		% wavelet threshold changed -- must redo wavlet transform w/ new threshold
		% centroid_overlay(APP,IMG,z_slices,1);
        centroid_overlay2(APP, 1);
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	case APP.current_threshold_slider
		% THRESHOLD ENTERED BY USER
		
		slider_thresh = get(APP.current_threshold_slider,'val');
		slider_thresh = ceil(20*slider_thresh) / 20;
		set(APP.current_threshold_display,'string',num2str(slider_thresh));
		set(APP.current_threshold_slider,'value',slider_thresh);
		
		% wavelet threshold changed -- must redo wavlet transform w/ new threshold
		% centroid_overlay(APP,IMG,z_slices,1);
		centroid_overlay2(APP, 1);	
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	case {APP.brightness_slider,APP.contrast_slider,APP.frame_signal_toggle,APP.z_slice_slider}
		% display measures only - they will not affect signal determination
		% centroid_overlay(APP,IMG,z_slices,[]);
        centroid_overlay2(APP, []);
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	case APP.start_frame_input
		% only affects final keyframe creation, just check against min / max film_slider
		user_input = str2num(APP.start_frame_input.String);
		
		frame_min = APP.film_slider.Min;
		frame_max = APP.film_slider.Max;
		
		if user_input <= frame_max && user_input >= frame_min
			APP.start_frame_input.String = num2str(round(user_input));
		else
			% out of range, figure out which val is closer and set to it
			if user_input < frame_min
				user_input = APP.film_slider.Min;
			end
			if user_input > frame_max
				user_input = APP.film_slider.Max;
			end
			APP.start_frame_input.String = num2str(user_input);
		end
		
		% centroid_overlay(APP,frameArray,z_slices,[]);
		
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	case APP.end_frame_input
		% only affects final keyframe creation, just check against min / max film_slider
		user_input = str2num(APP.end_frame_input.String);
		
		frame_min = APP.film_slider.Min;
		frame_max = APP.film_slider.Max;
		
		if user_input <= frame_max && user_input >= frame_min
			APP.end_frame_input.String = num2str(round(user_input));
		else
			% out of range, figure out which val is closer and set to it
			if user_input < frame_min
				user_input = APP.film_slider.Min;
			end
			if user_input > frame_max
				user_input = APP.film_slider.Max;
			end
            APP.end_frame_input.String = num2str(user_input);
		end
		
		% centroid_overlay(APP,frameArray,z_slices,[]);
	
end

%
%%%
%%%%%
%%%
%


		