function [] = display_call(hand,evt,APP)
%% updated display call w/ new GUI 
%  

% acquiring basic information after user has loaded image
IMG = getappdata(APP.MAIN,'IMG');
z_slices = IMG.Z;

if IMG.Z==1
    
    % two dim
    curr_index = round(APP.film_slider.Value);
    APP.film_slider.Value = curr_index;
    
    APP.curr_frame_display.Visible = 'on';
    APP.curr_frame_display.String = strcat('T =',{' '},num2str(curr_index));
    
    IMG = IMG.setCurrFrame(curr_index);
    I = IMG.getCurrFrame();
    
else
    
    % three dim
    curr_index = round(APP.film_slider.Value);
    APP.film_slider.Value = curr_index;
    
    display_select_handle = findobj('checked','on');
    display_select = display_select_handle.Label;
    
    IMG = IMG.setCurrFrame(curr_index);
    I = select_3d_display(APP, IMG, display_select);
    
    APP.curr_frame_display.Visible = 'on';
    APP.curr_frame_display.String = strcat('T =',{' '},num2str(curr_index));
    
end

setappdata(APP.MAIN,'IMG',IMG);

frame_height = IMG.Height;
frame_width = IMG.Width;

if ~isempty(allchild(APP.ax1))
    prev_xlim = APP.ax1.XLim;
    prev_ylim = APP.ax1.YLim;
else
    prev_xlim = [];
    prev_ylim = [];
end

% 	- APP.brightness_slider
% 	- APP.contrast_slider
alpha = APP.contrast_slider.Value;
beta = APP.brightness_slider.Value;
alpha_value = alpha / 50;
low_high = stretchlim(I);
MOD_LO_HI = zeros(2,1);

% 0 < alpha <= 1
if alpha_value <= 1
	
	difference_01 = low_high(1,1) - 0;
	difference_02 = 1 - low_high(2,1);
	lo_percent = difference_01*alpha_value;
	hi_percent = difference_02*alpha_value;
	MOD_LO_HI(1,1) = 0 + lo_percent;
	MOD_LO_HI(2,1) = 1 - hi_percent;

% alpha > 1
else
	
	alpha_value = alpha_value - 1;
	difference = low_high(2,1) - low_high(1,1);
	percent = difference * alpha_value;
	MOD_LO_HI(1,1) = low_high(1,1) + percent;
	MOD_LO_HI(2,1) = low_high(2,1) - percent;

end

gamma = 1;
J = imadjust(I,MOD_LO_HI,[0 1],gamma);

step_val = (max(max(I)) - min(min(I)))./50;

if beta >= 0
    beta = step_val.*beta;
    K = J + beta;
else
    beta = step_val.*abs(beta);
    K = J - beta;
end
imshow(K,'parent',APP.ax1);

if ~isempty(prev_xlim)
    APP.ax1.XLim = prev_xlim;
    APP.ax2.YLim = prev_ylim;
end

cla(APP.ax2);

% display_listener to access storage structures, examine what components need to 
% be enabled or disabled, as well as if there are any active process which supercede
% normal display call
[process_check,value_check,toggle_check] = display_check(APP);

