function [] = create_signal_distribution(APP, ax_hand, signal_info, str_arg)
%% creates interactive distribution based on data from overlay
%

signal_search_toolbox = getappdata(APP.MAIN,'signal_search_toolbox');
prev_entry = signal_search_toolbox{6};
prev_ind = 0;

switch str_arg
    case 'Intensity'
        data_arr = signal_info(:,1);
        prev_ind = 1;
    case 'Size'
        data_arr = signal_info(:,2);
        prev_ind = 2;
end

some_hand = histogram(ax_hand,data_arr);
some_edges = some_hand.BinEdges;

start_x = some_edges(1);
end_x = some_edges(end);

if max(prev_entry(:,prev_ind)) > 0
    start_x = prev_entry(1,prev_ind);
    end_x = prev_entry(2,prev_ind);
end

% selectors for the user
line(ax_hand,[start_x start_x],ax_hand.YLim,'color','red',...
    'linestyle','--','marker','>');
line(ax_hand,[end_x end_x],ax_hand.YLim,'color','green',...
    'linestyle','--','marker','<');
ax_hand.ButtonDownFcn = {@distribution_clicked,APP};
some_hand.ButtonDownFcn = {@distribution_clicked,APP};

ax_hand.HitTest = 'on';
ax_hand.PickableParts = 'visible';

% set APP radiobuttons callbacks
APP.hist_ax_min_box.String = '0';
APP.hist_ax_max_box.String = num2str(end_x);

APP.hist_ax_bg_01.Callback = {@hist_quick_call, APP};%, APP.hist_ax, signal_info, APP.hist_ax_bg_01.String};
APP.hist_ax_bg_02.Callback = {@hist_quick_call, APP};%, APP.hist_ax, signal_info, APP.hist_ax_bg_02.String};

APP.hist_ax_max_box.Callback = {@hist_box_callback, APP};
APP.hist_ax_min_box.Callback = {@hist_box_callback, APP};

APP.hist_ax.XLim(1) = 0;
APP.hist_ax.XTickMode = 'auto';
APP.hist_ax.XLimMode = 'auto';

%
%%%
%%%%%
%%%
%

function [] = distribution_clicked(hand, evt, APP)
%% <placeholder>
%

disp('histogram click registered');

pt_clicked = evt.IntersectionPoint;
if ~strcmp(hand.Type,'axes')
    hist_parent = hand.Parent;
    hist_ax_children = allchild(hist_parent);
else
    hist_ax_children = allchild(hand);
end

line_01 = findobj(hist_ax_children,'type','line','marker','>');
line_02 = findobj(hist_ax_children,'type','line','marker','<');
the_histogram = findobj(hist_ax_children,'type','histogram');

% both lines identified, pull xdata
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

% get all valid locations for selected line to traverse
bin_edges = the_histogram.BinEdges;
other_line_marker = other_line.Marker;
if strcmp(other_line_marker,'>')
    %other_line is lower bound
    bin_edges(bin_edges <=other_line.XData(1,1)) = [];
end
if strcmp(other_line_marker,'<')
    %other line is upper bound
    bin_edges(bin_edges>=other_line.XData(1,1)) = [];
end

% call figure motion callback w/ selected line handle
set(APP.MAIN,'WindowButtonMotionFcn',{@sig_dist_drag,APP,selected_line,bin_edges});
set(APP.MAIN,'WindowButtonUpFcn',{@sig_dist_release,APP,selected_line,bin_edges});

%
%%%
%%%%%
%%%
%

function [] = sig_dist_drag(hand, evt, APP, line_handle, accepted_bins)
%% <placeholder>
%

mouse_pointer = evt.IntersectionPoint;
mouse_x = mouse_pointer(1,1);

if mouse_x < max(accepted_bins) && mouse_x > min(accepted_bins)
    line_handle.XData = [mouse_x mouse_x];
end

%
%%%
%%%%%
%%%
%

function [] = sig_dist_release(hand, evt, APP, line_handle, accepted_bins)
%% <placeholder>
%

mouse_pointer = evt.IntersectionPoint;
mouse_x = mouse_pointer(1,1);

% find nearest mouse_pointer among acceptable bins
[k,~] = dsearchn(accepted_bins',mouse_x);
line_handle.XData = [accepted_bins(k) accepted_bins(k)];

% set appropriate elements in the signal processing panel
if strcmp(line_handle.Marker,'>')
    APP.hist_ax_min_box.String = num2str(accepted_bins(k));
else
    APP.hist_ax_max_box.String = num2str(accepted_bins(k));
end

% reset figure motion fxns
set(APP.MAIN,'WindowButtonMotionFcn','');
set(APP.MAIN,'WindowButtonUpFcn','');

centroid_overlay2(APP, 3);

%
%%%
%%%%%
%%%
%

function [] = hist_box_callback(hand, evt, APP)
%% <placeholder>
%

new_num = str2num(hand.String);

switch hand.Tag
    case 'HISTMAX'
        some_line = findobj(allchild(APP.hist_ax),'marker','<');
        other_line = findobj(allchild(APP.hist_ax),'marker','>');
        if isnumeric(new_num)
            % check if it's w/in axis limits
            if new_num <= APP.hist_ax.XLim(2) && new_num > other_line.XData(1)
                some_line.XData = new_num;
                centroid_overlay2(APP, 3);
            else
                hand.String = num2str(some_line.XData);
            end
        else
            hand.String = num2str(some_line.XData);
        end
    case 'HISTMIN'
        some_line = findobj(allchild(APP.hist_ax),'marker','>');
        other_line = findobj(allchild(APP.hist_ax),'marker','<');
        if isnumeric(new_num)
            % check if it's w/in axis limits
            if new_num >= APP.hist_ax.XLim(1) && new_num > other_line.XData(1)
                some_line.XData = new_num;
                centroid_overlay2(APP,3);
            else
                hand.String = num2str(some_line.XData);
            end
        else
            hand.String = num2str(some_line.XData);
        end
end

%
%%%
%%%%%
%%%
%

function [] = hist_quick_call(hand, evt, APP)

signal_search_toolbox = getappdata(APP.MAIN,'signal_search_toolbox');
tmp_entry = signal_search_toolbox{6};

maxbox = findobj(allchild(APP.MAIN),'tag','HISTMAX');
max_val = str2num(maxbox.String);
minbox = findobj(allchild(APP.MAIN),'tag','HISTMIN');
min_val = str2num(minbox.String);

% double check which label for the hand
tmp_string = hand.String;

switch tmp_string
    case 'Intensity'
        
        % set size as-is
        tmp_entry(:,2) = [min_val; max_val];
        
    case 'Size'
        
        % set intensity as-is
        tmp_entry(:,1) = [min_val; max_val];
end

signal_search_toolbox{6} = tmp_entry;
setappdata(APP.MAIN,'signal_search_toolbox',signal_search_toolbox);

signal_histogram_call2(APP);