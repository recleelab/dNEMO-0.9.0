function [] = keyframe_insert(APP,insertion_idx)
%% basic function for inserting keyframe into storage structure
%  
% 

raw_image_data = getappdata(APP.MAIN,'raw_image_data');
%{
[frameArray,minPix,maxPix,z_slices] = raw_image_data{[1,2,3,4]};
if isempty(z_slices) || z_slices==1
	str_arg = 1;
else
	str_arg = 2;
end
%}

IMG = getappdata(APP.MAIN,'IMG');
z_slices = IMG.Z;
if isempty(z_slices) || z_slices == 1
    z_slices = [];
    str_arg = 1;
else
    str_arg = 2;
end

%{
if size(raw_image_data,2) == 3
	% 2D
	[frameArray,minPix,maxPix] = raw_image_data{[1,2,3]};
	z_slices = [];
	str_arg = 1;
else
	% 3D
	[frameArray,minPix,maxPix,z_slices] = raw_image_data{[1,2,3,4]};
	str_arg = 2;
end
%}

% [frame_width frame_height nFrames] = size(frameArray);
filename = getappdata(APP.MAIN,'filename');
KEYFRAMES = getappdata(APP.MAIN,'KEYFRAMES');
kf_ref_array = getappdata(APP.MAIN,'keyframe_ref_array');

% determining basic keyframe properties
wavelet_threshold = get(APP.current_threshold_slider,'value');
frame_start = str2num(APP.start_frame_input.String);
frame_end = str2num(APP.end_frame_input.String);
kf_string_arr = keyframe_description(APP,str_arg);

% determining advanced keyframe properties 
% frame_lim = getappdata(APP.MAIN,'FRAME_LIMIT');
APP_PARAM = getappdata(APP.MAIN,'APP_PARAM');
frame_lim = APP_PARAM.FRAME_LIMIT;

% updating keyframe reference array 
number_of_movie_frames = APP.film_slider.Max;
if isempty(kf_ref_array)
	% NEW KEYFRAME
	num_to_add = 1;
	new_row = zeros(1,number_of_movie_frames);
	for i=frame_start:frame_end
		new_row(1,i) = num_to_add;
	end
	kf_ref_array = new_row;
else
	% ADD TO EXISTING
	num_keyframes = size(kf_ref_array,1);
	num_to_add = insertion_idx;
	new_row = zeros(1,number_of_movie_frames);
	for i=frame_start:frame_end
		new_row(1,i) = num_to_add;
	end
	if insertion_idx > num_keyframes
		kf_ref_array = cat(1,kf_ref_array,new_row);
	else
		kf_ref_array(insertion_idx,:) = new_row;
	end
end


% creating new keyframe
new_keyframe = struct;
new_keyframe = setfield(new_keyframe,'Threshold',wavelet_threshold);
new_keyframe = setfield(new_keyframe,'KF_START',frame_start);
new_keyframe = setfield(new_keyframe,'KF_END',frame_end);
new_keyframe = setfield(new_keyframe,'Description',kf_string_arr);

new_keyframe = setfield(new_keyframe,'FrameLim',frame_lim);

% addendum
int_measure = APP_PARAM.INT_MEASURE;
new_keyframe = setfield(new_keyframe,'IntMeasure',int_measure);
sig_measure = APP_PARAM.SIG_MEASURE;
new_keyframe = setfield(new_keyframe,'SigMeasure',sig_measure);

% handling additional arguments
additional_args = [];
additional_args{1} = 0;
additional_args{2} = [];

% supplying new keyframe struct w/ spotInfo field
[new_keyframe,spotInfo] = detect_signals(new_keyframe,IMG,z_slices,additional_args);

incl_excl = cell(1,size(spotInfo,2));

% num_pix_off = getappdata(APP.MAIN,'NUM_PIX_OFF');
num_pix_off = APP_PARAM.NUM_PIX_OFF;
% num_pix_bg = getappdata(APP.MAIN,'NUM_PIX_BG');
num_pix_bg = APP_PARAM.NUM_PIX_BG;

% utilize additional_results,spotInfo to get incl_excl
tmp_count = 1;
for tmp_frame = frame_start:frame_end
	
	tmp_spotInfo = spotInfo{tmp_frame};
	
	% current_image = frameArray(:,:,((tmp_frame-1)*z_slices)+1:(tmp_frame*z_slices));
	% current_image = frameArray{tmp_frame};
    IMG = IMG.setCurrFrame(tmp_frame);
    current_image = im2double(IMG.getCurrFrame());
	if str_arg == 1
		[BG_VALS,BG_LBLS] = two_dim_bg_calc(current_image,tmp_spotInfo,num_pix_off,num_pix_bg);
		SIG_VALS = tmp_spotInfo.SIG_VALS;
		centroids = tmp_spotInfo.objCoords;
		tmp_spotInfo.BG_VALS = BG_VALS;
	else
		[BG_VALS,BG_LBLS] = assign_bg_pixels(current_image,tmp_spotInfo,num_pix_off,num_pix_bg);
		SIG_VALS = tmp_spotInfo.SIG_VALS;
		centroids = tmp_spotInfo.objCoords;
		tmp_spotInfo.BG_VALS = BG_VALS;
	end
	
	% creating histogram data
	histogram_data = zeros(size(centroids,1),1);
	for m=1:size(centroids,1)
    	tmp_bg_mean = mean(BG_VALS{m,2});
    	mid_slice_vals = SIG_VALS{m,2};
    	histogram_data(m) = mean(mid_slice_vals - tmp_bg_mean);
    	if histogram_data(m) <= 0
        	histogram_data(m) = 0;
    	end
	end
	
	% figuring out less than matrix
    if ~isempty(additional_args{1})
        logical_greater_than = histogram_data >= additional_args{1};
    else
        logical_greater_than = histogram_data >= 0;
    end
	
	% assigning logical_less_than back to spotInfo
	incl_excl{tmp_count} = logical_greater_than;
	tmp_count = tmp_count + 1;
	
	spotInfo{tmp_frame} = tmp_spotInfo;
	
end

new_keyframe = setfield(new_keyframe,'incl_excl',incl_excl);
new_keyframe.spotInfo = spotInfo;

% inserting keyframe into existing storage structure
KEYFRAMES{insertion_idx,1} = new_keyframe;

setappdata(APP.MAIN,'KEYFRAMES',KEYFRAMES);
setappdata(APP.MAIN,'keyframe_ref_array',kf_ref_array);

update_user_selection(APP,1);

% check polygon list
polygon_list = getappdata(APP.MAIN,'polygon_list');
if ~isempty(polygon_list)
    coordinate_signals(APP,'keyframe',insertion_idx);
end

%
%%%
%%%%%
%%%
%