switch process_check
	case 0
		% base case -- normal display measures 
		hold on
		
		% signals
		if value_check(1,1)
			% display_signals(APP,value_check(4,1),toggle_check(1,1),toggle_check(2,1));
            display_signals2(APP,value_check(4,1),toggle_check(1,1),toggle_check(2,1),toggle_check(4,1));
		end
		
		% cells
		if value_check(2,1) && toggle_check(3,1)
			% display_cells(APP,value_check(3,1));
            display_cells2(APP,value_check(3,1));
		end
		
		% trajectories
		if value_check(1,1) && value_check(2,1)
			% display trajectories OR 3D cell 
			display_secondary_info(APP,value_check(3,1));
        end
		
        % feature histogram - dependent on hand, 
        switch hand
            case {APP.film_slider, APP.feature_select_dropdown, APP.keyframing_map}
                overlay = getappdata(APP.MAIN,'OVERLAY');
                if ~isempty(overlay)
                    if overlay.frameNo == curr_index
                        spot_filter_histogram_setup(APP);
                    end
                end
            case {APP.hist_ax}
                overlay = getappdata(APP.MAIN,'OVERLAY');
                if overlay.spotDetectFlag
                    % user manipulating features - clear local keyframing
                    % data
                    spot_detect = getappdata(APP.MAIN,'spot_detect');
                    overlay.spotDetectKFExcl = spot_detect.manualExclusion{overlay.frameNo};
                    setappdata(APP.MAIN,'OVERLAY',overlay);
                end
        end
        
		% additional assignments
		% TODO
		
		hold off
	
	case 1
		% keyframe being created or modified, redirect
		hold on
        % PREV KF METHOD - DEPRECATED
		% keyframe_handler(hand,1,APP);
        
        % overlay object exists in the APP
        overlay = getappdata(APP.MAIN,'OVERLAY');
        if ~isempty(overlay) && toggle_check(1)
            
            if overlay.frameNo ~= APP.film_slider.Value
                return;
            end
            
            APP.ax2.PickableParts = 'visible';
            APP.ax2.HitTest = 'on';
            APP.ax2.ButtonDownFcn = {@select_signal_axis_click, APP};
            
            co = getappdata(APP.MAIN,'color_matrix');

            [all_coords, excl_coords] = overlay.getFrameCoords();
            [slice_coords, excl_coords_slice] = overlay.getSliceCoords(APP.z_slice_slider.Value);
            if strcmp(APP.z_slice_slider.Enable,'on')
                if ~isempty(slice_coords)
                    scatter(APP.ax2,slice_coords(:,1),slice_coords(:,2),[],co(1,:),...
                        'ButtonDownFcn',{@self_scatter_select,APP});
                end
                if ~isempty(excl_coords_slice)
                    scatter(APP.ax2,excl_coords_slice(:,1),excl_coords_slice(:,2),[],'red',...
                        'ButtonDownFcn',{@self_scatter_select,APP});
                end
            else
                if ~isempty(all_coords)
                    scatter(APP.ax2,all_coords(:,1),all_coords(:,2),[],co(1,:),...
                        'ButtonDownFcn',{@self_scatter_select,APP});
                end
                if ~isempty(excl_coords)
                    scatter(APP.ax2,excl_coords(:,1),excl_coords(:,2),[],'red',...
                        'ButtonDownFcn',{@self_scatter_select,APP});
                end
            end

            hold off
        end
	
	%
	%%%
	%
	
	case 2
		% polygon being drawn, redirect
		
		hold on
		
		% polygon_handler(hand,1,APP);
        polygon_modify(APP.add_object_button,1,APP);
		
		if toggle_check(3,1) && value_check(2,1)
			display_cells(APP,value_check(3,1));
		end
		
		hold off
	
	%
	%%%
	%
	
	case 3
		% signals being excluded, redirect
		hold on
		% signals
		if value_check(1,1)
			% display_signals(APP,value_check(4,1),toggle_check(1,1),toggle_check(2,1));
            display_signals2(APP,value_check(4,1),toggle_check(1,1),toggle_check(2,1),toggle_check(4,1));
		end
		
		% cells
		if value_check(2,1) && toggle_check(3,1)
			% display_cells(APP,value_check(3,1));
            display_cells2(APP,value_check(3,1));
		end
		
		% MIGHT have to turn these components off, might be too difficult
		% trajectories
		if value_check(1,1) && value_check(2,1)
			% display trajectories OR 3D cell 
			display_secondary_info(APP,value_check(3,1));
		end

        
        % addendum - display signals that cannot be removed w/ an 'x'
        % display_signals_removed_by_feature(APP,toggle_check(4,1));
        hold off
		
		% actual exclusion call
		% exclude_signals(APP);
        exclude_signals2(APP);

	
	%
	%%%
	%
	
end

% final backup for the whiteout problem
err_flag = backup_ax_check(APP);
if err_flag
    backup_ax_fix(APP,err_flag);
end

%
%%%
%%%%%
%%%
%

function [] = display_cells(APP,num_arg)
%% fxn for displaying cell boundaries as patch object on APP.ax2
%  

