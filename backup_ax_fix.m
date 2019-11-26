function [] = backup_ax_fix(APP, err_flag)
%% function to correct whiteout, hopefully won't have to be called but
%  not a terrible backup

if err_flag
    
    disp('axis whiteout error logged. fixing.');
    
    % need to reset w/out clearing the axis
    APP.ax2.Units = 'normalized';
    APP.ax2.Position = APP.ax1.Position;
    APP.ax2.YDir = 'reverse';
    APP.ax2.Color = 'none';
    
    APP.ax2.XAxisLocation = 'top';
    APP.ax2.XTick = [];
    APP.ax2.YTick = [];
    APP.ax2.NextPlot = 'add';
    
    axis_display_sync(APP,APP.ax1,APP.ax2);
    
end

APP.ax2.PickableParts = 'visible';
APP.ax2.HitTest = 'on';

disp('fixed error');

% assignment for all scatter objects if the error is logged

%
%%%
%%%%%
%%%
%