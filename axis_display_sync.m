function [] = axis_display_sync(APP,image_axis,object_axis)
%% accepts a figure, examines 2 axes: ax1, and ax2. 
%  ax1 will already have an image object displayed, so
%  image object's limits can be ascertained w/out 
%  having to pass image dimensions into the method.
% 
%  having one axis which displays an image, the 
%  second axis will be repositioned so as to mimic the
%  first axis's positioning of the image object, which
%  otherwise can't be ascertained by MATLAB 
%  (he noted, irkedly).
%
%  only components needed are image object dims and 
%  the image axis dims. One will always be bigger than
%  the other, it's just a matter of accomadating those
%  dimensions (he said, lastwordsingly).
% 

% grab the image_axis's necessary properties
init_xlim = image_axis.XLim;
init_ylim = image_axis.YLim;
init_dar = image_axis.DataAspectRatio;
init_dar_mode = image_axis.DataAspectRatioMode;
init_pbar = image_axis.PlotBoxAspectRatio;
init_pbar_mode = image_axis.PlotBoxAspectRatioMode;

object_axis.XLim = init_xlim;
object_axis.YLim = init_ylim;
object_axis.DataAspectRatio = init_dar;
object_axis.DataAspectRatioMode = init_dar_mode;
object_axis.PlotBoxAspectRatio = init_pbar;
object_axis.PlotBoxAspectRatioMode = init_pbar_mode;

% that should be it...
%{
% ax1 will have single child -- image object
im_object = allchild(APP.ax1);
im_width = im_object.XData(1,2);
im_height = im_object.YData(1,2);

% dimensions of APP.ax1
ax_1_pos = APP.ax1.Position;
ax_1_cols = ax_1_pos(1,3);
ax_1_rows = ax_1_pos(1,4);

% monitor information %%%%% (IS THIS NECESSARY???) %%%%%
screen = get(0,'screensize');
screen_x = screen(1,3);
screen_y = screen(1,4);

x_diff = im_width - ax_1_cols;
y_diff = im_height - ax_1_rows;

% case: both x_diff and y_diff are > 0, which means both dimensions of 
% the image object are larger than the axis position, so it was 
% automatically scaled and centered by MATLAB and needs to be mimicked. 
% (in pixels)
if x_diff > 0 && y_diff > 0
	
	
% case: im_width > axis_width ONLY, im_height is <= axis_height
% (in pixels)
elseif
	%TODO
	
% case: im_height > axis_height ONLY, im_width is <= axis_width
% (in pixels)
elseif
	%TODO
	
% case: both of image object's dimensions are smaller than the axis dimensions
% (in pixels)
else
	%TODO
	
end
%}