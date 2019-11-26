function [] = inspector_display_setup(INSPECT,image)
%% <placeholder>
%  

% display maximum intensity projection of input image
max_intensity_projection = max(image,[],3);
imshow(imadjust(max_intensity_projection),'parent',INSPECT.image_axis);
% inspector_display_image(INSPECT.image_axis,1,INSPECT);
axis_display_sync(INSPECT,INSPECT.image_axis,INSPECT.signal_axis);
linkaxes([INSPECT.image_axis,INSPECT.signal_axis]);

% axis motion register for pixel axis setup
accepted_region = zeros(4,2);
pix_ax_pos = INSPECT.pixels_axis.Position;

accepted_region(1,:) = [pix_ax_pos(1,1) pix_ax_pos(1,2)];
accepted_region(2,:) = [pix_ax_pos(1,1) pix_ax_pos(1,2)+pix_ax_pos(1,4)];
accepted_region(3,:) = [pix_ax_pos(1,1)+pix_ax_pos(1,3) pix_ax_pos(1,2)+pix_ax_pos(1,4)];
accepted_region(4,:) = [pix_ax_pos(1,1)+pix_ax_pos(1,3) pix_ax_pos(1,2)];
setappdata(INSPECT.figure_handle,'accepted_region',accepted_region);

% initial bg label and value creation
inspector_bg_update(INSPECT.offset_slider,1,INSPECT);

% synchronize pixels and invisible axis
axis_display_sync(INSPECT, INSPECT.pixels_axis, INSPECT.invisible_axis);

%
%%%
%%%%%
%%%
%