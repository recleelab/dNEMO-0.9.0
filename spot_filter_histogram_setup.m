function [] = spot_filter_histogram_setup(APP)
%% <placeholder>
%

co = getappdata(APP.MAIN,'color_matrix');

hist_ax_children = allchild(APP.hist_ax);
if isempty(hist_ax_children)
    
    % startup
    APP.hist_ax_min_box.Enable = 'on';
    APP.hist_ax_max_box.Enable = 'on';
    APP.feature_select_dropdown.Enable = 'on';
    
    % populate feature dropdown
    curr_overlay = getappdata(APP.MAIN,'OVERLAY');
    fields = curr_overlay.spotFeatureNames;
    APP.feature_select_dropdown.String = fields;
    
    % create distribution
    curr_feat_pointer = APP.feature_select_dropdown.Value;
    data_arr = curr_overlay.spotFeatures(:,curr_feat_pointer);
    
    hist_hand = histogram(APP.hist_ax, data_arr,'facecolor',co(1,:));
    hist_edges = hist_hand.BinEdges;
    
    prev_min = curr_overlay.spotFeatureMin;
    if ~isnan(prev_min(curr_feat_pointer))
        start_x = prev_min(curr_feat_pointer);
    else
        start_x = 0;
        curr_overlay.spotFeatureMin(curr_feat_pointer) = start_x;
    end
    % start_x = prev_min(curr_feat_pointer);
    
    prev_max = curr_overlay.spotFeatureMax;
    if ~isnan(prev_max(curr_feat_pointer))
        end_x = prev_max(curr_feat_pointer);
    else
        end_x = hist_edges(end);
        curr_overlay.spotFeatureMax(curr_feat_pointer) = end_x;
    end
    
    setappdata(APP.MAIN,'OVERLAY',curr_overlay);
    
    % start_x = hist_edges(1);
    % end_x = hist_edges(end);
    
    line_01 = line(APP.hist_ax, [start_x start_x], APP.hist_ax.YLim,...
        'color', 'red','linestyle','--','marker','>');
    line_02 = line(APP.hist_ax, [end_x end_x], APP.hist_ax.YLim,... 
        'color', 'green','linestyle','--','marker','<');
    
    APP.hist_ax.ButtonDownFcn = {@distribution_clicked, APP};
    hist_hand.ButtonDownFcn = {@distribution_clicked, APP};
    set([line_01 line_02],'ButtonDownFcn',{@distribution_clicked, APP});
    
    APP.hist_ax.HitTest = 'on';
    APP.hist_ax.PickableParts = 'visible';

    APP.hist_ax.XLimMode = 'auto';
    APP.hist_ax.YLimMode = 'auto';
    APP.hist_ax.XTickMode = 'auto';
    APP.hist_ax.YTickMode = 'auto';
    APP.hist_ax.YLabel.String = 'spot count';
    
    APP.hist_ax_min_box.String = num2str(start_x);
    APP.hist_ax_min_box.Callback = {@hist_box_callback, APP};
    APP.hist_ax_max_box.String = num2str(end_x);
    APP.hist_ax_max_box.Callback = {@hist_box_callback, APP};
    
    APP.feature_select_dropdown.Callback = {@feature_switch, APP};
    
else
    % just get current details, reassign callbacks as appropriate
    feature_switch(APP.feature_select_dropdown, 1, APP);
end

%
%%%
%%%%%
%%%
%

function [] = distribution_clicked(hand, evt, APP)
%% callback for histogram axis, histogram axis children
% 

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

curr_overlay = getappdata(APP.MAIN,'OVERLAY');
curr_feat_pointer = curr_overlay.spotFeaturePointer;

mouse_pointer = evt.IntersectionPoint;
mouse_x = mouse_pointer(1,1);

