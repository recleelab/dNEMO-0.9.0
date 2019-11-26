function [] = inspector_update_pixels_axis(hand,evt,INSPECT,true_ind)
%% <placeholder>
% 

spotInfo = getappdata(INSPECT.figure_handle,'spotInfo');
% image = getappdata(INSPECT.figure_handle,'image');
spotMat = spotInfo.spotMat;

centroid = spotInfo.objCoords(true_ind,:);
frames = find(spotMat(true_ind,:)~=0);
curr_slice = round(hand.Value);
hand.Value = curr_slice;

% IMAGE HANDLER
inspector_display_image(hand,evt,INSPECT);
%{
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
%}

% display on top of zoomed in image
cla(INSPECT.invisible_axis);
curr_slice = round(INSPECT.z_slice_slider.Value);
INSPECT.z_slice_slider.Value = curr_slice;

profile_axis_children = allchild(INSPECT.z_profile);

% background line
bg_line = findobj(profile_axis_children,'color','red');
if ~isempty(bg_line)
    delete(bg_line);
end

% slider pointer
slider_line = findobj(profile_axis_children,'linestyle',':');
if ~isempty(slider_line)
    delete(slider_line);
end

% find pixel coordinates using spotInfo / spotMat / UL
if ismember(curr_slice,frames)
    
    % display the signal information
    curr_lbl = spotInfo.UL{curr_slice};
    curr_lbl_pointer = spotMat(true_ind,curr_slice);
    [signal_y,signal_x] = find(curr_lbl==curr_lbl_pointer+1);
    
    % scattering signal
    scatter(INSPECT.invisible_axis,signal_x,signal_y,'green','marker','.');
    
    % display offset information
    curr_bg_lbls = getappdata(INSPECT.figure_handle,'curr_bg_lbls');
    slice_bg_lbl = curr_bg_lbls{curr_slice};
    slice_bg_lbl(slice_bg_lbl==curr_lbl) = 0;
    [offset_y,offset_x] = find(slice_bg_lbl==curr_lbl_pointer+1);
    
    % scatter offset
    if ~isempty(offset_y)
        scatter(INSPECT.invisible_axis,offset_x,offset_y,'yellow',...
            'marker','diamond','MarkerEdgeAlpha',0.6);
    end
    
    % display background information
    [background_y,background_x] = find(slice_bg_lbl==-1*(curr_lbl_pointer+1));
    
    % scatter background
    scatter(INSPECT.invisible_axis,background_x,background_y,'red',...
        'marker','square','MarkerEdgeAlpha',0.6);
    
    % establish background line using true_ind and curr_bg_vals
    BG_VALS = getappdata(INSPECT.figure_handle,'curr_bg_vals');
    background_values = BG_VALS{true_ind,2};
    line(INSPECT.z_profile,[mean(background_values),mean(background_values)],INSPECT.z_profile.YLim,...
        'color','red','linewidth',0.75);
    
end



% bbox patched, invisible
bb = getappdata(INSPECT.figure_handle,'curr_bbox');
color_matrix = getappdata(INSPECT.figure_handle,'color_matrix');
bbox_pts = [bb(1,1),bb(1,3);bb(1,1),bb(1,4);bb(1,2),bb(1,4);bb(1,2),bb(1,3)];
patch(INSPECT.invisible_axis,bbox_pts(:,1),bbox_pts(:,2),color_matrix(1,:),'FaceColor','none',...
    'EdgeColor',color_matrix(1,:),'EdgeAlpha',0.75,'LineStyle','--','Visible','off');

% addendum - reassign invisible_axis limits to match pixels_axis
prev_xlim = INSPECT.pixels_axis.XLim;
prev_ylim = INSPECT.pixels_axis.YLim;
INSPECT.invisible_axis.XLim = prev_xlim;
INSPECT.invisible_axis.YLim = prev_ylim;

% additional z-profile items
line(INSPECT.z_profile,INSPECT.z_profile.XLim,[curr_slice curr_slice],'color','black',...
    'linestyle',':','linewidth',1.25);
line(INSPECT.z_profile,INSPECT.z_profile.XLim,[centroid(1,3) centroid(1,3)],...
    'color','green','linestyle','--','linewidth',1.0);

%
%%%
%%%%%
%%%
%