% grabbing relevant information
polygon_list = getappdata(APP.MAIN,'polygon_list');
co = getappdata(APP.MAIN,'color_matrix');
frame_no = APP.film_slider.Value;

if num_arg < 1
	% display all available cell boundaries
	%
	for i=1:size(polygon_list,1)
		% tmp_poly = polygon_list{i,1};
        tmp_cell = polygon_list{i,1};   % added for TMP_CELL
        tmp_poly = tmp_cell.polygons;   % added for TMP_CELL
		polygon_in_frame = tmp_poly{1,frame_no};
		polygon_color = mod(i,7);
		if polygon_color == 0
			polygon_color = 7;
		end
		patch_color = co(polygon_color,:);
		patch(APP.ax2,polygon_in_frame(:,1),polygon_in_frame(:,2),patch_color,...
				'FaceColor','none','EdgeColor',patch_color,'LineWidth',1.25);
	end
	%
else
	% display indicated cell patch
	%
	tmp_poly = polygon_list{num_arg,1};
	polygon_in_frame = tmp_poly{1,frame_no};
	polygon_color = mod(num_arg,7);
	if polygon_color == 0
		polygon_color = 7;
	end
	patch_color = co(polygon_color,:);
	patch(APP.ax2,polygon_in_frame(:,1),polygon_in_frame(:,2),patch_color,...
			'FaceColor','none','EdgeColor',patch_color,'LineWidth',1.25);
	%
end

%
%%%
%%%%%
%%%
%

function [] = display_signals(APP,kf_arg,frame_tog,cell_tog)
%% fxn for displaying signals as scatter objects on APP.ax2
%  
% jj1 = APP.ax2.Color;
% assignin('base','jj_beginning_display_signals',jj1);

% quick return
if frame_tog == 0 && cell_tog == 0
	return;
end

% pull necessary storage structures
KEYFRAMES = getappdata(APP.MAIN,'KEYFRAMES');
kf_ref_arr = getappdata(APP.MAIN,'keyframe_ref_array');

% current keyframe selection
curr_tag = str2num(APP.keyframe_map.Tag);

assignin('base','tag_from_keyframe_map',curr_tag);

% current frame
frame_no = APP.film_slider.Value;

KF = [];
kf_no = 0;
if curr_tag > 0
	disp('curr tag > 0');
	% looking at specific keyframe
	kf_no = kf_ref_arr(curr_tag,frame_no);
	if kf_no > 0
		KF = KEYFRAMES{curr_tag};
	end
else
	disp('curr tag <= 0');
	% looking at top keyframe
	kf_no = max(kf_ref_arr(:,frame_no));
	if kf_no > 0
		KF = KEYFRAMES{kf_no};
	end
end
% assignin('base','tmp_kf',KF); % error thrown --> KF object empty, no alternative 
% assigned, so should return at this point too, on top of empty spotInfo

% jj2 = APP.ax2.Color;
% assignin('base','jj_after_KF_determination',jj2);

if isempty(KF)
	return;
else
	spotInfo = KF.spotInfo{frame_no};
	if isempty(spotInfo)
		return;
	end
end

centroids = spotInfo.objCoords;
spot_locs_2d = spotInfo.spotLocs2d;
frame_incl_excl = KF.incl_excl{frame_no};

% jj3 = APP.ax2.Color;
% assignin('base','jj_before_cell_frame_tog',jj3);

% screwups are happening after this point. 

if cell_tog
	disp('cell scatter');
	
	% determine which signals to grab based on keyframe
	cell_signals = getappdata(APP.MAIN,'cell_signals');
	for i=1:size(cell_signals,1)
		
		% grab color
		co = getappdata(APP.MAIN,'color_matrix');
		curr_color = mod(i,7);
		if curr_color == 0
			curr_color = 7;
        end
		
		% grab centroids within cell
		some_cell = cell_signals{i,kf_no};
		curr_cell = some_cell{frame_no};
        curr_cell(frame_incl_excl==0)=0;
		cell_centroids = centroids(curr_cell,:);
		
		% scatter over either curr z slice or max intensity
		if strcmp(APP.z_slice_slider.Enable,'on')
			curr_z_slice = APP.z_slice_slider.Value;
			cell_slice_centroids = cell_centroids(cell_centroids(:,3)==curr_z_slice,:);
			scatter(APP.ax2,cell_slice_centroids(:,1),cell_slice_centroids(:,2),[],co(curr_color,:),'ButtonDownFcn',{@self_scatter_select,APP});
		else
			scatter(APP.ax2,cell_centroids(:,1),cell_centroids(:,2),[],co(curr_color,:),'ButtonDownFcn',{@self_scatter_select,APP});
		end
		
	end
	
