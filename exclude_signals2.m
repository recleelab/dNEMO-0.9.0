function [] = exclude_signals2(APP)
%% <placeholder>
%

% version change handler
curr_version = version;
VS = strsplit(curr_version,' ');
R_STRING = VS{end};
if contains(R_STRING,'2019')
    tmp_2019 = 1;
else
    tmp_2019 = 0;
end

if tmp_2019
    datacursormode off;
end

% need to set APP.ax2 methods
APP.ax2.HitTest = 'on';
APP.ax2.PickableParts = 'all';

% callback
set(APP.ax2,'ButtonDownFcn',{@grab_axis_points,APP});

% pull all scatter children and assign them the same function
scatter_children = findobj(allchild(APP.ax2),'type','scatter');
for ii=1:length(scatter_children)
    disp('assigninig exclusion callback to scatter objects');
    scatter_children(ii).ButtonDownFcn = {@grab_axis_points,APP};
end

%
%%%
%%%%%
%%%
%

function [] = grab_axis_points(hand,evt,APP)
%%
%

% disp('remove_down');

start_point = APP.ax2.CurrentPoint;
figure_point = APP.MAIN.CurrentPoint;

APP.ax2.HitTest = 'off';
APP.ax2.PickableParts = 'none';

set(APP.ax2,'ButtonDownFcn','');

axis_pos = APP.ax2.Position;
accepted_region = zeros(4,2);
accepted_region(1,:) = [axis_pos(1,1) axis_pos(1,2)];
accepted_region(2,:) = [axis_pos(1,1) axis_pos(1,2)+axis_pos(1,4)];
accepted_region(3,:) = [axis_pos(1,1)+axis_pos(1,3) axis_pos(1,2)+axis_pos(1,4)];
accepted_region(4,:) = [axis_pos(1,1)+axis_pos(1,3) axis_pos(1,2)];

set(APP.MAIN,'windowbuttonmotionfcn',{@exclude_mouse_drag,APP,start_point,accepted_region});
set(APP.MAIN,'windowbuttonupfcn',{@exclude_mouse_up,APP,start_point,accepted_region});

%
%%%
%%%%%
%%%
%

function [] = exclude_mouse_drag(hand,evt,APP,start_point,accepted_region)
%%
%

% disp('remove_drag');

single_patch = findobj(APP.ax2,'linestyle','--');
if ~isempty(single_patch)
	delete(single_patch);
end

curr_point = APP.ax2.CurrentPoint;
figure_loc = APP.MAIN.CurrentPoint;

is_drag_valid = inpolygon(figure_loc(1,1),figure_loc(1,2),accepted_region(:,1),accepted_region(:,2));
if is_drag_valid
	
	patch_vals = zeros(4,2);
	
	% (a,b)
	patch_vals(1,1) = start_point(1,1);
	patch_vals(1,2) = start_point(1,2);
	% (a,d)
	patch_vals(2,1) = start_point(1,1);
	patch_vals(2,2) = curr_point(1,2);
	% (c,d)
	patch_vals(3,1) = curr_point(1,1);
	patch_vals(3,2) = curr_point(1,2);
	% (c,b)
	patch_vals(4,1) = curr_point(1,1);
	patch_vals(4,2) = start_point(1,2);
	
	patch(APP.ax2,patch_vals(:,1),patch_vals(:,2),'red','facecolor',...
		'none','edgecolor','red','linestyle','--');

else
	% do nothing -- previous patch will stay until user clicks up
end

%
%%%
%%%%%
%%%
%

function [] = exclude_mouse_up(hand,evt,APP,start_point,accepted_region)
%%
%

% disp('remove_up');

% FOR NOW -- only looking at KEYFRAME currently selected -- may change soon. 
% just want to get bare bones functioning.

% determining endpoint
end_point = APP.ax2.CurrentPoint;
figure_loc = APP.MAIN.CurrentPoint;
is_click_valid = inpolygon(figure_loc(1,1),figure_loc(1,2),accepted_region(:,1),accepted_region(:,2));

% determining set of points being operated upon
% returns [x,y,z,ind]
[displayed_centroids,incl_excl_arr] = determine_current_centroids(APP);

