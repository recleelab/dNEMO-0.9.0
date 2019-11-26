function [] = select_signal_axis_click(hand,evt,APP)
%% <placeholder> 
% 
%

% double check for currently scattered point
prev_click = findobj('tag','selected_point');
if ~isempty(prev_click)
	delete(prev_click);
end

% grab nearest pt + collection of scattered points
% from which to pull xy coordinates
pt_clicked = get(hand,'currentpoint');
scattered_set = findobj('parent',hand,'type','scatter');

if ~isempty(scattered_set)
    % iterate through 
    
    scatter_x = [];
    scatter_y = [];
    
    for ii=1:length(scattered_set)
    
        scatter_x = cat(1,scatter_x,scattered_set(ii).XData.');
        scatter_y = cat(1,scatter_y,scattered_set(ii).YData.');
    end
    
    scatter_coords = [scatter_x scatter_y];

    user_pt = pt_clicked(1,1:2);

    % search for closest point against currently scattered objects
    [tmp_ind,~] = dsearchn(scatter_coords,user_pt);
    closest_pt = scatter_coords(tmp_ind,:);

    inspector_menu = uicontextmenu();
    inspect_image = uimenu('Parent',inspector_menu,'Label','Open Inspector',...
                            'callback',{@inspector_call,APP});
    set(APP.ax2,'UIContextMenu',inspector_menu);

    % display closest point
    hold on;
    scatter(APP.ax2,closest_pt(1,1),closest_pt(1,2),100,'yellow',...
            'LineWidth',1.25,'tag','selected_point',...
            'UIContextMenu',inspector_menu,'ButtonDownFcn',{@self_scatter_select,APP});
    hold off;

    % set uicontextmenu whenever click is registered AND 
    % signals are present
	
end

%
%%%
%%%%%
%%%
%