function [process,values,toggles] = display_check(APP)
%%
% 

process = 0;

% check - is keyframe currently being created?
wavelet_slider_status = APP.current_threshold_slider.Enable;
if strcmp(wavelet_slider_status,'on')
	process = 0;
end

% check - is polygon currently being drawn?
% drawing_poly = strcmp('Finish Drawing Cell',APP.add_object_button.String);
drawing_poly = strcmp('Finish Modifying Cell',APP.add_object_button.String);
% modifying_poly = strcmp('Finish Modifying Cell',APP.modify_cell_button.String);
% if drawing_poly || modifying_poly
if drawing_poly
	process = 2;
end

% check - are signals being manually excluded?
if strcmp('Stop Removing Signals',APP.remove_signals_button.String)
	process = 3;
end

%
%%%
%

values = zeros(4,1);
% (1) --> are there keyframes
% (2) --> are there cells
% (3) --> index of created_cell_selection
% (4) --> current keyframe selection

% check - does overlay object exist?
overlay = getappdata(APP.MAIN,'OVERLAY');
if ~isempty(overlay)
    values(1) = 1;
    process = 1;
end

% are there keyframes?
KEYFRAMES = getappdata(APP.MAIN,'KEYFRAMES');
if isstruct(KEYFRAMES{1})
	values(1,1) = 1;
	
	% is a specific keyframe selected for display?
	tmp_string = APP.keyframe_map.Tag;
	if ~isempty(tmp_string)
		values(4,1) = str2num(APP.keyframe_map.Tag);
    end
    
    % TEMPORARY - WANT TO SEE IF THIS FIXES IT
    %
    % if there are keyframes, axis signals can be selected for a 
    % call to the inspector tool
    %
    if process~=3 && process ~= 2
        set(APP.ax2,'ButtonDownFcn',{@select_signal_axis_click,APP});
        set(APP.ax2,'PickableParts','all','hittest','on');

        inspector_menu = uicontextmenu();
        inspect_image = uimenu('Parent',inspector_menu,'Label','Open Inspector',...
                                'callback',{@inspector_call,APP});
        set(APP.ax2,'UIContextMenu',inspector_menu);
    end
    %}
    %
    % END TEMPORARY SHUTDOWN
else
	
    % value already 0, no change there. just need to turn off pickable
    % parts for APP.ax2
    APP.ax2.PickableParts = 'none';
    APP.ax2.HitTest = 'off';
    
end

% are there cells?
polygon_list = getappdata(APP.MAIN,'polygon_list');
if ~isempty(polygon_list)
	values(2,1) = 1;
	
	% is one cell selected for display?
	selection_idx = APP.created_cell_selection.Value;
	values(3,1) = selection_idx - 1;
	
end 

%
%%%
%

toggles = zeros(4,1);
% (1) --> all frame signals @ current keyframe
% (2) --> frame signals in cells @ current keyframe
% (3) --> display drawn cell boundaries
% (4) --> display excluded signals @ current keyframe

% APP.remove_signals_button
if values(1,1)
    APP.remove_signals_button.Enable = 'on';
else
    APP.remove_signals_button.Enable = 'off';
end

% APP.frame_signal_toggle
if values(1,1) || process == 1
	APP.frame_signal_toggle.Enable = 'on';
else
	APP.frame_signal_toggle.Enable = 'off';
end
toggles(1,1) = APP.frame_signal_toggle.Value;

% APP.cell_signal_toggle
if values(1,1) && values(2,1)
	APP.cell_signal_toggle.Enable = 'on';
else
	APP.cell_signal_toggle.Enable = 'off';
end
toggles(2,1) = APP.cell_signal_toggle.Value;

% APP.cell_boundary_toggle
if values(2,1)
	APP.cell_boundary_toggle.Enable = 'on';
else
	APP.cell_boundary_toggle.Enable = 'off';
end
toggles(3,1) = APP.cell_boundary_toggle.Value;

% APP.excluded_signal_toggle
if values(1,1)
	APP.excluded_signal_toggle.Enable = 'on';
else
	APP.excluded_signal_toggle.Enable = 'off';
end
toggles(4,1) = APP.excluded_signal_toggle.Value;

% APP.remove_signals_button

% trajectory/sigvis elements
if values(1,1) && values(2,1) && values(3,1)
    APP.sig_traj_bg.Visible = 'on';
else
    APP.sig_traj_bg.Visible = 'off';
end

%
%%%
%





