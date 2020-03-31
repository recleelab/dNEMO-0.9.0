function [] = set_image_channel(hand, evt, APP)
%% menu callback function for swapping current display image channel
%
%  sets image channel based on handle properties from menu objected
%  selected by the user. channel menu objects generated when image is
%  loaded into dNEMO, with C channel menu selections made to represent C
%  image channels for the current image.
% 
%  INPUT:
%  . hand -- menu object user clicked to initiate function
%  . evt -- evt object passed with any callback function
%  . APP -- application structure
%
%  OUTPUT:
%  . None

main_channel_menu = findobj(allchild(APP.MAIN),'type','uimenu','label','Set Image Channel');
prev_checked_menu = findobj(allchild(main_channel_menu),'checked','on');
prev_checked_menu.Checked = 'off';

curr_label = hand.Label;
new_menu = findobj(allchild(APP.MAIN),'type','uimenu','label',curr_label);
new_menu.Checked = 'on';

new_channel = str2num(curr_label(end));

IMG = getappdata(APP.MAIN,'IMG');
IMG.CurrChannel = new_channel;
IMG.CurrFrameNo = 0;
setappdata(APP.MAIN,'IMG',IMG);

display_call(hand, evt, APP);

%
%%%
%%%%%
%%%
%