else
	disp('regular scatter');
	
	% INSERTION FOR INCL / EXCL ELEMENTS
	
	
	% check if z_slider is active
	if strcmp(APP.z_slice_slider.Enable,'on')
		
		curr_z_slice = APP.z_slice_slider.Value;
		
		incl_excl = KF.incl_excl{1,frame_no};
		if ~isempty(incl_excl)
	
			incl_arr = find(incl_excl);
			incl_centroids = spot_locs_2d(ismember(spot_locs_2d(:,4),incl_arr),:);
			incl_slice_centroids = incl_centroids(incl_centroids(:,3)==curr_z_slice,:);
			scatter(APP.ax2,incl_slice_centroids(:,1),incl_slice_centroids(:,2),'ButtonDownFcn',{@self_scatter_select,APP});
			
			if APP.excluded_signal_toggle.Value == 1
				excl_arr = find(~incl_excl);
				excl_centroids = spot_locs_2d(ismember(spot_locs_2d(:,4),excl_arr),:);
				excl_slice_centroids = excl_centroids(excl_centroids(:,3)==curr_z_slice,:);
				scatter(APP.ax2,excl_slice_centroids(:,1),excl_slice_centroids(:,2),[],'red','ButtonDownFcn',{@self_scatter_select,APP});
			end
			
		else
			slice_centroids = spot_locs_2d(spot_locs_2d(:,3)==curr_z_slice,:);
			scatter(APP.ax2,slice_centroids(:,1),slice_centroids(:,2),'ButtonDownFcn',{@self_scatter_select,APP});
		end
		
	else
		incl_excl = KF.incl_excl{1,frame_no};
		if ~isempty(incl_excl)
			incl_centroids = centroids(incl_excl,:);
			scatter(APP.ax2,incl_centroids(:,1),incl_centroids(:,2),'ButtonDownFcn',{@self_scatter_select,APP});
			
			if APP.excluded_signal_toggle.Value == 1
				excl_centroids = centroids(~incl_excl,:);
				scatter(APP.ax2,excl_centroids(:,1),excl_centroids(:,2),[],'red','ButtonDownFcn',{@self_scatter_select,APP});
			end
			
		else
			scatter(APP.ax2,centroids(:,1),centroids(:,2),'ButtonDownFcn',{@self_scatter_select,APP});
		end
	end

end

%
%%%
%%%%%
%%%
%

function [] = display_secondary_info(APP,cell_arg)
%% fxn for handling display of signal count information over the 
%  APP.trajectory_ax, as well as 3D signal display for single cells

display_trajectory_ax(APP);

% quick switch
if APP.sig_traj_rb1.Value == 1
    % limited trajectory axis update
    polygon_list = getappdata(APP.MAIN,'polygon_list');
    cell_signals = getappdata(APP.MAIN,'cell_signals');

    % for now, changes made to trajectory ax

    frame_no = APP.film_slider.Value;

    ax_children = allchild(APP.trajectory_ax);
    frame_line = findobj(ax_children,'LineStyle','--');
    if ~isempty(frame_line)
        frame_line.XData = [frame_no frame_no];
    end

    if cell_arg > 0
        % emphasize one cell over the others; set all linewidths to normal, except 
        % selected cell
        for i=1:size(ax_children,1)
            if ax_children(i).Tag == cell_arg
                ax_children(i).LineWidth = 2;
            else
                ax_children(i).LineWidth = 1;
            end
        end
    end  
end
if APP.sig_traj_rb2.Value == 1
    % run signal visualization display call
    display_signals_in_3D(APP);
