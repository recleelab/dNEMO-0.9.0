function [err_flag] = backup_ax_check(APP)
%% backup function for the axis white-out problem
% checks to see if background color of APP.ax2 == [1 1 1]; if so, error
% flag returned
err_flag = 0;
curr_color = APP.ax2.Color;
if isnumeric(curr_color)
    err_flag = 1;
end

%
%%%
%%%%%
%%%
%