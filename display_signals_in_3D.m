function [] = display_signals_in_3D(APP)
%% fxn for displaying signals in 3D space
%  

cla(APP.signal_visualization_box);

polygon_list = getappdata(APP.MAIN,'polygon_list');
cell_signals = getappdata(APP.MAIN,'cell_signals');
KEYFRAMES = getappdata(APP.MAIN,'KEYFRAMES');
frame_no = APP.film_slider.Value;
raw_image_data = getappdata(APP.MAIN,'raw_image_data');
z_slices = raw_image_data{1,4};

% bookkeeping -- turn trajectory ax off
cla(APP.trajectory_ax);
APP.trajectory_ax.Visible = 'off';

% turn signal_visualization_box on
APP.signal_visualization_box.Visible = 'on';

% get current polygon
curr_polygon_idx = APP.created_cell_selection.Value - 1;
curr_polygon_all_frames = polygon_list{curr_polygon_idx,1};
curr_polygon = curr_polygon_all_frames{1,frame_no};

% define box xlim and ylim based on polygon shape
tmp_poly = polyshape(curr_polygon(:,1),curr_polygon(:,2));
[poly_xlim,poly_ylim] = boundingbox(tmp_poly);

% define box zlim based on number of z-slices
poly_zlim = [0 z_slices+1];

% set signal_visualization_box limits
APP.signal_visualization_box.XLimMode = 'manual';
APP.signal_visualization_box.XLim = poly_xlim;
APP.signal_visualization_box.YLimMode = 'manual';
APP.signal_visualization_box.YLim = poly_ylim;
APP.signal_visualization_box.ZLimMode = 'manual';
APP.signal_visualization_box.ZLim = poly_zlim;

% set signal_visualization_box camera elements (rotation)
APP.signal_visualization_box.View = [-45 30];

% get current keyframe 
KF = [];
kf_no = str2num(APP.keyframe_map.Tag);
if kf_no <= 0
    kf_ref_arr = getappdata(APP.MAIN,'keyframe_ref_array');
    kf_no = max(kf_ref_arr(:,frame_no));
    if kf_no > 0
        KF = KEYFRAMES{kf_no};
    end
else
    KF = KEYFRAMES{kf_no};
end

if isempty(KF)
    return;
else
    spotInfo = KF.spotInfo{1,frame_no};
    if isempty(spotInfo)
        return;
    end
end

% centroids associated w/ current polygon
centroids = spotInfo.Centroids;
cell_signals_all_frame = cell_signals{curr_polygon_idx,kf_no};
curr_cell_signals = cell_signals_all_frame{frame_no};
centroids_in_poly = centroids(curr_cell_signals,:);

% get mock z-coordinates associated with current polygon
poly_z = ones(size(curr_polygon,1),1)*round((z_slices+1)/2);

% create colormap
cool_colormap = cool(z_slices+1);
colored_z_mat = zeros(size(centroids_in_poly,1),3);
assignin('base','cool_colormap',cool_colormap);
assignin('base','colored_z_mat',colored_z_mat);
assignin('base','centroids_in_poly',centroids_in_poly);
for i=1:size(centroids_in_poly,1)
    tmp_z_coord = centroids_in_poly(i,3);
    colored_z_mat(i,:) = cool_colormap(tmp_z_coord,:);
end
c = colored_z_mat(:,:);

% display
patch(APP.signal_visualization_box,curr_polygon(:,1),curr_polygon(:,2),poly_z,...
    'black','Facecolor','none','EdgeColor','black','linestyle','--');
scatter3(APP.signal_visualization_box,centroids_in_poly(:,1),centroids_in_poly(:,2),...
    centroids_in_poly(:,3),[],c,'filled');
APP.signal_visualization_box.PickableParts = 'visible';
APP.signal_visualization_box.HitTest = 'on';

% additional callback assignment for rotation and interactivity between
% signal_visualization_box and ax2
set(APP.MAIN,'WindowButtonDownFcn',{@sig_vis_buttondown,APP});

%TODO

%
%%%
%%%%%
%%%
%

function [] = sig_vis_buttondown(hand,evt,APP)
%% fxn for handling rotation, should be better than last time...
% 

disp('buttondown on figure registered!');
assignin('base','evt',evt);

clicked_pt = evt.Source.CurrentPoint;
sig_vis_pos = APP.signal_visualization_box.Position;
accepted_region = zeros(4,2);
accepted_region(1,:) = [sig_vis_pos(1,1),sig_vis_pos(1,2)];
accepted_region(2,:) = [sig_vis_pos(1,1),sig_vis_pos(1,2)+sig_vis_pos(1,4)];
accepted_region(3,:) = [sig_vis_pos(1,1)+sig_vis_pos(1,3),sig_vis_pos(1,2)+sig_vis_pos(1,4)];
accepted_region(4,:) = [sig_vis_pos(1,1)+sig_vis_pos(1,3),sig_vis_pos(1,2)];
assignin('base','ee_region',accepted_region);

if inpolygon(clicked_pt(1,1),clicked_pt(1,2),accepted_region(:,1),accepted_region(:,2))
    disp('pt w/in polygon');
    tmp_handle = rotate3d;
end

%
%%%
%%%%%
%%%
%

function [] = sig_vis_buttonup(hand,evt,APP)
%% fxn for handling the up part
% 

rotate3d(APP.signal_visualization_box,'off');
set(APP.MAIN,'windowbuttonupfcn','');
