function [] = inspector_change_scatter(hand,evt,INSPECT)
%% <placeholder>
%  

spotInfo = getappdata(INSPECT.figure_handle,'spotInfo');


% incl_excl = inspector_incl_excl(INSPECT);
incl_excl = logical(ones(size(spotInfo.objCoords,1),1));

axis_children = allchild(INSPECT.signal_axis);
prev_click = findobj(axis_children,'tag','user_tagged');
prev_xy = [];

if ~isempty(prev_click)
    prev_xy = [prev_click.XData prev_click.YData];
    delete(prev_click);
end

co = getappdata(INSPECT.figure_handle,'color_matrix');

cla(INSPECT.signal_axis);
INSPECT.signal_axis.NextPlot = 'add';

curr_im_tag = INSPECT.rb_image_group.SelectedObject.Tag;
switch curr_im_tag
    case 'MIP'
        tmp_centroids = spotInfo.objCoords;
        scatter(INSPECT.signal_axis,tmp_centroids(incl_excl,1),tmp_centroids(incl_excl,2),...
            [],co(1,:),'buttondownfcn',{@inspector_image_clicked,INSPECT});
        scatter(INSPECT.signal_axis,tmp_centroids(~incl_excl,1),tmp_centroids(~incl_excl,2),...
            [],'red','buttondownfcn',{@inspector_image_clicked,INSPECT});
    case 'SLICE'
        spotLocs2d = spotInfo.spotLocs2d;
        curr_z_slice = INSPECT.z_slice_slider.Value;
        
        tmp_incl = find(incl_excl);
        tmp_excl = find(~incl_excl);
        
        incl_centroids = spotLocs2d(ismember(spotLocs2d(:,4),tmp_incl),:);
        incl_slice_centroids = incl_centroids(incl_centroids(:,3)==curr_z_slice,:);
        scatter(INSPECT.signal_axis,incl_slice_centroids(:,1),incl_slice_centroids(:,2),[],co(1,:),'buttondownfcn',{@inspector_image_clicked,INSPECT});
        
        excl_centroids = spotLocs2d(ismember(spotLocs2d(:,4),tmp_excl),:);
        excl_slice_centroids = excl_centroids(excl_centroids(:,3)==curr_z_slice,:);
        scatter(INSPECT.signal_axis,excl_slice_centroids(:,1),excl_slice_centroids(:,2),[],'red','buttondownfcn',{@inspector_image_clicked,INSPECT});
end

if ~isempty(prev_xy)
    scatter(INSPECT.signal_axis,prev_xy(1,1),prev_xy(1,2),75,'yellow',...
        'LineWidth',1.25,'tag','user_tagged','buttondownfcn',{@inspector_image_clicked,INSPECT});
end

%{
scatter(INSPECT.signal_axis,tmp_centroids(incl_excl,1),tmp_centroids(incl_excl,2),...
    [],co(1,:));
scatter(INSPECT.signal_axis,tmp_centroids(~incl_excl,1),tmp_centroids(~incl_excl,2),...
    [],'red');
if ~isempty(prev_xy)
    scatter(INSPECT.signal_axis,prev_xy(1,1),prev_xy(1,2),75,'yellow',...
        'LineWidth',1.25,'tag','user_tagged');
end
%}


%{
spotInfo = getappdata(INSPECT.figure_handle,'spotInfo');
tmp_centroids = spotInfo.objCoords;

histogram_data = getappdata(INSPECT.figure_handle,'hist_data');
selection_legend = getappdata(INSPECT.figure_handle,'selection_legend');

hist_ax_children = allchild(INSPECT.hist_ax);
the_histogram = [];
the_line = [];

for idx=1:size(hist_ax_children,1)
	child_type = hist_ax_children(idx).Type;
	if strcmp(child_type,'histogram') == 1
		the_histogram = hist_ax_children(idx);
	end
	if strcmp(child_type,'line') == 1
		the_line = hist_ax_children(idx);
	end
end

line_location = the_line.XData(1,1);
hist_tag = the_histogram.Tag;   % if empty, no user selection

axis_children = allchild(INSPECT.signal_axis);
prev_click = findobj(axis_children,'tag','user_tagged');
prev_xy = [];
if ~isempty(prev_click)
    prev_xy = [prev_click.XData prev_click.YData];
end

cla(INSPECT.signal_axis);
color_matrix = getappdata(INSPECT.figure_handle,'color_matrix');

if ~isempty(selection_legend)
    % TODO - NEED TO FOCUS ON HISTOGRAM REWORKING
else
    
    % no sub selection, just need to consider base histogram values and the
    % line
    
    hist_logic_arr = histogram_data >= line_location;
    included_signals = tmp_centroids(hist_logic_arr,:);
    excluded_signals = tmp_centroids(~hist_logic_arr,:);
    
    scatter(INSPECT.signal_axis,included_signals(:,1),included_signals(:,2),[],color_matrix(1,:));
    scatter(INSPECT.signal_axis,excluded_signals(:,1),excluded_signals(:,2),'red');

end
%
if ~isempty(prev_xy)
    % keep it
    scatter(INSPECT.signal_axis,prev_xy(1,1),prev_xy(1,2),75,'yellow','LineWidth',1.25,'tag','user_tagged');
end
%}

%
%%%
%%%%%
%%%
%