function [] = menu_display_3d_select(varargin)
%%
% function meant to handle swapping the different 3D displays
%
[hand,APP] = varargin{[1,3]};
some_label = hand.Label;
parent_menu = get(hand,'parent');
parent_label = parent_menu.Label;
all_children = get(parent_menu,'children');
for i=1:length(all_children)
	if all_children(i) == hand
		all_children(i).Checked = 'on';
	else
		all_children(i).Checked = 'off';
	end
end
display_call(APP.z_slice_slider,1,APP);
%{
film_slider_state = get(APP.film_slider,'enable');
is_film_present = strcmp(film_slider_state,'on');
if is_film_present == 0
	return;
end


switch some_label
	
	case 'Basic MIP'
		hand.Checked = 'on';
		set(APP.display_menu.display_menu_02,'checked','off');
		set(APP.display_menu.display_menu_03,'checked','off');
	
	case 'Icy MIP'
		set(hand,'checked','on');
		set(APP.display_menu.display_menu_01,'checked','off');
		set(APP.display_menu.display_menu_03,'checked','off');
	
	case 'Full 3D Image'
		set(hand,'checked','on');
		set(APP.display_menu.display_menu_01,'checked','off');
		set(APP.display_menu.display_menu_02,'checked','off');
	
	case APP.film_slider
		% todo
end
%}