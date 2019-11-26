function [traj_created] = create_cellular_trajectories(APP,root_name)
%% <placeholder>
%

kf_ref_arr = getappdata(APP.MAIN,'keyframe_ref_array');
KEYFRAMES = getappdata(APP.MAIN,'KEYFRAMES');
cell_signals = getappdata(APP.MAIN,'cell_signals');
num_frames = APP.film_slider.Max;

% compose table of relevant data
traj_created = 0;
if ~isempty(cell_signals{1})

    results_mat = zeros(size(cell_signals,1),num_frames);
    for cell_idx=1:size(cell_signals,1)

        for frame_idx=1:num_frames

            top_kf_idx = max(kf_ref_arr(:,frame_idx));
            if top_kf_idx~=0
                curr_kf = KEYFRAMES{top_kf_idx};
                curr_spotInfo = curr_kf.spotInfo{frame_idx};
                curr_incl_excl = curr_kf.incl_excl{frame_idx};
            
                if ~isempty(curr_spotInfo)

                    curr_cell = cell_signals{cell_idx,top_kf_idx};
                    cell_in_frame = curr_cell{frame_idx};

                    % remove any signals that should be excluded
                    cell_in_frame(curr_incl_excl==0) = 0;

                    % just need signal count per cell
                    num_signals_in_cell = sum(cell_in_frame);
                    results_mat(cell_idx,frame_idx) = num_signals_in_cell;
                else
                    results_mat(cell_idx,frame_idx) = 0;
                end
            end
        end
    end
    
    % create new file
    traj_filename = strcat(root_name,'_trajectories.mat');
    save(traj_filename,'results_mat');
    traj_created = 1;
    
end

%
%%%
%%%%%
%%%
%