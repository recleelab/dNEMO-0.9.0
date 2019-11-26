function [] = inspector_bg_update(hand,evt,INSPECT)
%% <placeholder>
%  

% get offset, bg values
offset_val = round(INSPECT.offset_slider.Value);
INSPECT.offset_slider.Value = offset_val;
bg_val = round(INSPECT.background_slider.Value);
INSPECT.background_slider.Value = bg_val;

% run assign_bg_pixels.m to get new bg_lbls from which to pull values
image = getappdata(INSPECT.figure_handle,'image');
spotInfo = getappdata(INSPECT.figure_handle,'spotInfo');

if size(image, 3) == 1
    [BG_VALS,BG_LBLS] = two_dim_bg_calc(image, spotInfo, offset_val, bg_val);
else
    [BG_VALS,BG_LBLS] = assign_bg_pixels(image,spotInfo,offset_val,bg_val);
end

% assign the values to INSPECT
setappdata(INSPECT.figure_handle,'curr_bg_vals',BG_VALS);
setappdata(INSPECT.figure_handle,'curr_bg_lbls',BG_LBLS);

% call inspector_update_pixels_axis if pixels axis has graphics object
% children
pix_ax_children = allchild(INSPECT.pixels_axis);
if ~isempty(pix_ax_children)
    true_ind = str2num(INSPECT.invisible_axis.Tag);
    inspector_update_pixels_axis(hand,evt,INSPECT,true_ind);
end

%
%%%
%%%%%
%%%
%