function [avi_created] = create_avi(APP,root_name)
%% <placeholder>
%

avi_created = 0;
AVI_answer = questdlg('Create a short AVI depicting signals captured using this application?',...
				'Record Film','Yes','No','Yes');
switch AVI_answer
	case 'Yes'
		avi_suffix = '_detected_spots.avi';
        avi_file = strcat(root_name,avi_suffix);
        avi_scatter = VideoWriter(avi_file);

        num_frames = APP.film_slider.Max;
        APP.film_slider.Value = 1;
        APP.cell_boundary_toggle.Value = 0;
        APP.excluded_signals_toggle.Value = 0;
        APP.frame_signal_toggle.Value = 0;
        APP.cell_signal_toggle.Value = 1;
        APP.created_cell_selection.Value = 1;

        display_call(APP.film_slider,1,APP);

        set(APP.ax2,'units','pixel');
        axis_pos = get(APP.ax2,'position');
        set(APP.ax2,'units','normalized');

        for i=1:num_frames

            APP.film_slider.Value = i;
            display_call(APP.film_slider,1,APP);
            the_ax = getframe(APP.MAIN,axis_pos);
            spotMov(:,:,i) = the_ax;

        end

        open(avi_scatter);
        for j=1:num_frames
            writeVideo(avi_scatter,spotMov(:,:,j));
        end
        close(avi_scatter);
        APP.film_slider.Value = 1;
        display_call(APP.film_slider,1,APP);
        
        avi_created = 1;
	case 'No'
		% do nothing
end

%
%%%
%%%%%
%%%
%