end
	
%{
if cell_arg < 1
	
	curr_kf_tag = str2num(APP.keyframe_map.Tag);
	if curr_kf_tag == 0
		% special case, pull kf_ref_arr
		keyframe_ref_array = getappdata(APP.MAIN,'keyframe_ref_array');
		tmp_seq = max(keyframe_ref_array,[],2);
		
		
	else
		% use curr_kf_tag to pull cell_signals associated @ that keyframe
	end
	
else
	% todo
end
%}

%
%%%
%%%%%
%%%
%

function [] = display_signals2(APP,kf_arg,frame_tog,cell_tog,excl_tog)
%% <placeholder>
%

if ~frame_tog && ~cell_tog
    return;
end

hold on

spot_detect = getappdata(APP.MAIN,'spot_detect');
if ~isempty(spot_detect)
    
    % populate an overlay object w/ the current frame 
    overlay = getappdata(APP.MAIN,'OVERLAY');
    curr_frame_no = APP.film_slider.Value;
    
    if frame_tog || cell_tog
        if curr_frame_no ~= overlay.frameNo
            
            % populate new overlay object
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
            % new_overlay.spotDetectKFExcl = logical(spot_detect.pullFeatureExclLogicArr(curr_frame_no));
            new_overlay.spotDetectKFExcl = logical(spot_detect.getExclusionLogicArray(curr_frame_no));
            setappdata(APP.MAIN,'OVERLAY',new_overlay);
            
        end
    end
    
end

% use overlay
overlay = getappdata(APP.MAIN,'OVERLAY');
if ~isempty(overlay) && frame_tog
    if overlay.frameNo ~= APP.film_slider.Value
        return;
    end

    APP.ax2.PickableParts = 'visible';
    APP.ax2.HitTest = 'on';
    APP.ax2.ButtonDownFcn = {@select_signal_axis_click, APP};

    co = getappdata(APP.MAIN,'color_matrix');

    [all_coords, excl_coords] = overlay.getFrameCoords();
    [slice_coords, excl_coords_slice] = overlay.getSliceCoords(APP.z_slice_slider.Value);
    if strcmp(APP.z_slice_slider.Enable,'on')
        if ~isempty(slice_coords)
            scatter(APP.ax2,slice_coords(:,1),slice_coords(:,2),[],co(1,:),...
                'ButtonDownFcn',{@self_scatter_select,APP});
        end
        if ~isempty(excl_coords_slice) && excl_tog
            scatter(APP.ax2,excl_coords_slice(:,1),excl_coords_slice(:,2),[],'red',...
                'ButtonDownFcn',{@self_scatter_select,APP});
        end
    else
        if ~isempty(all_coords)
            scatter(APP.ax2,all_coords(:,1),all_coords(:,2),[],co(1,:),...
                'ButtonDownFcn',{@self_scatter_select,APP});
        end
        if ~isempty(excl_coords) && excl_tog
            scatter(APP.ax2,excl_coords(:,1),excl_coords(:,2),[],'red',...
                'ButtonDownFcn',{@self_scatter_select,APP});
        end
    end

end

