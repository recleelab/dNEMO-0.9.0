function [] = inspector_self_select(hand, evt, APP)
%% <placeholder>
%

if strcmp(hand.Tag,'user_tagged')
    return;
end

parent_ax = hand.Parent;
prev_click = findobj(allchild(parent_ax),'tag','user_tagged');
if ~isempty(prev_click)
    delete(prev_click);
end

pt_clicked = get(parent_ax,'currentpoint');

scatter_coords = [hand.XData.' hand.YData.'];
user_pt = pt_clicked(1,1:2);

% search for closest point against currently scattered objects
[tmp_ind,~] = dsearchn(scatter_coords, user_pt);
closest_pt = scatter_coords(tmp_ind,:);

% display closest point
hold on
scatter(parent_ax,closest_pt(1,1),closest_pt(1,2),100,'yellow',...
    'LineWidth',1.25,'tag','selected_point',...
    'UIContextMenu',inspector_menu,'ButtonDownFcn',{@inspector_image_clicked,APP});
hold off



%
%%%
%%%%%
%%%
%