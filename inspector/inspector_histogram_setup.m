function [] = inspector_histogram_setup(INSPECT,image,spotInfo)
%% <placeholder>
%  

centroids = spotInfo.objCoords;
histogram_data = zeros(size(centroids,1),1);

signal_values = spotInfo.SIG_VALS;
% [BG_VALS,~] = assign_bg_pixels(image,spotInfo,1,1);
BG_VALS = getappdata(INSPECT.figure_handle,'curr_bg_vals');

% run basic operation
for idx=1:size(histogram_data,1)
    histogram_data(idx,1) = mean(signal_values{idx,2} - mean(BG_VALS{idx,2}));
end

curr_hist = histogram(INSPECT.hist_ax,histogram_data);
% line(INSPECT.hist_ax,[0 0],INSPECT.hist_ax.YLim,'Color','red','linestyle','--');

% assign values back to INSPECT
setappdata(INSPECT.figure_handle,'curr_hist',curr_hist);
setappdata(INSPECT.figure_handle,'hist_data',histogram_data);
setappdata(INSPECT.figure_handle,'selection_legend',[]);

% set up greater than / less than lines
hist_bin_edges = curr_hist.BinEdges;
lower_bound = hist_bin_edges(1);
upper_bound = hist_bin_edges(length(hist_bin_edges));

line(INSPECT.hist_ax,[lower_bound lower_bound],INSPECT.hist_ax.YLim,...
    'color','red','linestyle','--','marker','>');
line(INSPECT.hist_ax,[upper_bound upper_bound],INSPECT.hist_ax.YLim,...
    'color','green','linestyle','--','marker','<');

% set edit boxes w/ values
INSPECT.min_intensity_box.String = num2str(lower_bound);
INSPECT.max_intensity_box.String = num2str(upper_bound);

% get size info quickly, to populate for histogram checkup
size_info = cellfun('length',signal_values(:,2));
assignin('base','size_info',size_info);
setappdata(INSPECT.figure_handle,'size_info',size_info);
INSPECT.min_size_box.String = num2str(min(size_info));
INSPECT.max_size_box.String = num2str(max(size_info));
        

% additional histogram callback setup
histogram_axis_children = allchild(INSPECT.hist_ax);
for idx=1:size(histogram_axis_children,1)
    histogram_axis_children(idx).ButtonDownFcn = {@inspector_hist_click,INSPECT};
end
% need axis too
INSPECT.hist_ax.ButtonDownFcn = {@inspector_hist_click,INSPECT};

% finally, call scatter based on histogram data
inspector_change_scatter(INSPECT.hist_ax,1,INSPECT);

%
%%%
%%%%%
%%%
%