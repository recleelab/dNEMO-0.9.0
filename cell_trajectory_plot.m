function [] = cell_trajectory_plot(varargin)

[APP,cell_delineator] = varargin{[1,2]};

set(APP.trajectory_ax,'visible','on');
cla(APP.trajectory_ax);
set(APP.trajectory_ax,'NextPlot','add');

% quick insert for sig_traj_bg
cla(APP.signal_visualization_box);
set(APP.signal_visualization_box,'visible','off');
set(APP.signal_visualization_box,'NextPlot','add','pickableparts','none','hittest','off');


child_handles = allchild(APP.sig_traj_bg);
curr_button = findobj(child_handles,'val',1);
curr_tag = curr_button.Tag;

if strcmp(curr_tag,'#1') == 1

    cell_signals = getappdata(APP.MAIN,'cell_signals');
    color_matrix = getappdata(APP.MAIN,'color_matrix');
    excluded_array = getappdata(APP.MAIN,'excluded_array');
    nFrames = get(APP.film_slider,'max');
    frame_no = get(APP.film_slider,'val');
    num_cells = length(cell_signals);
    signal_count = zeros(num_cells,nFrames);

    for r=1:num_cells
        tmp_count = cell_signals{r,1};
        for u=1:length(tmp_count)
            tmp_frame = tmp_count{1,u};
            [m,n] = size(tmp_frame);
            signal_count(r,u) = m;
        end
    end

    %%%%%%%%%%
    subtract_these_numbers = zeros(num_cells,nFrames);
    for i=1:length(excluded_array)
        curr_exclusions = excluded_array{i};
        if isempty(curr_exclusions) == 0
            for j=1:length(curr_exclusions(:,3))
                val = curr_exclusions(j,3);
                if val ~= 0
                    current_num_to_sub = subtract_these_numbers(val,i);
                    subtract_these_numbers(val,i) = current_num_to_sub+1;
                end
            end
        end
    end

    signal_count = signal_count - subtract_these_numbers;
    for i=1:size(signal_count,1)
        for j=1:size(signal_count,2)
            if signal_count(i,j) < 0
                signal_count(i,j) = 0;
            end
        end
    end

    %%%%%%%%%%

    hold on
    if cell_delineator == 0
        for r=1:num_cells
            plot(APP.trajectory_ax,signal_count(r,:));
        end
        line(APP.trajectory_ax,[frame_no frame_no],get(APP.trajectory_ax,'YLim'),'color','black','linestyle','--');
    else
        selected_color = mod(cell_delineator,7);
        if selected_color == 0
            selected_color = 7;
        end
        selected_color = color_matrix(selected_color,:);
        plot(APP.trajectory_ax,signal_count(cell_delineator,:),'color',selected_color);
        line(APP.trajectory_ax,[frame_no frame_no],get(APP.trajectory_ax,'YLim'),'color','black','linestyle','--');
    end
    hold off
    
    % added to see if buttowndown on the axis would actually work
    set(APP.trajectory_ax,'hittest','on','pickableparts','visible');
    set(APP.trajectory_ax,'buttondownfcn',{@traj_axis_button_down,APP});
    children_of_traj = allchild(APP.trajectory_ax);
    for i=1:length(children_of_traj)
        set(children_of_traj(i,1),'buttondownfcn',{@traj_axis_button_down,APP});
    end
    
    
end

