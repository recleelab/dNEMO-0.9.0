function [cell_arr, traj_arr] = parse_cells_DEP(KEYFRAMES, cell_signals)
%% <placeholder>
%

num_KF = length(KEYFRAMES);
num_cells = size(cell_signals,1);
if num_KF == 1
    cell_arr = cell(num_cells,1);
else
    cell_arr = cell(num_cells,num_KF+1);
end
traj_arr = cell_arr;

for kf_idx=1:num_KF
    
    KF = KEYFRAMES{kf_idx};
    
    sig_measure = KF.SigMeasure;
    switch sig_measure
        case 'ZCOORD'
            col_idx = 2;
        case 'FULL'
            col_idx = 1;
    end
    
    spot_info_arr = KF.spotInfo;
    incl_excl_arr = KF.incl_excl;
    
    for cell_idx=1:num_cells
        curr_cell_logic = cell_signals{cell_idx};
        for logic_idx=1:length(curr_cell_logic)
            
            curr_incl_excl = incl_excl_arr{logic_idx};
            tmp_cell_logic = curr_cell_logic{logic_idx};
            if ~isempty(curr_incl_excl) && ~isempty(tmp_cell_logic)
                
                tmp_cell_logic(curr_incl_excl==0) = 0;
                curr_cell_logic{logic_idx} = tmp_cell_logic;
            end
            
        end

        SPOTS = struct;
        tmp_traj = zeros(length(spot_info_arr),1);
        for frame_idx=1:length(spot_info_arr)
            
            curr_frame_info = spot_info_arr{frame_idx};
            if ~isempty(curr_frame_info)
            
                curr_frame_logic = curr_cell_logic{frame_idx};
                curr_coords = curr_frame_info.objCoords(curr_frame_logic,:);
                curr_signal = curr_frame_info.SIG_VALS(curr_frame_logic,col_idx);
                curr_background = curr_frame_info.BG_VALS(curr_frame_logic,col_idx);
                curr_values = pull_spot_information(curr_signal, curr_background);
            
                % pull raw information
                raw_values = pull_spot_information_raw(curr_signal,curr_background,1);

                SPOTS(frame_idx).TIME = ones(length(curr_coords(:,1)),1).*frame_idx;
                SPOTS(frame_idx).XCoord = curr_coords(:,1);
                SPOTS(frame_idx).YCoord = curr_coords(:,2);
                SPOTS(frame_idx).ZCoord = curr_coords(:,3);
                SPOTS(frame_idx).INT_AVG = curr_values(:,1);
                SPOTS(frame_idx).INT_MED = curr_values(:,2);
                SPOTS(frame_idx).INT_SUM = curr_values(:,3);
                SPOTS(frame_idx).INT_MAX = curr_values(:,5);
                SPOTS(frame_idx).SIZE = curr_values(:,4);

                SPOTS(frame_idx).INT_AVG_RAW = raw_values(:,1);
                SPOTS(frame_idx).INT_MAX_RAW = raw_values(:,2);
                SPOTS(frame_idx).INT_SUM_RAW = raw_values(:,3);
                SPOTS(frame_idx).BG_MEAN = raw_values(:,4);
                SPOTS(frame_idx).BG_STD = raw_values(:,5);
                SPOTS(frame_idx).BG_MAX = raw_values(:,6);
                SPOTS(frame_idx).BG_SUM = raw_values(:,7);
                SPOTS(frame_idx).BG_SIZE = raw_values(:,8);
                
                tmp_traj(frame_idx) = size(curr_coords,1);

            else

                SPOTS(frame_idx).XCoord = [];
                SPOTS(frame_idx).YCoord = [];
                SPOTS(frame_idx).ZCoord = [];
                SPOTS(frame_idx).INT_AVG = [];
                SPOTS(frame_idx).INT_MED = [];
                SPOTS(frame_idx).INT_SUM = [];
                SPOTS(frame_idx).SIZE = [];

                SPOTS(frame_idx).INT_AVG_RAW = [];
                SPOTS(frame_idx).INT_MAX_RAW = [];
                SPOTS(frame_idx).INT_SUM_RAW = [];
                SPOTS(frame_idx).BG_MEAN = [];
                SPOTS(frame_idx).BG_STD = [];
                SPOTS(frame_idx).BG_MAX = [];

            end
            
        end
        
            
        cell_arr{cell_idx,kf_idx} = SPOTS;
        traj_arr{cell_idx} = tmp_traj;
        
        
        
    end

    
end

%
%%%
%%%%%
%%%
%