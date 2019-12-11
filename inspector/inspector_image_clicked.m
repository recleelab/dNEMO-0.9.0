function [] = inspector_image_clicked(hand,evt,INSPECT)
%% <placeholder>
%  

switch hand.Type
    case 'axes'
        disp('axes clicked');
    case 'scatter'
        disp('scatter clicked');
        tmp_parent = hand.Parent;
        hand = tmp_parent;
end

pt_clicked = evt.IntersectionPoint;
hand_children = allchild(hand);
prev_click = findobj(hand_children,'tag','user_tagged');
if ~isempty(prev_click)
    delete(findobj(hand_children,'tag','user_tagged'));
end

spotInfo = getappdata(INSPECT.figure_handle,'spotInfo');
tmp_centroids = spotInfo.objCoords;
user_pt = pt_clicked(1,1:2);
[true_ind,~] = dsearchn(tmp_centroids(:,1:2),user_pt);
scatter(hand,tmp_centroids(true_ind,1),tmp_centroids(true_ind,2),...
    75,'yellow','LineWidth',1.25,'tag','user_tagged');

% inspector display call
inspector_pixel_information_display(INSPECT,spotInfo,true_ind);
    
% tagging invisible axis w/ spotInfo_coord
invis_tag = num2str(true_ind);
INSPECT.invisible_axis.Tag = invis_tag;

%{
% what remains should be the scattered points
if ~isempty(hand_children)
    scatter_x = [];
    scatter_y = [];
    for tmp_idx=1:size(hand_children,1)
        tmp_x = hand_children(tmp_idx).XData;
        tmp_y = hand_children(tmp_idx).YData;
        if ~isempty(tmp_x) && ~isempty(tmp_y)
            scatter_x = cat(1,scatter_x,tmp_x');
            scatter_y = cat(1,scatter_y,tmp_y');
        end
    end
    scatter_coords = [scatter_x scatter_y];
    user_pt = pt_clicked(1,1:2);
    
    % search for closest point against currently scattered objects
	[tmp_ind,~] = dsearchn(scatter_coords,user_pt);
	closest_pt = scatter_coords(tmp_ind,:);
    
    % display closest point
    scatter(hand,closest_pt(1,1),closest_pt(1,2),75,'yellow','LineWidth',1.25,'tag','user_tagged');
    
    % find actual index within full set of objects (not just whatever is
    % scattered on INSPECT.signal_axis
    spotInfo = getappdata(INSPECT.figure_handle,'spotInfo');
    actual_centroids = spotInfo.objCoords;
    [true_ind,~] = dsearchn(actual_centroids(:,1:2),closest_pt);
    
    % inspector display call
    inspector_pixel_information_display(INSPECT,spotInfo,true_ind);
    
    % tagging invisible axis w/ spotInfo_coord
    invis_tag = num2str(true_ind);
    INSPECT.invisible_axis.Tag = invis_tag;
    
end
%}

%
%%%
%%%%%
%%%
%