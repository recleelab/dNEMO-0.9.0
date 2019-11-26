function[I] = select_3d_display(APP, IMG, display_option)
%% meant to return image to display and be altered regardless of state
%

curr_image = IMG.getCurrFrame();
frame_height = IMG.Height;
frame_width = IMG.Width;
z_slices = IMG.Z;

%{
frame_height = size(frameArray,2);
frame_width = size(frameArray,1);
curr_index = round(get(APP.film_slider,'value'));
set(APP.film_slider,'value',curr_index);
%}

switch display_option
	case 'Max Z-Project'
		
		% taking current index, combined with z_slices, to create one-off MIP of current 
		% slice
        %{
		start_point = ((curr_index * z_slices) - z_slices) + 1;
		end_point = curr_index * z_slices;
		mip_slice = zeros(frame_width,frame_height,z_slices);
		j = 1;
		for i=start_point:end_point
			mip_slice(:,:,j) = frameArray(:,:,i);
			j = j + 1;
        end
        
        I = max(mip_slice,[],3);
        
        %}
		
		I = IMG.getZProject();
		
		set(APP.z_slice_slider,'enable','off','visible','off');
        
        % handling z_slice annotation removal
        annotation_objects = allchild(findobj(allchild(APP.MAIN),'Type','annotation'));
        for ann_idx=1:length(annotation_objects)
            if strcmpi(annotation_objects(ann_idx).Type,'TextBox')
                tmp_string = annotation_objects(ann_idx).String;
                if contains(tmp_string,'Z')
                    delete(annotation_objects(ann_idx));
                end
            end
            if strcmpi(annotation_objects(ann_idx).Type,'TextBoxShape')
                tmp_string = annotation_objects(ann_idx).String;
                if contains(tmp_string,'Z')
                    delete(annotation_objects(ann_idx));
                end
            end
        end
	
	case 'Icy MIP'
		set(APP.z_slice_slider,'enable','off','visible','off');
		
		lut_array = zeros(32,3,'uint8');
		lut_array(:,1) = [0,0,0,0,0,0,19,29,50,48,79,112,134,158,186,201,217,229,242,250,250,250,250,251,250,250,250,250,251,251,243,230];
		lut_array(:,2) = [156,165,176,184,190,196,193,184,171,162,146,125,107,93,81,87,92,97,95,93,93,90,85,69,64,54,47,35,19,0,4,0];
		lut_array(:,3) = [140,147,158,166,170,176,209,220,234,225,236,246,250,251,250,250,245,230,230,222,202,180,163,142,123,114,106,94,84,64,26,27];
		
		local_min = 255;
		local_max = 0;
		start_point = ((curr_index - 1)*z_slices)+1;
		end_point = curr_index * z_slices;
		curr_frame = frameArray(:,:,start_point:end_point);
		ff = im2uint16(curr_frame);
		normalized_ff = uint8(255*mat2gray(ff));
		
		[maxes,maxes_indices] = max(normalized_ff,[],3);
		new_rgb_image = zeros(frame_height,frame_width,3);

		% create all colormaps in their own object
		all_colormaps = zeros(255,3,z_slices);
		for m=1:z_slices
    		single_slice_color = lut_array(round((32/z_slices)*m),:);
    		for n=1:3
        		some_color_channel = single_slice_color(n);
        		if some_color_channel == 0
            		% ignore
        		else
            		all_colormaps(:,n,m) = round(linspace(0,double(some_color_channel),double(255)));
        		end
    		end
		end

		all_colormaps_mod = double(all_colormaps) / 255;

		for q=1:frame_height
    		for p=1:frame_width
        		temp_max_val = maxes(q,p); % points to value out of 255 for a given color map
        		temp_max_val_index = maxes_indices(q,p); % points to which color map
        		color_to_select = all_colormaps_mod(temp_max_val,:,temp_max_val_index);
        
        		new_rgb_image(q,p,:) = color_to_select;
    		end
		end
		
		I = im2uint8(new_rgb_image);
		
	case 'Full 3D Stack'
		set(APP.z_slice_slider,'enable','on','max',z_slices,'visible','on');
		curr_slice_num = round(get(APP.z_slice_slider,'value'));
    	set(APP.z_slice_slider,'value',curr_slice_num);
    	set(APP.z_slice_slider,'sliderstep',[1/z_slices 1/z_slices]);
        
        % I = curr_image(:,:,curr_slice_num);
        I = IMG.getZSlice(curr_slice_num);
        
        % handling z slice annotation
        annotation_objects = allchild(findobj(allchild(APP.MAIN),'Type','annotation'));
        already_displayed_z = 0;
        for ann_idx=1:length(annotation_objects)
            if strcmpi(annotation_objects(ann_idx).Type,'TextBox')
                tmp_string = annotation_objects(ann_idx).String;
                if contains(tmp_string,'Z')
                    % replace Z annotation string
                    annotation_objects(k).String = strcat('Z =',{' '},num2str(curr_slice_num));
                    already_displayed_z = 1;
                end
            end
            if strcmpi(annotation_objects(ann_idx).Type,'TextBoxShape')
                tmp_string = annotation_objects(ann_idx).String;
                if contains(tmp_string,'Z')
                    % replace Z annotation string
                    annotation_objects(ann_idx).String = strcat('Z = ',{' '},num2str(curr_slice_num));
                    already_displayed_z = 1;
                end
            end
        end
        
        if ~already_displayed_z
            tmp_pos = APP.curr_frame_display.Position;
            z_slice_display = annotation(APP.MAIN,...
                'textbox',[tmp_pos(1,1) tmp_pos(1,2)+tmp_pos(1,4) tmp_pos(1,3) tmp_pos(1,4)],...
                'String',strcat('Z =',{' '},num2str(curr_slice_num)),...
                'color','red',...
                'HorizontalAlignment','right',...
                'VerticalAlignment','bottom',...
                'EdgeColor','none',...
                'FontSize',14,...
                'FitBoxToText','on',...
                'visible','on');
        end
        
        %{
        if size(annotation_objects,1) > 1
        	% simply replace string on Z annotation
        	for k=1:size(annotation_objects,1)
        		if contains(annotation_objects(k).String,'Z')
        			annotation_objects(k).String = strcat('Z =',{' '},num2str(curr_slice_num));
        		end
        	end
        else
        	% create, display Z annotation
        	tmp_pos = APP.curr_frame_display.Position;
        	z_slice_display = annotation(APP.MAIN,...
        		'textbox',[tmp_pos(1,1) tmp_pos(1,2)+tmp_pos(1,4) tmp_pos(1,3) tmp_pos(1,4)],...
        		'String',strcat('Z =',{' '},num2str(curr_slice_num)),...
        		'color','red',...
        		'HorizontalAlignment','right',...
        		'VerticalAlignment','bottom',...
        		'EdgeColor','none',...
        		'FontSize',14,...
        		'FitBoxToText','on',...
        		'visible','on');
        end
        %}
    
end
		
