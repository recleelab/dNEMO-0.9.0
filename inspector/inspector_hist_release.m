function [] = inspector_hist_release(hand,evt,INSPECT,line_handle,accepted_bins)
%% <placeholder>
%

mouse_pointer = evt.IntersectionPoint;
mouse_x = mouse_pointer(1,1);

% find nearest mouse_pointer among acceptable bins
[k,~] = dsearchn(accepted_bins',mouse_x);
line_handle.XData = [accepted_bins(k) accepted_bins(k)];

% set appropriate elements in the signal processing panel
if strcmp(INSPECT.min_intensity_label.Enable,'on')
    %dealing with intensity
    if strcmp(line_handle.Marker,'>')
        INSPECT.min_intensity_box.String = num2str(accepted_bins(k));
    else
        INSPECT.max_intensity_box.String = num2str(accepted_bins(k));
    end
else
    %dealing with size
    if strcmp(line_handle.Marker,'>')
        INSPECT.min_size_box.String = num2str(accepted_bins(k));
    else
        INSPECT.max_size_box.String = num2str(accepted_bins(k));
    end
end

% reset figure motion fxns
pix_ax_children = allchild(INSPECT.pixels_axis);
if ~isempty(pix_ax_children)
    set(INSPECT.figure_handle,'WindowButtonMotionFcn',{@inspector_mouse_drag,INSPECT});
else
    set(INSPECT.figure_handle,'WindowButtonMotionFcn','');
end
set(INSPECT.figure_handle,'WindowButtonUpFcn','');

% change scatter
inspector_change_scatter(hand,evt,INSPECT);

%
%%%
%%%%%
%%%
%