function [] = inspector_hist_drag(hand,evt,INSPECT,line_handle,accepted_bins)
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