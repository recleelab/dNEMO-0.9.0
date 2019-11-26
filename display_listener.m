function [] = display_listener(hand,evt,APP)
%% simple fxn to handle some application ons and offs
%  
%  unfortunately a bit of a catch-all for some of the applications switches

switch hand
	
	case APP.frame_signal_toggle
		curr_state = APP.frame_signal_toggle.Value;
		if curr_state 
			APP.cell_signal_toggle.Value = 0;
		end
		display_call(hand,evt,APP);
	
	%
	%%%
	%
	
	case APP.cell_signal_toggle
		curr_state = APP.cell_signal_toggle.Value;
		if curr_state
			APP.frame_signal_toggle.Value = 0;
		end
		display_call(hand,evt,APP);
	
	%
	%%%
	%
	
	case APP.created_cell_selection
		curr_state = APP.created_cell_selection.Value;
		if curr_state > 1
			APP.delete_object_button.Enable = 'on';
			APP.modify_cell_button.Enable = 'on';
		else
			APP.delete_object_button.Enable = 'off';
			APP.modify_cell_button.Enable = 'off';
            
            % updated trajectory axis switches
            APP.sig_traj_rb1.Value = 1;
            APP.sig_traj_rb2.Value = 0;
            cla(APP.signal_visualization_box);
            APP.signal_visualization_box.ButtonDownFcn = '';
            APP.signal_visualization_box.Visible = 'off';
		end
		display_trajectory_ax(APP);
		display_call(hand,evt,APP);
	
	%
	%%%
	%
	
	case APP.remove_signals_button
		curr_string = APP.remove_signals_button.String
		curr_state = strcmp(curr_string,'Remove Signals');
		if curr_state
			% beginning exclusion, set to 'Stop Removing Signals'
			APP.remove_signals_button.String = 'Stop Removing Signals';
			master_listener(APP,'exclude',1);
			display_call(hand,evt,APP);
		else
			% finishing exclusion, set to 'Remove Signals'
			APP.remove_signals_button.String = 'Remove Signals';
			master_listener(APP,'exclude',2);
			display_call(hand,evt,APP);
		end
	
	%
	%%%
	%
    
    case APP.sig_traj_rb1
        % first sig_traj radiobutton, display signal trajectories in 
        % identified cells
        APP.sig_traj_rb1.Value = 1;
        APP.sig_traj_rb2.Value = 0;
        
        % call to handle trajectory axis
        display_trajectory_ax(APP);
    
    %
    %%%
    %
    
    case APP.sig_traj_rb2
        % second sig_traj radiobutton, display 3D representation of 
        % selected cell
        APP.sig_traj_rb2.Value = 1;
        APP.sig_traj_rb1.Value = 0;
        
        % call to handle sig visualizer
        display_signals_in_3D(APP);
    
    %
    %%%
    %

end
