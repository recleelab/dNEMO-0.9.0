function [] = signal_histogram_call2(APP)
%% <placeholder>
%

hist_ax_children = allchild(APP.hist_ax);

signal_search_toolbox = getappdata(APP.MAIN,'signal_search_toolbox');

if isempty(hist_ax_children)
    
    APP.hist_ax_bg_01.Enable = 'on';
    APP.hist_ax_bg_02.Enable = 'on';
    
    % no previous histogram created - setup
    selected_hist_text = APP.hist_ax_bg.SelectedObject.String;
    histogram_data = signal_search_toolbox{2};
    axes(APP.hist_ax);
    cla(APP.hist_ax);
    create_signal_distribution(APP,APP.hist_ax, histogram_data, selected_hist_text);
    axes(APP.ax2);
    
else
    
    % no previous histogram created - setup
    selected_hist_text = APP.hist_ax_bg.SelectedObject.String;
    histogram_data = signal_search_toolbox{2};
    axes(APP.hist_ax);
    cla(APP.hist_ax);
    create_signal_distribution(APP,APP.hist_ax, histogram_data, selected_hist_text);
    axes(APP.ax2);
    
    
end

%
%%%
%%%%%
%%%
%