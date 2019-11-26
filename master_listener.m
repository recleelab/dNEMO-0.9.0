function [] = master_listener(APP,string_arg,num_arg)
%% fxn for handling application components turning on/off when different functions are 
%  operating. largely used to keep main function clean of on/off problems.
%  
%  Note: some components, once turned off here, are turned back on when display_call.m
%        and display_listener.m are called, which relies on states of various storage
%        components to turn components on and off for basic user interactions
%  
%  Input:
%  		APP - the application
% 		string_arg - string argument correlating w/ major operation
%  		num_arg - case argument (opening, closing, modifying, deleting, etc.)
%

% raw_image_data
raw_image_data = getappdata(APP.MAIN,'raw_image_data');

switch string_arg
	
	
	%% keyframe
	%
	
	case 'keyframe'
		
		switch num_arg
			
			case 1
				% beginning keyframe creation
				disp('setting app up for keyframe creation');
				% object creation panel components
				set(APP.add_keyframe_button,'string','Cancel Keyframe Creation');
				set(APP.add_object_button,'enable','off');
				
				% spot filter panel components
				set(APP.current_threshold_label,'enable','on');
				set(APP.current_threshold_display,'enable','on');
				set(APP.current_threshold_slider,'enable','on');
				set(APP.create_keyframe_button,'enable','on');
				if size(raw_image_data,2) == 4
					set(APP.current_threshold_slider,'value',2.0);
					set(APP.current_threshold_display,'string','2');
					% HIST AX MANIPULATION HERE
                    set(APP.hist_ax_bg,'visible','on');
                    % set(APP.hist_ax_bg_intensity,'value',1);
				end
				set(APP.start_frame_label,'enable','on');
				set(APP.start_frame_input,'enable','on');
				set(APP.start_frame_input,'string',num2str(APP.film_slider.Min));
				set(APP.end_frame_label,'enable','on');
				set(APP.end_frame_input,'enable','on');
				set(APP.end_frame_input,'string',num2str(APP.film_slider.Max));
				
				% user display components
				set(APP.frame_signal_toggle,'enable','on','value',1)
				set(APP.cell_signal_toggle,'enable','off','value',0);
				set(APP.cell_boundary_toggle,'enable','off','value',0);
				set(APP.excluded_signal_toggle,'enable','off','value',0);
				
				% keyframe display 
				% view_keyframes(APP.curr_keyframe_details,1,APP);
				
				% other
				if size(raw_image_data,2) == 4
					set(APP.current_threshold_slider,'value',2.0);
					set(APP.current_threshold_display,'string','2');
				end
			
			case 2
				% ending keyframe creation
				disp('shutting down app for keyframe creation');
				% object creation panel components
				set(APP.add_keyframe_button,'string','Add Keyframe');
                set(APP.add_keyframe_button,'enable','on');
				set(APP.add_object_button,'enable','on');
				set(APP.keyframe_information_box,'string','');
				
				% spot filter panel components
				set(APP.current_threshold_label,'enable','off');
				set(APP.current_threshold_display,'enable','off','string','2');
				set(APP.current_threshold_slider,'enable','off','val',2);
				set(APP.create_keyframe_button,'enable','off');
				set(APP.start_frame_label,'enable','off');
				set(APP.start_frame_input,'enable','off','string','');
				set(APP.end_frame_label,'enable','off');
				set(APP.end_frame_input,'enable','off','string','');
				cla(APP.hist_ax);
				% set(APP.hist_ax_intensity_measure,'string','');
                
                APP.hist_ax.XTick = [];
                APP.hist_ax_min_box.Enable = 'off';
                APP.hist_ax_max_box.Enable = 'off';
                APP.hist_ax_bg_01.Enable = 'off';
                APP.hist_ax_bg_02.Enable = 'off';
				
                % modify handle case
                if strcmp(APP.modify_keyframe_button.String,'Finish Modifying Keyframe')
                    APP.modify_keyframe_button.String = 'Modify Keyframe';
                    APP.modify_keyframe_button.Enable = 'off';
                end
                
				% user display components
				set(APP.frame_signal_toggle,'enable','on');
			
			case 3
				% modifying existing keyframe
				
				% object creation panel components
				set(APP.add_keyframe_button,'enable','off');
				set(APP.del_keyframe_button,'enable','off');
				set(APP.add_object_button,'enable','off');
				set(APP.delete_object_button,'enable','off');
				set(APP.modify_cell_button,'enable','off');
				set(APP.modify_keyframe_button,'string','Finish Modifying Keyframe');
				
				% spot filter panel components
				set(APP.current_threshold_label,'enable','on');
				set(APP.current_threshold_display,'enable','on');
				set(APP.start_frame_label,'enable','on');
				set(APP.start_frame_input,'enable','on');
				set(APP.end_frame_label,'enable','on');
				set(APP.end_frame_input,'enable','on');
				
				% user display components
				set(APP.frame_signal_toggle,'enable','on','value',1);
				set(APP.cell_signal_toggle,'enable','off','value',0);
				set(APP.cell_boundary_toggle,'enable','off','value',0);
				set(APP.excluded_signal_toggle,'enable','off','value',0);
				
				% other
				
			case 4
				% deleting existing keyframe
			
		end
	
	
	%% cell
	%
	
	case 'cell'
		
		switch num_arg
			
			case 1
				% initializing cell drawing
				
				% turn off keyframe components
				set(APP.add_keyframe_button,'enable','off');
				set(APP.modify_keyframe_button,'enable','off');
				set(APP.del_keyframe_button,'enable','off');
				
				% confirm APP.ax2 is operational
				APP.ax2.HitTest = 'on';
				APP.ax2.PickableParts = 'visible';
				
				% turn off modify cell
				APP.modify_cell_button.Enable = 'off';
				
				% add, delete cell get new strings
				APP.add_object_button.String = 'Finish Drawing Cell';
				APP.add_object_button.Enable = 'off';
				APP.delete_object_button.String = 'Cancel Drawing Cell';
				APP.delete_object_button.Enable = 'off';
			
			case 2
				% finish initialization of drawing a cell
				
				% turning on add, delete buttons
				APP.add_object_button.Enable = 'on';
				APP.delete_object_button.Enable = 'on';
			
			case 3
				% finishing drawing a cell
				
				% turning back add, delete buttons
				APP.add_object_button.String = 'Draw Cell';
                APP.add_object_button.Enable = 'on';
				APP.modify_cell_button.String = 'Modify Cell';
				APP.delete_object_button.String = 'Delete Cell';
				APP.delete_object_button.Enable = 'off';
				
				% turning on add keyframe button
				APP.add_keyframe_button.Enable = 'on';
				
			
			case 4
				% beginning modification of an existing cell
				
				% turning off cell buttons
				APP.add_object_button.Enable = 'off';
				APP.delete_object_button.Enable = 'off';
				
				% turning off keyframe buttons
				APP.add_keyframe_button.Enable = 'off';
				APP.modify_keyframe_button.Enable = 'off';
				APP.del_keyframe_button.Enable = 'off';
				
				% swapping string on APP.modify_cell_button
				APP.modify_cell_button.String = 'Finish Modifying Cell';
		
		end
	
	
	%% exclude
	%
	
	case 'exclude'
	
		switch num_arg
			
			case 1
				% starting up, need to shut off certain components
				APP.ax2.PickableParts = 'all';
				
				% turning off cell drawing, selection components
				APP.add_object_button.Enable = 'off';
				APP.modify_cell_button.Enable = 'off';
				APP.delete_object_button.Enable = 'off';
				% APP.created_cell_selection.Value = 1;
				% APP.created_cell_selection.Enable = 'off';
				
				% turning on keyframe components
				APP.add_keyframe_button.Enable = 'off';
				APP.modify_keyframe_button.Enable = 'off';
				APP.del_keyframe_button.Enable = 'off';
			
			case 2
				% shutting down, need to turn certain components back on
				APP.ax2.PickableParts = 'visible';
				set(APP.ax2,'ButtonDownFcn','');
				set(APP.MAIN,'windowbuttonupfcn','');
				set(APP.MAIN,'windowbuttonmotionfcn','');
				
				% turning on cell drawing, selection components
				APP.add_object_button.Enable = 'on';
				APP.modify_cell_button.Enable = 'on';
				APP.delete_object_button.Enable = 'on';
				APP.created_cell_selection.Enable = 'on';
				
				% turning on keyframe components
				APP.add_keyframe_button.Enable = 'on';
				
				% turning on additional display components
		end
				
			
	
	%% misc
	%
	
	case 'misc'
		%TODO
	
end