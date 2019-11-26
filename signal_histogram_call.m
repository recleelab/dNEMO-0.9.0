function [] = signal_histogram_call(APP)
%% 
%  the histogram data is created before this call is made, so 
%  what remains to be completed is to put the intensity or 
%  size data into a fitted histogram along the APP.hist_ax
%  


% determine whether a histogram has already been created.
hist_ax_children = allchild(APP.hist_ax);

if isempty(hist_ax_children)
	
	% no previous histogram - setup proceeds.
	selected_hist_text = APP.hist_ax_bg.SelectedObject.String;
	
	if strcmp(selected_hist_text,'Intensity')    
		create_intensity_histogram(APP);
	end
	
	if strcmp(selected_hist_text,'Size')
		create_size_histogram(APP);
	end
	
else
	
	% previous histogram present - retain same restrictions
	% user has previously defined.
	selected_hist_text = APP.hist_ax_bg.SelectedObject.String;
	%{
	if strcmp(selected_hist_text,'Intensity')
		
		% pull value from the text box
		curr_intensity_minimum = str2num(APP.hist_ax_intensity_measure.String);
		
		% pass along with the histogram creation.
		create_intensity_histogram(APP,curr_intensity_minimum);
		
	end
	%}
	if strcmp(selected_hist_text,'Size')
		
		%TODO
	
	end
    
end

%
%%%
%%%%%
%%%
%

function [] = create_intensity_histogram(APP,previous_arg)
%% <placeholder>
%

signal_search_toolbox = getappdata(APP.MAIN,'signal_search_toolbox');
hist_data = signal_search_toolbox{1,2};
assignin('base','hist_data',hist_data);

cla(APP.hist_ax);
APP.MAIN.CurrentAxes = APP.hist_ax;

new_hist_objects = histfit(hist_data(:,1),[],'lognormal');
assignin('base','new_hist_objects',new_hist_objects);
delete(new_hist_objects(1));

co = getappdata(APP.MAIN,'color_matrix');

the_curve = new_hist_objects(2);
the_curve.Color = co(1,:);
curve_xdata = the_curve.XData;
curve_ydata = the_curve.YData;

start_x_coord = curve_xdata(1,1);
if nargin > 1
	line(APP.hist_ax,[previous_arg previous_arg],APP.hist_ax.YLim,'color','red','linestyle','--');
	% APP.hist_ax_intensity_measure.String = num2str(previous_arg);
else
	line(APP.hist_ax,[start_x_coord start_x_coord],APP.hist_ax.YLim,'color','red','linestyle','--');
	% APP.hist_ax_intensity_measure.String = num2str(start_x_coord);
end
set(APP.hist_ax,'ButtonDownFcn',{@histogram_clicked,APP});
% set(APP.hist_ax_intensity_measure,'Callback',{@hist_textbox_edit,APP});

disp('intensity histogram created.');

%
%%%
%%%%%
%%%
%

function [] = create_size_histogram(APP,previous_arg)
%% <placeholder>
% 

signal_search_toolbox = getappdata(APP.MAIN,'signal_search_toolbox');
hist_data = signal_search_toolbox{1,2};

cla(APP.hist_ax);
APP.MAIN.CurrentAxes = APP.hist_ax;

new_hist_objects = histfit(hist_data(:,2),[],'normal');
delete(new_hist_objects(2));

co = getappdata(APP.MAIN,'color_matrix');

the_histogram = new_hist_objects(1);
the_histogram.Color = co(1,:);
hist_edges = the_histogram.BinEdges;

start_x_coord = hist_edges(1);
end_x_coord = hist_edges(length(hist_edges));

if nargin > 1
	line(APP.hist_ax,[previous_arg(1) previous_arg(1)],APP.hist_ax.YLim,'color','red','linestyle','--');
	line(APP.hist_ax,[previous_arg(2) previous_arg(2)],APP.hist_ax.YLim,'color','green','linestyle','--');
else
	line(APP.hist_ax,[start_x_coord start_x_coord],APP.hist_ax.YLim,'color','red','linestyle','--');
	line(APP.hist_ax,[end_x_coord end_x_coord],APP.hist_ax.YLim,'color','green','linestyle','--');
end
set(APP.hist_ax,'ButtonDownFcn',{@histogram_clicked,APP});

disp('size histogram created');

%
%%%
%%%%%
%%%
%

function [] = histogram_clicked(hand,evt,APP)
%% fxn that operates when the histogram is clicked
%  

pt_clicked = evt.IntersectionPoint;
hist_ax_children = allchild(APP.hist_ax);

% both are lines
xdata1 = hist_ax_children(1,1).XData;
xdata2 = hist_ax_children(2,1).XData;

if length(xdata1) > length(xdata2)
    % first child is curve
    the_curve = hist_ax_children(1,1);
    the_marker = hist_ax_children(2,1);
else
    the_curve = hist_ax_children(2,1);
    the_marker = hist_ax_children(1,1);
end

curve_xdata = the_curve.XData;
[~,clicked_edge_loc] = min(abs(curve_xdata-pt_clicked(1,1)));
the_marker.XData = [curve_xdata(1,clicked_edge_loc) curve_xdata(1,clicked_edge_loc)];
assignin('base','clicked_edge_loc',clicked_edge_loc);
assignin('base','line_copy',the_marker);

string_val = num2str(curve_xdata(1,clicked_edge_loc));
APP.hist_ax_intensity_measure.String = string_val;

raw_image_data = getappdata(APP.MAIN,'raw_image_data');
[frameArray,minPix,maxPix,z_slices] = raw_image_data{[1,2,3,4]};
centroid_overlay(APP,frameArray,z_slices,2);

%
%%%
%%%%%
%%%
%

function [] = hist_textbox_edit(hand,evt,APP)
%%
% 

% grab string, convert to number
init_string = hand.String;
new_number_val = str2num(init_string);

% need to grab the red line anyways, regardless of what I do next 
% 

hist_ax_children = allchild(APP.hist_ax);
% both are lines
xdata1 = hist_ax_children(1,1).XData;
xdata2 = hist_ax_children(2,1).XData;

if length(xdata1) > length(xdata2)
    % first child is curve
    the_curve = hist_ax_children(1,1);
    the_marker = hist_ax_children(2,1);
else
    the_curve = hist_ax_children(2,1);
    the_marker = hist_ax_children(1,1);
end

curr_marker_xdata = the_marker.XData;
if isempty(new_number_val)
    % not a number, swap text with Xdata
    some_x_val = curr_marker_xdata(1,1);
    hand.String = num2str(some_x_val);
else
    % is a number, swap val into xdata
    the_marker.XData = [new_number_val new_number_val];
end

raw_image_data = getappdata(APP.MAIN,'raw_image_data');
[frameArray,minPix,maxPix,z_slices] = raw_image_data{[1,2,3,4]};
centroid_overlay(APP,frameArray,z_slices,2);

%
%%%
%%%%%
%%%
%