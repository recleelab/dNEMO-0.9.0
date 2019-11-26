function [cell_arr, traj_arr] = parse_cells(spot_detect, cell_signals)
%% <placeholder>
%

cell_arr = {};
traj_arr = {};

for cell_idx=1:length(cell_signals)
    
    spot_info_arr = spot_detect.spotInfoArr;
    curr_cell_logic = cell_signals{cell_idx};
    
    for logic_idx=1:length(curr_cell_logic)
        excl_arr = spot_detect.getExclusionLogicArray(logic_idx);
        frame_arr = curr_cell_logic{logic_idx};
        frame_arr(excl_arr) = 0;
        curr_cell_logic{logic_idx} = frame_arr;
    end
    
    SPOTS = struct;
    TRAJ = struct;
    
    for frame_idx=1:length(spot_info_arr)
        curr_frame_info = spot_info_arr{frame_idx};
        curr_frame_logic = curr_cell_logic{frame_idx};
        if ~isempty(curr_frame_info)
            curr_coords = curr_frame_info.objCoords(curr_frame_logic,:);
            if ~isempty(curr_coords)
                col_idx = 2;
                curr_signal = curr_frame_info.SIG_VALS(curr_frame_logic,col_idx);
                curr_background = curr_frame_info.BG_VALS(curr_frame_logic,col_idx);
                curr_values = pull_spot_information(curr_signal,curr_background);
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
                
                % additional trajectory assignment
                TRAJ(frame_idx).SPOT_COUNT = size(curr_coords,1);
                TRAJ(frame_idx).INT_AVG = mean(curr_values(:,1));
                TRAJ(frame_idx).INT_MED = mean(curr_values(:,2));
                TRAJ(frame_idx).INT_SUM = mean(curr_values(:,3));
                TRAJ(frame_idx).INT_MAX = mean(curr_values(:,5));
                TRAJ(frame_idx).SIZE = mean(curr_values(:,4));
                
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
                
                % additional trajectory assignment
                TRAJ(frame_idx).SPOT_COUNT = 0;
                TRAJ(frame_idx).INT_AVG = 0;
                TRAJ(frame_idx).INT_MED = 0;
                TRAJ(frame_idx).INT_SUM = 0;
                TRAJ(frame_idx).INT_MAX = 0;
                TRAJ(frame_idx).SIZE = 0;
            end
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
            
            % additional trajectory assignment
            TRAJ(frame_idx).SPOT_COUNT = 0;
            TRAJ(frame_idx).INT_AVG = 0;
            TRAJ(frame_idx).INT_MED = 0;
            TRAJ(frame_idx).INT_SUM = 0;
            TRAJ(frame_idx).INT_MAX = 0;
            TRAJ(frame_idx).SIZE = 0;
        end
    end
    
    cell_arr = cat(1,cell_arr,{SPOTS});
    traj_arr = cat(1,traj_arr,{TRAJ});
    
end

%
%%%
%%%%%
%%%
%