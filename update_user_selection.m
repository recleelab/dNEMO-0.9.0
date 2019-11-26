function [] = update_user_selection(APP,circumstance)

if circumstance == 1
	
    KEYFRAMES = getappdata(APP.MAIN,'KEYFRAMES');
    kf_ref_arr = getappdata(APP.MAIN,'keyframe_ref_array');
    co = getappdata(APP.MAIN,'color_matrix');
    
    cla(APP.keyframe_map);
    
    if isstruct(KEYFRAMES{1,1})
        % there's at least 1 keyframe. display on APP.keyframe_map
        % displaying basic keyframe information
        
        line_vals = 1:1:size(kf_ref_arr,2);
        
        for i=1:size(KEYFRAMES,1)
            disp(i);
            line_x = line_vals(kf_ref_arr(i,:)==i);
            start_pt = line_x(1,1);
            end_pt = line_x(1,size(line_x,2));
            % start_pt = curr_kf.KF_START;
            % end_pt = curr_kf.KF_END;
            if start_pt == end_pt
                % just scatter
                scatter(APP.keyframe_map,start_pt,i,10,co(i,:));
            else
                % plot
                line_y = ones(size(line_x))*i;
                plot(APP.keyframe_map,line_x,line_y,'Color',co(i,:),'LineWidth',1.25);
                scatter(APP.keyframe_map,start_pt,i,10,co(i,:));
            end
            
        end
        % basic kfref line
        ref_line_x = 1:size(kf_ref_arr,2);
        ref_line_y = zeros(size(ref_line_x));
        plot(APP.keyframe_map,ref_line_x,ref_line_y,'Color','black','LineWidth',1.25,'LineStyle','--');
        
        % advanced kfref line
        color_refs = max(kf_ref_arr,[],2);
        
        
        % additional axes preparations
        APP.keyframe_map.XLim = [APP.film_slider.Min - 1,APP.film_slider.Max + 1];
        % APP.keyframe_map.XTick = APP.keyframe_map.XLim(1,1):APP.keyframe_map.XLim(1,2);
        APP.keyframe_map.YLim = [-1,size(KEYFRAMES,1)+1];
        APP.keyframe_map.YTick = [];
        
        % APP.keyframe_map.HitTest = 'on';
        % APP.keyframe_map.PickableParts = 'visible';
        APP.keyframe_map.Tag = '0';
        
        % axes children, axes callback assignments
        
        
        % keyframe_selection update
        num_kfs = size(KEYFRAMES,1);
        S = cell(num_kfs+1,1);
        S{1,1} = 'ALL';
        for i=1:num_kfs
        	kfstr = strcat('Keyframe #',num2str(i));
        	S{i+1,1} = kfstr;
        end
        APP.keyframe_selection.String = S;
        APP.keyframe_selection.Value = 1;
        APP.keyframe_selection.Enable = 'on';

    else
        % there are no keyframes, turn off appropriate components
    end
    
end

if circumstance == 2
    polygon_list = getappdata(APP.MAIN,'polygon_list');
    if isempty(polygon_list)
        S = cell(1);
        S{1,1} = 'N/A';
        APP.created_cell_selection.String = S;
        APP.created_cell_selection.Value = 1;
        APP.created_cell_selection.Enable = 'inactive';
        
        % additionally...
        APP.cell_boundary_toggle.Enable = 'off';
        APP.cell_boundary_toggle.Value = 0;
        
    else
        num_cells = size(polygon_list,1);
        S = cell(num_cells+1,1);
        S{1,1} = 'ALL';
        for i=1:num_cells
            cell_str = strcat('Cell #',num2str(i));
            S{i+1,1} = cell_str;
        end
        APP.created_cell_selection.String = S;
        APP.created_cell_selection.Value = 1;
        APP.created_cell_selection.Enable = 'on';
        
        % additionally...
        APP.cell_boundary_toggle.Enable = 'on';
        APP.cell_boundary_toggle.Value = 1;
    end
end