if ~isempty(overlay) && cell_tog
    
    cell_signals = getappdata(APP.MAIN,'cell_signals');
    co = getappdata(APP.MAIN,'color_matrix');
    frame_no = overlay.frameNo;
    
    cell_idx = APP.created_cell_selection.Value - 1;
    if cell_idx==0
        % do all cells
        for tmp_idx=1:length(cell_signals)
            
            curr_cell = cell_signals{tmp_idx};
            curr_cell_logic = curr_cell{frame_no};
            
            tmp_obj_coords = overlay.spotInfo.objCoords;
            feature_incl = overlay.getLogicalInclusions();
            curr_cell_logic(~feature_incl) = 0;
            
            obj_coords = tmp_obj_coords(curr_cell_logic,:);
            curr_color = co(tmp_idx,:);
            if ~isempty(obj_coords)
                scatter(APP.ax2,obj_coords(:,1),obj_coords(:,2),[],curr_color,...
                    'ButtonDownFcn',{@self_scatter_select,APP});
            end
            
            if excl_tog
                % disp('made it to exclusions from cell display');
                tmp_cell_logic = curr_cell{frame_no};
                tmp_cell_logic(feature_incl) = 0;
                % logically_excluded = ~feature_incl;
                % logically_excluded(curr_cell_logic==0) = 0;
                excl_coords = tmp_obj_coords(tmp_cell_logic,:);
                % excl_coords = tmp_obj_coords(logically_excluded,:);
                if ~isempty(excl_coords)
                    scatter(APP.ax2,excl_coords(:,1),excl_coords(:,2),[],'red',...
                        'ButtonDownFcn',{@self_scatter_select,APP});
                end
            end
            
        end
    else
        % do individual cell
        curr_cell = cell_signals{cell_idx};
        curr_cell_logic = curr_cell{frame_no};
        
        tmp_obj_coords = overlay.spotInfo.objCoords;
        feature_incl = overlay.getLogicalInclusions();
        curr_cell_logic(~feature_incl) = 0;
        
        obj_coords = tmp_obj_coords(curr_cell_logic,:);
        curr_color = co(cell_idx,:);
        if ~isempty(obj_coords)
            scatter(APP.ax2,obj_coords(:,1),obj_coords(:,2),[],curr_color,...
                'ButtonDownFcn',{@self_scatter_select,APP});
        end
    end
    
end

hold off

APP.ax2.PickableParts = 'visible';
APP.ax2.HitTest = 'on';

if strcmp(APP.quick_detect_button.Enable,'off')
    % spot_filter_histogram_setup(APP);
end

%
%%%
%%%%%
%%%
%

function [] = display_cells2(APP,num_arg)
%% fxn for displaying cell boundaries as patch object on APP.ax2
%  

% grabbing relevant information
polygon_list = getappdata(APP.MAIN,'polygon_list');
co = getappdata(APP.MAIN,'color_matrix');
frame_no = APP.film_slider.Value;

if num_arg < 1
	% display all available cell boundaries
	%
	for i=1:size(polygon_list,1)
		% tmp_poly = polygon_list{i,1};
        tmp_cell = polygon_list{i,1};   % added for TMP_CELL
        tmp_poly = tmp_cell.polygons;   % added for TMP_CELL
		polygon_in_frame = tmp_poly{1,frame_no};
		polygon_color = mod(i,7);
		if polygon_color == 0
			polygon_color = 7;
		end
		patch_color = co(polygon_color,:);
		patch(APP.ax2,polygon_in_frame(:,1),polygon_in_frame(:,2),patch_color,...
				'FaceColor','none','EdgeColor',patch_color,'LineWidth',1.25);
	end
	%
else
	% display indicated cell patch
	%
	% tmp_poly = polygon_list{num_arg,1};
    tmp_cell = polygon_list{num_arg,1};   % added for TMP_CELL
    tmp_poly = tmp_cell.polygons;   % added for TMP_CELL
	polygon_in_frame = tmp_poly{1,frame_no};
	polygon_color = mod(num_arg,7);
	if polygon_color == 0
		polygon_color = 7;
	end
	patch_color = co(polygon_color,:);
	patch(APP.ax2,polygon_in_frame(:,1),polygon_in_frame(:,2),patch_color,...
			'FaceColor','none','EdgeColor',patch_color,'LineWidth',1.25);
	%
end

%
%%%
%%%%%
%%%
%

function [] = display_signals_removed_by_feature(APP, exclusion_toggle)
%% <placeholder>
%
disp('made it to x-marker display');
assignin('base','exclusion_toggle',exclusion_toggle);
if exclusion_toggle
    
    frame_no = APP.film_slider.Value;
    spot_detect = getappdata(APP.MAIN,'spot_detect');
    obj_coords = spot_detect.spotInfoArr{frame_no}.objCoords;
    feature_excl_logic = spot_detect.featureExclusion{frame_no};
    non_removable_coords = obj_coords(feature_excl_logic,:);
    scatter(APP.ax2,non_removable_coords(:,1),non_removable_coords(:,2),...
        [],'red','marker','x');
    
end

%
%%%
%%%%%
%%%
%