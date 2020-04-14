function [] = set_par_processes(hand, evt, APP)
%% <placeholder>
%

% check if parallel processing toolbox exists
par_flag = 0;
tmp_ver_struct = ver;
avail_toolboxes = {tmp_ver_struct.Name}.';
par_toolbox_present = max(strcmp(avail_toolboxes, 'Parallel Computing Toolbox'));
if par_toolbox_present
    par_flag = 1;
end

if ~par_flag
    warndlg('Warning. Parallel computing toolbox not found. Parallel processes not possible at this time.',...
        'Parallel Computing Toolbox not found.');
    return;
end

if strcmp(hand.Checked, 'on')
    
    % turn off parallel processes
    pool_obj = gcp('nocreate');
    delete(pool_obj);
    
    hand.Checked = 'off';
else
    
    % turn on parallel processes
    [num_cores] = par_get_num_cores();
    cores_to_use = num_cores-1;
    
    if cores_to_use < 2
        warndlg('Warning. 2 or fewer cores found in current machine. Not advisable to run processes in parallel.',...
            '<= 2 cores found');
    end

    % initializing parallel pool
    curr_pool = gcp('nocreate');
    if isempty(curr_pool)
        curr_pool = parpool(cores_to_use);
    else
        if curr_pool.NumWorkers ~= cores_to_use
            delete(gcp('nocreate'));
            curr_pool = parpool(cores_to_use);
        end
    end
    
    hand.Checked = 'on';
end

%
%%%
%%%%%
%%%
%