% find nearest mouse_pointer among acceptable bins
[k,~] = dsearchn(accepted_bins',mouse_x);
line_handle.XData = [accepted_bins(k) accepted_bins(k)];

% set appropriate elements in the signal processing panel
if strcmp(line_handle.Marker,'>')
    APP.hist_ax_min_box.String = num2str(accepted_bins(k));
    curr_overlay.spotFeatureMin(curr_feat_pointer) = str2num(APP.hist_ax_min_box.String);
else
    APP.hist_ax_max_box.String = num2str(accepted_bins(k));
    curr_overlay.spotFeatureMax(curr_feat_pointer) = str2num(APP.hist_ax_max_box.String);
end

% reset figure motion fxns
set(APP.MAIN,'WindowButtonMotionFcn','');
set(APP.MAIN,'WindowButtonUpFcn','');

setappdata(APP.MAIN,'OVERLAY',curr_overlay);

% DISPLAY CALL
display_call(APP.hist_ax, 1, APP);

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
                some_line.XData = [new_num new_num];
                
                % pull current overlay
                curr_overlay = getappdata(APP.MAIN,'OVERLAY');
                curr_feat_pointer = curr_overlay.spotFeaturePointer;
                curr_overlay.spotFeatureMax(curr_feat_pointer) = new_num;
                setappdata(APP.MAIN,'OVERLAY',curr_overlay);
                
                % display call
                display_call(hand, 1, APP);
                
            else
                hand.String = num2str(some_line.XData(1));
            end
        else
            hand.String = num2str(some_line.XData(1));
        end
    case 'HISTMIN'
        some_line = findobj(allchild(APP.hist_ax),'marker','>');
        other_line = findobj(allchild(APP.hist_ax),'marker','<');
        if isnumeric(new_num)
            % check if it's w/in axis limits
            if new_num >= APP.hist_ax.XLim(1) && new_num < other_line.XData(1)
                some_line.XData = [new_num new_num];
                
                % pull current overlay
                curr_overlay = getappdata(APP.MAIN,'OVERLAY');
                curr_feat_pointer = curr_overlay.spotFeaturePointer;
                curr_overlay.spotFeatureMin(curr_feat_pointer) = new_num;
                setappdata(APP.MAIN,'OVERLAY',curr_overlay);
                
                % DISPLAY CALL
                display_call(hand, 1, APP);
                
            else
                hand.String = num2str(some_line.XData(1));
            end
        else
            hand.String = num2str(some_line.XData(1));
        end
end

%
%%%
%%%%%
%%%
%

function [] = feature_switch(hand, evt, APP)
%% <placeholder>
%

co = getappdata(APP.MAIN,'color_matrix');

curr_overlay = getappdata(APP.MAIN,'OVERLAY');

curr_feat_pointer = hand.Value;
data_arr = curr_overlay.spotFeatures(:,curr_feat_pointer);
curr_overlay.spotFeaturePointer = curr_feat_pointer;

hist_ax_children = findobj(allchild(APP.hist_ax));
line_01 = findobj(hist_ax_children,'type','line','marker','>');
line_02 = findobj(hist_ax_children,'type','line','marker','<');
the_histogram = findobj(hist_ax_children,'type','histogram');

delete(the_histogram);
APP.hist_ax.NextPlot = 'add';

hist_hand = histogram(APP.hist_ax, data_arr,'facecolor',co(1,:));
hist_edges = hist_hand.BinEdges;

prev_min = curr_overlay.spotFeatureMin;
if ~isnan(prev_min(curr_feat_pointer))
    start_x = prev_min(curr_feat_pointer);
else
    start_x = 0;
    curr_overlay.spotFeatureMin(curr_feat_pointer) = start_x;
end
% start_x = prev_min(curr_feat_pointer);

prev_max = curr_overlay.spotFeatureMax;
if ~isnan(prev_max(curr_feat_pointer))
    end_x = prev_max(curr_feat_pointer);
else
    end_x = hist_edges(end);
    curr_overlay.spotFeatureMax(curr_feat_pointer) = end_x;
end

% start_x = hist_edges(1);
% end_x = hist_edges(end);

line_01.XData = [start_x start_x];
line_02.XData = [end_x end_x];

hist_hand.ButtonDownFcn = {@distribution_clicked, APP};

APP.hist_ax.XLimMode = 'auto';
APP.hist_ax.YLimMode = 'auto';
APP.hist_ax.XTickMode = 'auto';
APP.hist_ax.YTickMode = 'auto';
APP.hist_ax.YLabel.String = 'spot count';

line_01.YData = APP.hist_ax.YLim;
line_02.YData = APP.hist_ax.YLim;

APP.hist_ax_min_box.String = num2str(start_x);
APP.hist_ax_max_box.String = num2str(end_x);

setappdata(APP.MAIN,'OVERLAY',curr_overlay);

% display_call(APP.feature_select_dropdown, 1, APP);
display_call(APP.hist_ax, 1, APP);

%
%%%
%%%%%
%%%
%