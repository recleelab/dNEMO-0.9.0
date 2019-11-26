function [] = inspector_display_image(hand,evt,INSPECT)
%% <placeholder>
%  

% for image display, contrast and brightness changes. will be experimenting
% with the min/max contrast eventually, but for now...

% change image on main axis
image = getappdata(INSPECT.figure_handle,'image');
curr_slice = round(INSPECT.z_slice_slider.Value);

im_selection = INSPECT.rb_image_group.SelectedObject.Tag;
switch im_selection
    case 'MIP'
        I = max(image,[],3);
    case 'SLICE'
        I = image(:,:,curr_slice);
end

if ~isempty(allchild(INSPECT.image_axis))
    prev_xlim = INSPECT.image_axis.XLim;
    prev_ylim = INSPECT.image_axis.YLim;
else
    prev_xlim = [];
    prev_ylim = [];
end

% image handler
% I = max(image,[],3);
% I = image(:,:,curr_slice);

alpha = get(INSPECT.contrast_slider,'value');
beta = get(INSPECT.brightness_slider,'value');

alpha_value = alpha / 50;
low_high = stretchlim(I);
MOD_LO_HI = zeros(2,1);

%  case: 0 < alpha <= 1
if alpha_value <= 1
	difference_01 = low_high(1,1) - 0;
	difference_02 = 1 - low_high(2,1);
	lo_percent = difference_01*alpha_value;
	hi_percent = difference_02*alpha_value;
	MOD_LO_HI(1,1) = 0 + lo_percent;
	MOD_LO_HI(2,1) = 1 - hi_percent;

%  case: alpha > 1
else
	alpha_value = alpha_value - 1;
	difference = low_high(2,1) - low_high(1,1);
	percent = difference * alpha_value;
	MOD_LO_HI(1,1) = low_high(1,1) + percent;
	MOD_LO_HI(2,1) = low_high(2,1) - percent;
end

gamma = 1;
J = imadjust(I,MOD_LO_HI,[0 1],gamma);
K = J + beta;

% place K on the axis
cla(INSPECT.image_axis);
imshow(K,'parent',INSPECT.image_axis);

if ~isempty(prev_xlim)
    INSPECT.image_axis.XLim = prev_xlim;
    INSPECT.image_axis.YLim = prev_ylim;
end

% do same thing, for pixels axis; look for user_tagged scatter object from
% INSPECT.signal_axis
sig_ax_children = allchild(INSPECT.signal_axis);
some_obj = findobj(sig_ax_children,'tag','user_tagged');

if ~isempty(some_obj)
    % IMAGE HANDLER
    PREV_XLIM = INSPECT.pixels_axis.XLim;
    PREV_YLIM = INSPECT.pixels_axis.YLim;

    I = image(:,:,curr_slice);

    alpha = get(INSPECT.contrast_slider,'value');
    beta = get(INSPECT.brightness_slider,'value');

    alpha_value = alpha / 50;
    low_high = stretchlim(I);
    MOD_LO_HI = zeros(2,1);

    %  case: 0 < alpha <= 1
    if alpha_value <= 1
        difference_01 = low_high(1,1) - 0;
        difference_02 = 1 - low_high(2,1);
        lo_percent = difference_01*alpha_value;
        hi_percent = difference_02*alpha_value;
        MOD_LO_HI(1,1) = 0 + lo_percent;
        MOD_LO_HI(2,1) = 1 - hi_percent;

    %  case: alpha > 1
    else
        alpha_value = alpha_value - 1;
        difference = low_high(2,1) - low_high(1,1);
        percent = difference * alpha_value;
        MOD_LO_HI(1,1) = low_high(1,1) + percent;
        MOD_LO_HI(2,1) = low_high(2,1) - percent;
    end

    gamma = 1;
    J = imadjust(I,MOD_LO_HI,[0 1],gamma);
    K = J + beta;

    cla(INSPECT.pixels_axis);
    imshow(K,'parent',INSPECT.pixels_axis);

    INSPECT.pixels_axis.XLim = PREV_XLIM;
    INSPECT.pixels_axis.YLim = PREV_YLIM;
    INSPECT.invisible_axis.XLim = PREV_XLIM;
    INSPECT.invisible_axis.YLim = PREV_YLIM;
end

% run change scatter
inspector_change_scatter(hand,evt,INSPECT);

%
%%%
%%%%%
%%%
%