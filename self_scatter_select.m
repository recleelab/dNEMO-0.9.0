function [] = self_scatter_select(hand, evt, APP)
%% <placeholder>
%

[process,~,~] = display_check(APP);
if process~=3 && process~=2

    if strcmp(hand.Tag,'selected_point')
        return;
    end

    parent_ax = hand.Parent;
    prev_click = findobj(allchild(parent_ax),'tag','selected_point');
    if ~isempty(prev_click)
        delete(prev_click);
    end

    pt_clicked = get(parent_ax,'currentpoint');

    scatter_coords = [hand.XData.' hand.YData.'];
    user_pt = pt_clicked(1,1:2);

    % search for closest point against currently scattered objects
    [tmp_ind,~] = dsearchn(scatter_coords, user_pt);
    closest_pt = scatter_coords(tmp_ind,:);
    
    % temporary
    assignin('base','tmp_point',closest_pt);

    % create new uicontextmenu
    inspector_menu = uicontextmenu();
    inspect_image = uimenu('Parent',inspector_menu,'Label','Open Inspector',...
                            'callback',{@inspector_call,APP});
    set(APP.ax2,'UIContextMenu',inspector_menu);

    % display closest point
    hold on
    scatter(APP.ax2,closest_pt(1,1),closest_pt(1,2),100,'yellow',...
        'LineWidth',1.25,'tag','selected_point',...
        'UIContextMenu',inspector_menu,'ButtonDownFcn',{@self_scatter_select,APP});
    hold off
    
    APP.ax2.PickableParts = 'visible';
    APP.ax2.HitTest = 'on';
end

if process==3
    % exclusion happening, different self-selection required
end

%
%%%
%%%%%
%%%
%