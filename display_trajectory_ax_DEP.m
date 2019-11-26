function [] = display_trajectory_ax(APP)
%% special case, hence its own function.
%  
%  trajectory axis does not need to be updated and redrawn every display call.
%  rather, any time a change is made to either the KEYFRAMES or polygon_list, this
%  method is called.
%  

% first, check to confirm both keyframes and cells are present

KEYFRAMES = getappdata(APP.MAIN,'KEYFRAMES');
polygon_list = getappdata(APP.MAIN,'polygon_list');

disp('made it to display_trajectory_ax.m');

if ~isstruct(KEYFRAMES{1}) || isempty(polygon_list)
	
	% turn off APP.trajectory_ax
	cla(APP.trajectory_ax);
	APP.trajectory_ax.Visible = 'off';
	APP.trajectory_ax.HitTest = 'off';
	
	% turn off 3D visualization
	cla(APP.signal_visualization_box);
	APP.signal_visualization_box.Visible = 'off';
	APP.signal_visualization_box.HitTest = 'off';
	
	return;
end

disp('made it through initial check in display_trajectory_ax.m');

cla(APP.signal_visualization_box);
APP.signal_visualization_box.Visible = 'off';
APP.signal_visualization_box.HitTest = 'off';

cla(APP.trajectory_ax);
APP.trajectory_ax.Visible = 'on';
APP.trajectory_ax.HitTest = 'on';

% grab cell signal information, color information, cell selection information
cell_signals = getappdata(APP.MAIN,'cell_signals');
co = getappdata(APP.MAIN,'color_matrix');

% need current keyframe information to properly display trajectories
% ie, which keyframe is currently selected?

frame_no = APP.film_slider.Value;

curr_kf_tag = str2num(APP.keyframe_map.Tag);

if curr_kf_tag < 1
	% complicated
	disp('complicated');
	
	kf_ref_arr = getappdata(APP.MAIN,'keyframe_ref_array');
	tmp_kf_pointer = max(kf_ref_arr,[],1);
	
	for i=1:size(cell_signals,1)
		curr_color = mod(i,7);
		if curr_color == 0
			curr_color = 7;
		end
		count_mat = zeros(size(tmp_kf_pointer));
		for j=1:size(tmp_kf_pointer,2)
			if tmp_kf_pointer(j) == 0
				count_mat(j) = 0;
			else
				kf_idx = tmp_kf_pointer(j);
				curr_cell = cell_signals{i,kf_idx};
				curr_signals = curr_cell{j};
				curr_incl_excl = KEYFRAMES{kf_idx}.incl_excl{j};
				if ~isempty(curr_signals)
					curr_signals(curr_incl_excl==0)=0;
					count_mat(j) = sum(curr_signals);
				else
					count_mat(j) = 0;
				end
			end
		end
		
		plot(APP.trajectory_ax,count_mat,'color',co(curr_color,:),'LineWidth',1,'Tag',num2str(i));
		
	end
	
	curr_frame = APP.film_slider.Value;
	plot(APP.trajectory_ax,[curr_frame curr_frame],APP.trajectory_ax.YLim,'color','black','linestyle','--');
	
else
	% simple
	disp('simple');
	
	for i=1:size(cell_signals,1)
		curr_cell = cell_signals{i,curr_kf_tag};
		curr_color = mod(i,7);
		if curr_color == 0
			curr_color = 7;
		end
		count_mat = zeros(size(curr_cell));
		for j=1:size(curr_cell,2)
			if ~isempty(curr_cell{j})
                curr_signals = curr_cell{j};
				curr_incl_excl = KEYFRAMES{curr_kf_tag}.incl_excl{j};
                if ~isempty(curr_signals)
					curr_signals(curr_incl_excl==0)=0;
					count_mat(j) = sum(curr_signals);
                else
                    count_mat(j) = sum(curr_cell{j});
                end
			else
				count_mat(j) = 0;
			end
		end
		
		plot(APP.trajectory_ax,count_mat,'color',co(curr_color,:),'LineWidth',1,'Tag',num2str(i));	
		
	end
	
	curr_frame = APP.film_slider.Value;
	plot(APP.trajectory_ax,[curr_frame curr_frame],APP.trajectory_ax.YLim,'color','black','linestyle','--');
end

disp('completed display_trajectory_ax.m');

some_color = APP.ax2.Color;
assignin('base','color_after_traj_call',some_color);
