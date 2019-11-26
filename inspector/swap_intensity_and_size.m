function [] = swap_intensity_and_size(hand,evt,INSPECT)
%% <placeholder>
%

% get hand.String
button_string = hand.String;

% unfortunately a bit specialized, but whatever
% curr_hist_state = INSPECT.min_intensity_label.Enable;

if strcmp('Size Histogram',button_string) 

    % turn size associated components on 
    INSPECT.min_size_label.Enable = 'on';
    INSPECT.min_size_box.Enable = 'on';
    INSPECT.max_size_label.Enable = 'on';
    INSPECT.max_size_box.Enable = 'on';
    
    % turn intensity associated components off
    INSPECT.min_intensity_label.Enable = 'off';
    INSPECT.min_intensity_box.Enable = 'off';
    INSPECT.max_intensity_label.Enable = 'off';
    INSPECT.max_intensity_box.Enable = 'off';
     
    % histogram creation - size
    cla(INSPECT.hist_ax);
    hold on
    size_info = getappdata(INSPECT.figure_handle,'size_info');
    histogram(INSPECT.hist_ax,size_info);
    
    % setappdata(INSPECT.figure_handle,'curr_hist',curr_hist);
    
    lower_bound = str2num(INSPECT.min_size_box.String);
    upper_bound = str2num(INSPECT.max_size_box.String);
    %
    line(INSPECT.hist_ax,[lower_bound lower_bound],INSPECT.hist_ax.YLim,...
        'color','red','linestyle','--','marker','>');
    line(INSPECT.hist_ax,[upper_bound upper_bound],INSPECT.hist_ax.YLim,...
        'color','green','linestyle','--','marker','<');
    %
    hold off
    
    histogram_axis_children = allchild(INSPECT.hist_ax);
    for idx=1:size(histogram_axis_children,1)
        histogram_axis_children(idx).ButtonDownFcn = {@inspector_hist_click,INSPECT};
    end
    INSPECT.hist_ax.ButtonDownFcn = {@inspector_hist_click,INSPECT};
    
else
    
    % turn intensity associated components on
    INSPECT.min_intensity_label.Enable = 'on';
    INSPECT.min_intensity_box.Enable = 'on';
    INSPECT.max_intensity_label.Enable = 'on';
    INSPECT.max_intensity_box.Enable = 'on';
    
    % turn size associated components off 
    INSPECT.min_size_label.Enable = 'off';
    INSPECT.min_size_box.Enable = 'off';
    INSPECT.max_size_label.Enable = 'off';
    INSPECT.max_size_box.Enable = 'off';
    
    % histogram creation - intensity
    cla(INSPECT.hist_ax);
    intensity_info = getappdata(INSPECT.figure_handle,'hist_data');
    curr_hist = histogram(INSPECT.hist_ax,intensity_info);
    
    setappdata(INSPECT.figure_handle,'curr_hist',curr_hist);
    
    lower_bound = str2num(INSPECT.min_intensity_box.String);
    upper_bound = str2num(INSPECT.max_intensity_box.String);
    
    line(INSPECT.hist_ax,[lower_bound lower_bound],INSPECT.hist_ax.YLim,...
        'color','red','linestyle','--','marker','>');
    line(INSPECT.hist_ax,[upper_bound upper_bound],INSPECT.hist_ax.YLim,...
        'color','green','linestyle','--','marker','<');
    
    histogram_axis_children = allchild(INSPECT.hist_ax);
    for idx=1:size(histogram_axis_children,1)
        histogram_axis_children(idx).ButtonDownFcn = {@inspector_hist_click,INSPECT};
    end
    INSPECT.hist_ax.ButtonDownFcn = {@inspector_hist_click,INSPECT};
    
end

%
%%%
%%%%%
%%%
%