function [] = centroid_overlay(APP,frameArray,z_slices,num_arg)
%% fxn for handling creation and display of information to user
%  about the keyframe being created.
%  
%  needed to separate out some of the components which weren't working...
%  
%  also this is essentially scratch paper. because i need to keep the same names,
%  and i don't want to break everything too badly.
%  

% frame_limit = getappdata(APP.MAIN,'FRAME_LIMIT');
APP_PARAM = getappdata(APP.MAIN,'APP_PARAM');
frame_limit = APP_PARAM.FRAME_LIMIT;

if ~isempty(num_arg)
	
	switch num_arg
		
		% if num_arg == 1, some change has been made to the set of signals being
		% detected, either the frame_no has changed or the wavelet threshold has changed
		case 1
			
			% pulling necessary elements from APP
			frame_no = APP.film_slider.Value;
			threshold = APP.current_threshold_slider.Value;
			signal_search_toolbox = cell(1,3);
			
			if isempty(z_slices)
				
				% TWO DIM
				% image = frameArray(:,:,frame_no);
                % image = frameArray{frame_no};
                image = im2double(frameArray.getCurrFrame());
				[frame_centroids,lbl,indices] = spot_finder_two_dim(image,threshold,1);
				[spotInfo] = two_dim_sig_calc(image,frame_centroids,lbl,indices);
                % small_struct = create_two_dim_spotInfo(image,frame_centroids,lbl,indices);
				hist_data = create_histogram_data(APP,image,spotInfo,'2D');
				signal_search_toolbox{1,1} = spotInfo;
				signal_search_toolbox{1,2} = hist_data;
				setappdata(APP.MAIN,'signal_search_toolbox',signal_search_toolbox);
				
			else
				
				% THREE DIM
				% image = frameArray(:,:,((frame_no-1)*z_slices)+1:frame_no*z_slices);
                % image = frameArray{frame_no};
                image = im2double(frameArray.getCurrFrame());
				spotInfo = spot_finder_three_dim(image,threshold,frame_limit,1);
                assignin('base','spotInfo',spotInfo);
				hist_data = create_histogram_data(APP,image,spotInfo,'3D');
				signal_search_toolbox{1,1} = spotInfo;
				signal_search_toolbox{1,2} = hist_data;
                signal_search_toolbox{1,3} = ones(size(spotInfo.objCoords,1),1);
				setappdata(APP.MAIN,'signal_search_toolbox',signal_search_toolbox);
			
			end
			
			% hist fit curve needs to be displayed, using APP's current settings
			% signal_histogram_call(APP);
			
			% writing / updating keyframe description
			str_arr = keyframe_description(APP,2);
			APP.keyframe_information_box.String = str_arr;
		
		%
		%%%
		%
		
		case 2 
			
			% user interacted with the histogram in some fashion, and was bounced
			% back here. changes need to be registered in the logically accepted 
			% component of the signal_search_toolbox.
			
			signal_search_toolbox = getappdata(APP.MAIN,'signal_search_toolbox');
			hist_data = signal_search_toolbox{1,2};
			
			% need to pull current values from...
			less_than_this_intensity = str2num(APP.hist_ax_intensity_measure.String);
			logically_acceptable = hist_data >= less_than_this_intensity;
			
			% NOTE - needs to be updated for size as well.
			
			signal_search_toolbox{1,3} = logically_acceptable;
			setappdata(APP.MAIN,'signal_search_toolbox',signal_search_toolbox);
			
			% writing / updating keyframe description
			str_arr = keyframe_description(APP,2);
			APP.keyframe_information_box.String = str_arr;
		
		%
		%%%
		%
		
		case 3
		
			%todo
	end
	
end

% display component

display_frame_signals = APP.frame_signal_toggle.Value;
signal_search_toolbox = getappdata(APP.MAIN,'signal_search_toolbox');

cla(APP.ax2);

