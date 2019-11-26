function [] = view_keyframes(hand,evt,APP)
%% fxn for handling changing views of current keyframe details and
%  all keyframe information

clicked_tag = hand.Tag;
clicked_type = hand.Type; % either panel, text, or axis, right?
assignin('base','clicked_type',clicked_type);

disp('viewing keyframes');

switch clicked_tag
    case 'curr'
        % clicking on current details, so swap it
        APP.curr_keyframe_details.Enable = 'on';
        APP.curr_keyframe_details_pan.BorderWidth = 2;
        APP.all_keyframe_details.Enable = 'off';
        APP.all_keyframe_details_pan.BorderWidth = 1;
        
        % want keyframe details editbox visible, keyframe map invisible
        APP.keyframe_information_box.Visible = 'on';
        APP.keyframe_map.Visible = 'off';
        
        % grab tag from APP.keyframe_map
        curr_tag = APP.keyframe_map.Tag;
        frame_no = APP.film_slider.Value;
        
        if ~isempty(curr_tag)
        	KEYFRAMES = getappdata(APP.MAIN,'KEYFRAMES');
        	kf_ref_arr = getappdata(APP.MAIN,'keyframe_ref_array');
        	kf_no = str2num(curr_tag);
    		if kf_no < 1
    			% grab top of kf_ref_arr
    			kf_no = max(kf_ref_arr(:,frame_no));
    		end
    		if kf_no > 0
    			% produce string array to pass into display component
    			curr_keyframe = KEYFRAMES{kf_no};
    			kf_str_arr = curr_keyframe.Description;
    			APP.keyframe_information_box.String = kf_str_arr;
    		end
    	end
        
        % main figure motion listener
        APP.MAIN.WindowButtonMotionFcn = '';
        
    case 'all'
        APP.all_keyframe_details.Enable = 'on';
        APP.all_keyframe_details_pan.BorderWidth = 2;
        APP.curr_keyframe_details.Enable = 'off';
        APP.curr_keyframe_details_pan.BorderWidth = 1;
        
        % want keyframe map visible, keyframe details editbox invisible
        APP.keyframe_information_box.Visible = 'off';
        APP.keyframe_map.Visible = 'on';
        
        % enable figure method based tracker
        %{
        if ~isempty(allchild(APP.keyframe_map))
        	APP.MAIN.WindowButtonMotionFcn = {@keyframe_map_hover_call,APP};
        end
        %}
end

if strcmp(clicked_type,'axes')
	
	if isempty(allchild(APP.keyframe_map))
		APP.keyframe_map.Tag = '';
	else
		% assign new tag based on click
		pt_clicked = evt.IntersectionPoint;
		y_coord = round(pt_clicked(1,2));
		APP.keyframe_map.Tag = num2str(y_coord);
		
		% look at children from keyframe_map
		ax_children = allchild(APP.keyframe_map);
		assignin('base','tmp_ax_children',ax_children);
		for i=1:length(ax_children)
			curr_child = ax_children(i);
			tmp_ydata = curr_child.YData;
			assignin('base','tmp_ydata',tmp_ydata);
			if tmp_ydata(1) == y_coord
				if strcmp(curr_child.Type,'line')
					curr_child.LineWidth = 2.5;
				end
				if strcmp(curr_child.Type,'scatter')
					curr_child.SizeData = 15;
				end
			else
				if strcmp(curr_child.Type,'line')
					curr_child.LineWidth = 1.25;
				end
				if strcmp(curr_child.Type,'scatter')
					curr_child.SizeData = 10;
				end
			end
		end
		disp('keyframe map click completely registered');
		display_trajectory_ax(APP);
		disp('done w/ trajectory display');
		axis_color = APP.ax2.Color;
		assignin('base','color_before_all_display_call_components',axis_color);
		display_call(hand,evt,APP);
	end

end

