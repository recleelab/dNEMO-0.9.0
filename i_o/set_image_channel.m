function [] = set_image_channel(hand, evt, APP)
%% <placeholder>
%

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