if display_frame_signals
	
	% TWO DIM
	if isempty(z_slices)
		disp('should be displaying signals from 2 dim');
		spotInfo = signal_search_toolbox{1,1};
		centroids = spotInfo.objCoords;
		assignin('base','yy_displayed_centroids',centroids);
		co = getappdata(APP.MAIN,'color_matrix');
		
		% hist incl/excl array
		hist_incl_arr = signal_search_toolbox{1,3};
		if ~isempty(hist_incl_arr)

            incl_centroids = centroids(logical(hist_incl_arr),:);
            excl_centroids = centroids(logical(~hist_incl_arr),:);
		
            scatter(APP.ax2,incl_centroids(:,1),incl_centroids(:,2),[],co(1,:));
            scatter(APP.ax2,excl_centroids(:,1),excl_centroids(:,2),[],'red');
        else
            scatter(APP.ax2,centroids(:,1),centroids(:,2),[],co(1,:));
        end
	
	% THREE DIM
	else
		
		spotInfo = signal_search_toolbox{1,1};
		centroids = spotInfo.objCoords;
		spotLocs2d = spotInfo.spotLocs2d;
		
		co = getappdata(APP.MAIN,'color_matrix');
		
		% hist incl/excl array
		hist_incl_arr = signal_search_toolbox{1,3};
		hist_incl_arr = min(hist_incl_arr,[],2);
		
		% get state of z_slice_slider
		z_slice_slider_state = APP.z_slice_slider.Enable;
		
		if strcmp(z_slice_slider_state,'on') == 1
			
			% z_slice_slider is active, only want spots which show up @ current slice
			curr_z_slice = APP.z_slice_slider.Value;
			
			% which centroids are included or excluded
			tmp_incl = find(hist_incl_arr);
			tmp_excl = find(~hist_incl_arr);
			
			incl_centroids = spotLocs2d(ismember(spotLocs2d(:,4),tmp_incl),:);
			incl_slice_centroids = incl_centroids(incl_centroids(:,3)==curr_z_slice,:);
			scatter(APP.ax2,incl_slice_centroids(:,1),incl_slice_centroids(:,2),[],co(1,:));
			
			excl_centroids = spotLocs2d(ismember(spotLocs2d(:,4),tmp_excl),:);
			excl_slice_centroids = excl_centroids(excl_centroids(:,3)==curr_z_slice,:);
			scatter(APP.ax2,excl_slice_centroids(:,1),excl_slice_centroids(:,2),[],'red');

		else
			
			% show all signals
			incl_centroids = centroids(logical(hist_incl_arr),:);
			excl_centroids = centroids(logical(~hist_incl_arr),:);
			
			scatter(APP.ax2,incl_centroids(:,1),incl_centroids(:,2),[],co(1,:));
			scatter(APP.ax2,excl_centroids(:,1),excl_centroids(:,2),[],'red');
			
		end
				
	end

end

disp('scatter done.');

%
%%%
%%%%%
%%%
%

function [small_struct] = create_two_dim_spotInfo(image,centroids,lbl,indices)
%% <placeholder>
%  

% seeing if this works...
% centroids = cat(2,centroids,ones(size(centroids,1),1));

small_struct = struct;
small_struct.objCoords = cat(2,centroids,ones(size(centroids,1),1));
small_struct.spotMat = [1:size(centroids,1)]';
tmp_cell = cell(1);
tmp_cell{1} = lbl;
small_struct.UL = tmp_cell;
tmp_cell{1} = centroids;
small_struct.lbl_centroids = tmp_cell;

[ii, jj] = find(lbl==0);
borderlocs_sub = [jj ii];
borderlocs_ind = lbl==0;
closestcentroid = knnsearch(centroids,borderlocs_sub);
lbl(borderlocs_ind) = lbl(sub2ind(size(lbl),...
	round(centroids(closestcentroid,2)),round(centroids(closestcentroid,1))));

% updating label matrix to reflect any clustered objects
if ~isempty(indices)
	remove_me = find(indices==1);
	updated_lbl = adjust_label_matrix(image,lbl,remove_me,centroids);
    tmp_cell = cell(1);
    tmp_cell{1} = updated_lbl;
	small_struct.UL = tmp_cell;
end

% pulling signal values from associated label matrix
the_lbl = small_struct.UL;
alt_props = regionprops(the_lbl{1},'PixelList');
tmp_pixlist = {alt_props.PixelList}';
tmp_pixlist = tmp_pixlist(2:end,1);

% create intensity profiles for each spot compatible with the 3D operations
% (this is getting messier. you'll have to re-examine later).
signal_values = cell(size(centroids,1),2);
for i=1:size(centroids,1)
    pixlist_currentframe = tmp_pixlist{i};
    intensityvals = image(sub2ind(size(image),...
        pixlist_currentframe(:,2),... % y
        pixlist_currentframe(:,1)));  % x
    signal_values{i,1} = intensityvals;
    signal_values{i,2} = intensityvals;
end

small_struct.SIG_VALS = signal_values;

%
%%%
%%%%%
%%%
%

function [hist_data] = create_histogram_data(APP,image,spotInfo,dim_arg_string)
%% <placeholder>
%  

APP_PARAM = getappdata(APP.MAIN,'APP_PARAM');
num_pix_off = APP_PARAM.NUM_PIX_OFF;
num_pix_bg = APP_PARAM.NUM_PIX_BG;

switch dim_arg_string
	case '2D'
		[BG_VALS,~] = two_dim_bg_calc(image,spotInfo,num_pix_off,num_pix_bg);
	case '3D'
		[BG_VALS,~] = assign_bg_pixels(image,spotInfo,num_pix_off,num_pix_bg);
end
SIG_VALS = spotInfo.SIG_VALS;
% assignin('base','bg_vals',BG_VALS);
% assignin('base','sig_vals',SIG_VALS);

hist_data = zeros(size(SIG_VALS,1),2);
%
for idx=1:length(hist_data)
	hist_data(idx,1) = mean(SIG_VALS{idx,2} - mean(BG_VALS{idx,2}));
end
%
% hist_data(:,1) = cellfun('mean',SIG_VALS(:,2) - cellfun('mean',BG_VALS(:,2)));
hist_data(:,2) = cellfun('length',SIG_VALS(:,1));
hist_data(hist_data(:,1)<=0,1) = 0;

%
%%%
%%%%%
%%%
%