if ~strcmp(clicked_type, 'uipanel') && strcmp(hand.Style,'popupmenu')
    
    disp('made it to callback');
    
    % check that there are keyframes
    KEYFRAMES = getappdata(APP.MAIN,'KEYFRAMES');
    if isempty(KEYFRAMES) || ~isstruct(KEYFRAMES{1})
		return;
    end
	
    % get current movie frame number
    frame_no = APP.film_slider.Value;
    
	% get the value of the pop menu
    curr_pop_val = hand.Value;
    
    if curr_pop_val == 1
        
        % pull the keyframe reference array, assign current keyframe to the Tag field
        % of APP.keyframe_map
        kf_ref_arr = getappdata(APP.MAIN,'keyframe_ref_array');
        top_kf = max(kf_ref_arr(:,frame_no));
        APP.keyframe_map.Tag = num2str(top_kf);
        
        APP.modify_keyframe_button.Enable = 'off';
        APP.del_keyframe_button.Enable = 'off';
        
    else
        APP.keyframe_map.Tag = num2str(curr_pop_val-1);
        
        % modification and deletion of keyframes should be made available
        APP.modify_keyframe_button.Enable = 'on';
        APP.del_keyframe_button.Enable = 'on';
    end
	
	
end

%
%%%
%%%%%
%%%
%

function [] = keyframe_map_hover_call(hand,evt,APP)
%% fxn meant to handle window motion over APP.keyframe_map
%  

% trying again -- 
screen = get(0,'screensize');
figure_pos = APP.MAIN.Position;
panel_pos = APP.cell_creation_panel.Position;
axis_pos = APP.keyframe_map.Position;

true_map_x = (panel_pos(1,1)*figure_pos(1,3)*screen(1,3))+(axis_pos(1,1)*panel_pos(1,3)*figure_pos(1,3)*screen(1,3));
true_map_y = (panel_pos(1,2)*figure_pos(1,4)*screen(1,4))+(axis_pos(1,2)*panel_pos(1,4)*figure_pos(1,4)*screen(1,4));
true_map_width = axis_pos(1,3)*panel_pos(1,3)*figure_pos(1,3)*screen(1,3);
true_map_height = axis_pos(1,4)*panel_pos(1,4)*figure_pos(1,4)*screen(1,4);

accepted_region = zeros(4,2);
accepted_region(1,:) = [true_map_x,true_map_y];
accepted_region(2,:) = [true_map_x,true_map_y+true_map_height];
accepted_region(3,:) = [true_map_x+true_map_width,true_map_y+true_map_height];
accepted_region(4,:) = [true_map_x+true_map_width,true_map_y];
assignin('base','cc_accepted_region',accepted_region);

current_point = APP.MAIN.CurrentPoint;
assignin('base','cc_fig_point',current_point);
curr_x = current_point(1,1)*figure_pos(1,3)*screen(1,3);
curr_y = current_point(1,2)*figure_pos(1,4)*screen(1,4);

is_point_valid = inpolygon(curr_x,curr_y,accepted_region(:,1),accepted_region(:,2));

if is_point_valid
	% annotate appropriately
	curr_ax_point = APP.ax2.CurrentPoint;
	assignin('base','cc_ax_point',curr_ax_point);
	
	% test annotation, to get look and feel, and see if it can be removed 
	% in an appropriate manner	
	annotation_objects = allchild(findobj(allchild(APP.cell_creation_panel),'Type','annotation'));
	if isempty(annotation_objects)
		
		% TEMPORARY -- small annotation to accurately track the cursor?
		tmp_pos = APP.cell_creation_panel.Position;
		tmp_annotation = annotation(APP.cell_creation_panel,...
									'textbox',[current_point(1,1)*tmp_pos(1,1) current_point(1,2)*tmp_pos(1,2) 1 1],...
									'String','T',...
									'color','black',...
									'EdgeColor','black',...
									'BackgroundColor',[0.91 0.41 0.17],...
									'FontSize',10,...
									'FitBoxToText','on',...
									'visible','on');
	else
		annotation_objects.Position = [current_point(1,1) current_point(1,2) 0.005 0.005];
	end
else
	% remove the annotation, look for children of the panel of type annotation
	annotation_objects = allchild(findobj(allchild(APP.cell_creation_panel),'Type','annotation'));
	delete(annotation_objects);
end

%
%%%
%%%%%
%%%
%