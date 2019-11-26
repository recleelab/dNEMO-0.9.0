function [] = inspector_hist_click(hand,evt,INSPECT)
%% <placeholder>
%  

disp('histogram click registered');
% need to grab all graphics objects associated with the histogram axis
hist_ax_children = allchild(INSPECT.hist_ax);

% should be the two lines, histogram
pt_clicked = evt.IntersectionPoint;

% clearly identify objects on the hist_ax
line_01 = [];
line_02 = [];
the_histogram = [];
for idx=1:size(hist_ax_children,1)
    curr_type = hist_ax_children(idx).Type;
    if strcmp(curr_type,'line') && isempty(line_01)
        line_01 = hist_ax_children(idx);
    end
    if strcmp(curr_type,'line') && ~isempty(line_01)
        line_02 = hist_ax_children(idx);
    end
    if strcmp(curr_type,'histogram')
        the_histogram = hist_ax_children(idx);
    end
end

% both lines are identified, don't know which is which, but it doesn't
% matter at this point. xdata is key.
line_01_xdata = line_01.XData;
line_02_xdata = line_02.XData;
line_01_diff = abs(line_01_xdata - pt_clicked(1,1));
line_02_diff = abs(line_02_xdata - pt_clicked(1,1));

selected_line = [];
other_line = [];
if line_01_diff > line_02_diff
    selected_line = line_02;
    other_line = line_01;
else
    selected_line = line_01;
    other_line = line_02;
end

% get all valid locations for the selected line to traverse
bin_edges = the_histogram.BinEdges;
other_line_marker = other_line.Marker;
if strcmp(other_line_marker,'>')
    % other line is lower bound
    bin_edges(bin_edges<=other_line.XData(1,1)) = [];
end
if strcmp(other_line_marker,'<')
    % other line is upper bound
    bin_edges(bin_edges>=other_line.XData(1,1)) = [];
end


% call figure motion callback with selected line handle, 
set(INSPECT.figure_handle,'WindowButtonMotionFcn',{@inspector_hist_drag,INSPECT,selected_line,bin_edges});
set(INSPECT.figure_handle,'WindowButtonUpFcn',{@inspector_hist_release,INSPECT,selected_line,bin_edges});

%
%%%
%%%%%
%%%
%