if strcmp(curr_tag,'#2') == 1
    % here's where visualization_box should be set up, trajectory_ax should
    % be shut down
    
    cla(APP.trajectory_ax);
    set(APP.trajectory_ax,'visible','off','NextPlot','add');
    cla(APP.signal_visualization_box);
    set(APP.signal_visualization_box,'visible','on','pickableparts','visible','hittest','on');
    set(APP.signal_visualization_box,'buttondownfcn',{@traj_axis_button_down,APP});
    
    % decided to move the bulk of setup here, made a lot more sense
    curr_index = round(get(APP.film_slider,'value'));
    raw_image_data = getappdata(APP.MAIN,'raw_image_data');
    z_slices = raw_image_data{4};
    
    polygon_list = getappdata(APP.MAIN,'polygon_list');
    selected_poly = polygon_list{cell_delineator,1};
    polygon_in_frame = selected_poly{1,curr_index};
    poly_x = polygon_in_frame(:,1);
    poly_y = polygon_in_frame(:,2);
    % get polyshape object represented by submitted polygon
    small_polygon = polyshape(poly_x,poly_y);
    [poly_xlim,poly_ylim] = boundingbox(small_polygon);
    
    % determine vector for poly_z, which should be round((z_slices+1)/2)
    z_val = round(z_slices+1)/2;
    z_size = size(poly_x,1);
    poly_z = zeros(z_size,1);
    poly_z(1:z_size) = z_val;
    
    % get signals, assign them to a cool colormap
    cell_signals = getappdata(APP.MAIN,'cell_signals');
    selected_signals = cell_signals{cell_delineator};
    frame_centroids = selected_signals{curr_index};
    [frame_centroids] = display_exclusion_handler(APP,frame_centroids,1);
    cool_colormap = cool(z_slices+1);
    colored_z_matrix = zeros(size(frame_centroids,1),3);
    for i=1:size(frame_centroids,1)
        tmp_coord = frame_centroids(i,3);
        ceiled_tmp_coord = ceil(tmp_coord);
        colored_z_matrix(i,:) = cool_colormap(ceiled_tmp_coord,:);
    end
    c = colored_z_matrix(:,:);
    
    % actual display with all gathered components
    set(APP.signal_visualization_box,'XLimMode','manual','XLim',poly_xlim);
    set(APP.signal_visualization_box,'YLimMode','manual','YLim',poly_ylim);
    set(APP.signal_visualization_box,'ZLimMode','manual','ZLim',[0 z_slices+1]);

    hold on;
    patch(APP.signal_visualization_box,poly_x,poly_y,poly_z,'black','Facecolor','none','EdgeColor','black','linestyle','--','tag',num2str(cell_delineator));
    scatter3(APP.signal_visualization_box,frame_centroids(:,1),frame_centroids(:,2),frame_centroids(:,3),[],c,'filled');
    set(APP.signal_visualization_box,'pickableparts','visible','hittest','on');
    hold off;
    
    % assigning callback to all displayed objects on
    % signal_visualization_box
    children_of_sigvis = allchild(APP.signal_visualization_box);
    for i=1:length(children_of_sigvis)
        set(children_of_sigvis(i,1),'buttondownfcn',{@traj_axis_button_down,APP});
    end
end

function traj_axis_button_down(src,evt,APP)
%% callback for trajectory axis
%
src_type = src.Type;
src_axis = '';

assignin('base','event',evt);

% if src_type is axes, distinguish between tags on the two axes.
if strcmp(src_type,'axes') == 1
    src_axis = src.Tag;
% if src_type is a line, the trajectory axes is the src
elseif strcmp(src_type,'line') == 1
    src_axis = 'trajectory';
% if src_type is a patch, the signal_visualization_box is the src
elseif strcmp(src_type,'patch') == 1
    src_axis = 'visualization';
% if src_type is a scatter, the signal_visualization_box is the src
elseif strcmp(src_type,'scatter') == 1
    src_axis = 'visualization';
% if anything else, display the type, say no function associated with the
% given src's tag
else
    disp(strcat('No function associated w/',{' '},src_type,'.'));
end

switch src_axis
    case 'trajectory'
        traj_axis = findobj(allchild(APP.MAIN),'Tag',src_axis);
        user_click = traj_axis.CurrentPoint;
        x_coord = user_click(1,1);
        new_frame_num = round(x_coord);
        set(APP.film_slider,'val',new_frame_num);
        display_call(APP.film_slider,1,APP);
        
    case 'visualization'
        vis_axis = findobj(allchild(APP.MAIN),'Tag',src_axis);
        user_click = vis_axis.CurrentPoint;
        figure_click = APP.MAIN.CurrentPoint;
        % signal_visualization_box_handler(APP,src_type,cell_delineator,user_click,figure_click);
        sig_vis_handler(APP,src_type,user_click,figure_click);
end

