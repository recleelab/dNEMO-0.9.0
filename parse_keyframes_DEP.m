function [spot_arr] = parse_keyframes_DEP(KEYFRAMES)
%% <placeholder>
%

num_KF = length(KEYFRAMES);
spot_arr = cell(num_KF,1);

for kf_idx=1:num_KF
    
    KF = KEYFRAMES{kf_idx};
    spot_info_arr = KF.spotInfo;
    incl_excl_arr = KF.incl_excl;
    
    sig_measure = KF.SigMeasure;
    switch sig_measure
        case 'ZCOORD'
            col_idx = 2;
        case 'FULL'
            col_idx = 1;
    end
    
    SPOTS = struct;
    
    for frame_idx=1:length(spot_info_arr)
        
        curr_frame_info = spot_info_arr{frame_idx};
        curr_frame_logic = incl_excl_arr{frame_idx};
        if ~islogical(curr_frame_logic)
            curr_frame_logic = logical(curr_frame_logic);
        end
        
        if ~isempty(curr_frame_info)
            
            % get relevant information
            % 1 - entire object (all available slices)
            % 2 - just slice at object middle (where signal brightest)
            curr_coords = curr_frame_info.objCoords(curr_frame_logic,:);
            curr_signal = curr_frame_info.SIG_VALS(curr_frame_logic,col_idx); % signal (1 or 2)
            curr_background = curr_frame_info.BG_VALS(curr_frame_logic,col_idx); % background (1 or 2)
            curr_values = pull_spot_information(curr_signal,curr_background);

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
    
    spot_arr{kf_idx} = SPOTS;
    
end

%
%%%
%%%%%
%%%
%