if is_click_valid && ~isempty(displayed_centroids)
	
	if start_point(1,1) == end_point(1,1) && start_point(1,2) == end_point(1,2)
		
		% if end_point == start_point, user clicked on single point, so operation
		% should be based on that.
		[closest_ind,~] = dsearchn(displayed_centroids(:,1:2),[start_point(1,1) start_point(1,2)]);
		if incl_excl_arr(displayed_centroids(closest_ind,4)) == 1
			incl_excl_arr(displayed_centroids(closest_ind,4)) = 0;
		else
			incl_excl_arr(displayed_centroids(closest_ind,4)) = 1;
		end
	%
	else
		
		% disp('using user region');
		
		% using selected region from user to test against signals for current frame
		% bit trickier
		patch_vals = zeros(4,2);
		% start = a,b / end = c,d
		% (a,b)
		patch_vals(1,:) = [start_point(1,1) start_point(1,2)];
		% (a,d)
		patch_vals(2,:) = [start_point(1,1) end_point(1,2)];
		% (c,d)
		patch_vals(3,:) = [end_point(1,1) end_point(1,2)];
		% (c,b)
		patch_vals(4,:) = [end_point(1,1) start_point(1,2)];
		
		% query displayed centroids against region defined by the user
		logically_in_user_region = inpolygon(displayed_centroids(:,1),displayed_centroids(:,2),patch_vals(:,1),patch_vals(:,2));
		% assignin('base','logically_in_user_region',logically_in_user_region);
		if max(logically_in_user_region) == 1
			% need to swap all incl_excl_arr values for those points 
			ind_to_swap = displayed_centroids(logically_in_user_region,4);
			% assignin('base','ind_to_swap',ind_to_swap);
			% currently_incl = find(incl_excl_arr(ind_to_swap)==1);
            currently_incl = find(incl_excl_arr(ind_to_swap)==0);
			% assignin('base','currently_incl',currently_incl);
			% currently_excl = find(incl_excl_arr(ind_to_swap)==0);
            currently_excl = find(incl_excl_arr(ind_to_swap)==1);
			if ~isempty(currently_incl)
				% incl_excl_arr(ind_to_swap(currently_incl)) = 0;
                incl_excl_arr(ind_to_swap(currently_incl)) = 1;
			end
			if ~isempty(currently_excl)
				% incl_excl_arr(ind_to_swap(currently_excl)) = 1;
                incl_excl_arr(ind_to_swap(currently_excl)) = 0;
			end
        end
        
        % assignin('base','excl_arr_after_assign',incl_excl_arr);
	%
	end
end

% reassign incl_excl_arr to appropriate keyframe and whatnot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% NEEDS TO BE UPDATED WHEN KF FIXED!!!!!!!!
%{
KEYFRAMES = getappdata(APP.MAIN,'KEYFRAMES');
curr_kf_no = str2num(APP.keyframe_map.Tag);
KF = KEYFRAMES{1};
frame_no = APP.film_slider.Value;
KF.incl_excl{frame_no} = incl_excl_arr;
KEYFRAMES{1} = KF;
setappdata(APP.MAIN,'KEYFRAMES',KEYFRAMES);
%}

spot_detect = getappdata(APP.MAIN,'spot_detect');
frame_no = APP.film_slider.Value;
spot_detect.manualExclusion{frame_no} = incl_excl_arr;
setappdata(APP.MAIN,'spot_detect',spot_detect);

overlay = getappdata(APP.MAIN,'OVERLAY');
overlay.spotDetectKFExcl = logical(spot_detect.getExclusionLogicArray(frame_no));
setappdata(APP.MAIN,'OVERLAY',overlay);

% disp('exclude mechanics completed');
APP.ax2.HitTest = 'on';
APP.ax2.PickableParts = 'all';

set(APP.MAIN,'windowbuttonupfcn','');
set(APP.MAIN,'windowbuttonmotionfcn','');
display_call(APP.remove_signals_button,1,APP);

%
%%%
%%%%%
%%%
%

function [displayed_centroids,curr_incl_excl] = determine_current_centroids(APP)
%% <placeholder>
%  

% get current keyframe %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% NEEDS TO BE UPDATED!!!!!!!!!!!
%{
KEYFRAMES = getappdata(APP.MAIN,'KEYFRAMES');
curr_kf_no = str2num(APP.keyframe_map.Tag);
if curr_kf_no == 0
	curr_kf_no = 1;
end
KF = KEYFRAMES{curr_kf_no};
%

% get frame spotInfo for current keyframe
frame_no = APP.film_slider.Value;
curr_spotInfo = KF.spotInfo{frame_no};
curr_incl_excl = KF.incl_excl{frame_no};
%}

spot_detect = getappdata(APP.MAIN,'spot_detect');
frame_no = APP.film_slider.Value;
curr_spotInfo = spot_detect.spotInfoArr{frame_no};
curr_incl_excl = spot_detect.getManualExclusions(frame_no);

% starting point
tmp_ind = 1:size(curr_spotInfo.objCoords,1);
frame_centroids = cat(2,curr_spotInfo.objCoords,tmp_ind');
spot_locs_2d = curr_spotInfo.spotLocs2d; 

% get current display settings
[~,values,toggles] = display_check(APP);

if toggles(1,1)
	% all signals in current frame displayed -- return frame_centroids 
    if strcmp(APP.z_slice_slider.Visible,'on')
        displayed_centroids = spot_locs_2d(spot_locs_2d(:,3)==APP.z_slice_slider.Value,:);
    else
        displayed_centroids = frame_centroids;
    end
elseif toggles(1,2)
	% signals in cells only being displayed, either all cells or specific cell
	cell_signals = getappdata(APP.MAIN,'cell_signals');
	if values(3,1) > 0
		% consider specific cell
		curr_signals = cell_signals{values(3,1),curr_kf_no};
		tmp_logic_arr = curr_signals{frame_no};
		if ~isempty(tmp_logic_arr)
			displayed_centroids = frame_centroids(tmp_logic_arr,:);
		else
			displayed_centroids = [];
		end
	else
		% consider all cells
		tmp_logic_arr = zeros(size(frame_centroids,1),1);
        for cell_idx=1:size(cell_signals,1)
            curr_signals = cell_signals{cell_idx,curr_kf_no};
            tmp_arr = curr_signals{frame_no};
            tmp_logic_arr(tmp_arr==1) = 1;
        end
        displayed_centroids = frame_centroids(tmp_logic_arr,:);
	end
else
	% no signals displayed -- return empty displayed_centroids, 
	displayed_centroids = [];
end

%
%%%
%%%%%
%%%
%