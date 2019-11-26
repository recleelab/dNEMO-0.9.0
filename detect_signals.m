function [updated_keyframe,full_spotInfo] = detect_signals(input_keyframe,frameArray,z_slices,additional_args)
%% fxn which performs signal determination given images and current keyframe settings
%  
%

start_frame = input_keyframe.KF_START;
end_frame = input_keyframe.KF_END;
wav_threshold = input_keyframe.Threshold;
frame_limit = input_keyframe.FrameLim;

num_frames = (end_frame - start_frame) + 1;
% total_frames = size(frameArray,3);
% total_frames = length(frameArray);
total_frames = frameArray.T;
%{
if ~isempty(z_slices)
	total_frames = size(frameArray,3) / z_slices;
end
%}
full_spotInfo = cell([1 total_frames]);

wbar = waitbar(0,'Wavelet Transform 0% Complete');
for i=start_frame:end_frame
	
	if isempty(z_slices)
		
		% TWO-DIM
        
        frameArray = frameArray.setCurrFrame(i);
        curr_image = im2double(frameArray.getCurrFrame());
        
		% [centroids,lbl,indices] = spot_finder_two_dim(frameArray(:,:,i),wav_threshold,1);
		% [centroids,lbl,indices] = spot_finder_two_dim(frameArray{i},wav_threshold,1);
        % [spotInfo] = two_dim_sig_calc(frameArray{i},centroids,lbl,indices);
        [centroids,lbl,indices] = spot_finder_two_dim(curr_image,wav_threshold,1);
        [spotInfo] = two_dim_sig_calc(curr_image,centroids,lbl,indices);
        
        %{
		spotInfo = struct;
		spotInfo = setfield(spotInfo,'objCoords',centroids);
        tmp_spot_mat = [1:size(centroids,1)]';
        spotInfo = setfield(spotInfo,'spotMat',tmp_spot_mat);
		spotInfo = setfield(spotInfo,'UL',lbl);
        spotInfo = setfield(spotInfo,'lbl_centroids',centroids);
		%}
		full_spotInfo{i} = spotInfo;
		
		% waitbar handling
		percent_done = i/num_frames;
		displayed_percent_done = num2str(round(percent_done*100));
		percent_done_message = strcat('Wavelet Transform',{' '},displayed_percent_done,'% Complete');
		waitbar(percent_done,wbar,percent_done_message);
	
	else
		i
		% THREE-DIM
		% current_image = frameArray(:,:,((i-1)*z_slices)+1:(i*z_slices));
        % current_image = frameArray{i};
        
        frameArray = frameArray.setCurrFrame(i);
        current_image = im2double(frameArray.getCurrFrame());
        
		[spotInfo] = spot_finder_three_dim(current_image,wav_threshold,frame_limit,1);
		full_spotInfo{i} = spotInfo;
		
		% waitbar handling
		percent_done = i/num_frames;
		displayed_percent_done = num2str(round(percent_done*100));
		percent_done_message = strcat('Wavelet Transform',{' '},displayed_percent_done,'% Complete');
		waitbar(percent_done,wbar,percent_done_message);
	
	end

end

% removing waitbar
delete(wbar);

input_keyframe = setfield(input_keyframe,'spotInfo',full_spotInfo);
updated_keyframe = input_keyframe;