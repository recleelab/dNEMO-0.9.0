function [] = inspector_pixel_information_display(INSPECT,spotInfo,true_ind)
%% <placeholder>
%  

disp('navigated to inspector_pixel_information_display.m');

I = getappdata(INSPECT.figure_handle,'image');
single_centroid = spotInfo.objCoords(true_ind,:);
% [z_ax_profile,signal_profile,signal_intensities] = create_z_profile_v3(INSPECT,I,spotInfo,true_ind);
[raw_zdata,frames] = create_z_profile_v3(INSPECT,I,spotInfo,true_ind);
disp('created zdata successfully');

% display - messy, needs fixing
cla(INSPECT.z_profile);
color_matrix = getappdata(INSPECT.figure_handle,'color_matrix');

% plotting on z profile
plot(INSPECT.z_profile,raw_zdata(:,2),raw_zdata(:,1),'color','black');
plot(INSPECT.z_profile,INSPECT.z_profile.XLim,[frames(1,1) frames(1,1)],'color',color_matrix(1,:),'LineStyle','--');
plot(INSPECT.z_profile,INSPECT.z_profile.XLim,[frames(1,size(frames,2)) frames(1,size(frames,2))],'color',color_matrix(1,:),'LineStyle','--');

% handle z_slider
INSPECT.z_slice_slider.Enable = 'on';
INSPECT.z_slice_slider.Value = single_centroid(1,3);

% updating the main analysis axis
inspector_update_pixels_axis(INSPECT.z_slice_slider,1,INSPECT,true_ind);
INSPECT.z_slice_slider.Callback = {@inspector_update_pixels_axis,INSPECT,true_ind};

bbox = getappdata(INSPECT.figure_handle,'curr_bbox');
bg_and_off = INSPECT.offset_slider.Value + INSPECT.background_slider.Value;

x_diff = bbox(1,2) - bbox(1,1);
y_diff = bbox(1,4) - bbox(1,3);

if x_diff > y_diff
    diff_diff = x_diff - y_diff;
    INSPECT.pixels_axis.XLim = [bbox(1,1)-bg_and_off-3 bbox(1,2)+bg_and_off+3];
    INSPECT.pixels_axis.YLim = [bbox(1,3)-bg_and_off-3 bbox(1,4)+bg_and_off+3+diff_diff];
else
    diff_diff = y_diff - x_diff;
    INSPECT.pixels_axis.XLim = [bbox(1,1)-bg_and_off-3 bbox(1,2)+bg_and_off+3+diff_diff];
    INSPECT.pixels_axis.YLim = [bbox(1,3)-bg_and_off-3 bbox(1,4)+bg_and_off+3];
end
INSPECT.invisible_axis.XLim = INSPECT.pixels_axis.XLim;
INSPECT.invisible_axis.YLim = INSPECT.pixels_axis.YLim;

% mouse drag
set(INSPECT.figure_handle,'WindowButtonMotionFcn',{@inspector_mouse_drag,INSPECT});
% need to handle profile bg as well

%
%%%
%%%%%
%%%
%