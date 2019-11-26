function [] = change_directory(hand,~,APP)
%% fxn meant to assist user in changing directories for image/results
%  simple call, changes path stored w/in created APP.

called_label = get(hand,'label');

if strcmp(called_label,'Images') == 1
    new_dir = uigetdir(matlabroot,'MATLAB Root Dir');
    if new_dir ~= 0
        % assign to APP, return
        setappdata(APP.MAIN,'images_dir_path',new_dir);
    end
end

if strcmp(called_label,'Results') == 1
    new_dir = uigetdir(matlabroot,'MATLAB Root Dir');
    if new_dir ~= 0
        % assign to APP, return
        setappdata(APP.MAIN,'results_dir_path',new_dir);
    end
end
