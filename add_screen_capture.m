function [] = add_screen_capture(figure_handle)
%% <placeholder>
%
%  given a figure handle, it adds a uicontextmenu option to the current 
%  figure that, so long as there's an axis where the mouse clicked, it 
%  can capture and export that axis as a PDF. helpful for screenshots!
% 
%  really we only need axes, anything worth capturing...
%  - trajectory axis
%  - main axis
%  - inspector (separate issue for the time being...
new_menu = uicontextmenu();
screencap = uimenu('parent',new_menu,'Label','Test');
figure_handle.UIContextMenu = new_menu;

% basically just adding a context menu w/ a dummy command for now.
% new_menu = uicontextmenu(figure_handle);
% screencap = uicontrol(figure_handle,'UIContextMenu',new_menu);
% actual_menu = uimenu('Parent',new_menu,'Label','Test');


%
%%%
%%%%%
%%%
%