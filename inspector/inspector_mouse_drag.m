function [] = inspector_mouse_drag(hand,evt,INSPECT)
%% <placeholder>
% 

accepted_region = getappdata(INSPECT.figure_handle,'accepted_region');
figure_loc = INSPECT.figure_handle.CurrentPoint;

is_drag_valid = inpolygon(figure_loc(1,1),figure_loc(1,2),accepted_region(:,1),accepted_region(:,2));

if is_drag_valid
    current_point = INSPECT.invisible_axis.CurrentPoint;
    displayed_point = round(current_point);
    
    spotInfo_coord = str2num(INSPECT.invisible_axis.Tag);
    spotInfo = getappdata(INSPECT.figure_handle,'spotInfo');
    centroid = spotInfo.objCoords(spotInfo_coord,:);
    image = getappdata(INSPECT.figure_handle,'image');
    current_image = image(:,:,INSPECT.z_slice_slider.Value);
    
    some_val = current_image(displayed_point(1,2),displayed_point(1,1));
    
    % string construction:
	str_x = strcat('X:',num2str(displayed_point(1,1)));
	str_y = strcat('Y:',num2str(displayed_point(1,2)));
	str_raw = strcat('Pixel Value:',{' '},num2str(some_val));
	
	full_string = strcat(str_x,{' '},str_y,{' '},str_raw);
    
    INSPECT.small_display_box.Visible = 'on';
    INSPECT.small_display_box.String = full_string;
    
    % grab patch object in invisible axis
    invis_ax_children = allchild(INSPECT.invisible_axis);
    invis_ax_patch = findobj(invis_ax_children,'Type','patch');
    invis_ax_patch.Visible = 'on';
else
    INSPECT.small_display_box.Visible = 'off';
    INSPECT.small_display_box.String = '';
    
    invis_ax_children = allchild(INSPECT.invisible_axis);
    invis_ax_patch = findobj(invis_ax_children,'Type','patch');
    invis_ax_patch.Visible = 'off';
end

%
%%%
%%%%%
%%%
%