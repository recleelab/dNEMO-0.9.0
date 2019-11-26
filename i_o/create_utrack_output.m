function [utrack_all,utrack_cells] = create_utrack_output(APP,root_name)
%% fxn for creating utrack-compatible output for DN results
%
%  struct name: movieInfo
%  fields: xCoord [p x 2], yCoord [p x 2], zCoord [p x 2], amp [p x 2]
%

% use kf_ref_array, KEYFRAMES, incl_excl to get valid output
kf_ref_arr = getappdata(APP.MAIN,'keyframe_ref_array');
KEYFRAMES = getappdata(APP.MAIN,'KEYFRAMES');
cell_signals = getappdata(APP.MAIN,'cell_signals');
num_frames = APP.film_slider.Max;

% initialize movieInfo
movieInfo = struct;

for idx=1:num_frames
    top_kf_idx = max(kf_ref_arr(:,idx));
    curr_kf = KEYFRAMES{top_kf_idx};
    curr_spotInfo = curr_kf.spotInfo{idx};
    curr_incl_excl = curr_kf.incl_excl{idx};
    if ~isempty(curr_spotInfo)
        objCoords = curr_spotInfo.objCoords;
        signal_values = curr_spotInfo.SIG_VALS;
        background_values = curr_spotInfo.BG_VALS;

        mean_bg_vals = cellfun(@mean,background_values(:,2));
        tmp_intensity_vals = zeros(size(signal_values,1),1);
        for tmp_idx=1:size(signal_values,1)
            tmp_intensity_vals(tmp_idx) = mean(cell2mat(signal_values(tmp_idx)) - mean_bg_vals(tmp_idx));
        end

        xCoords = objCoords(curr_incl_excl,1);
        xCoords = cat(2,xCoords,zeros(size(xCoords,1),1));

        yCoords = objCoords(curr_incl_excl,2);
        yCoords = cat(2,yCoords,zeros(size(yCoords,1),1));

        zCoords = objCoords(curr_incl_excl,3);
        zCoords = cat(2,zCoords,zeros(size(zCoords,1),1));

        amp = tmp_intensity_vals(curr_incl_excl);
        amp = cat(2,amp,zeros(size(amp,1),1));

        movieInfo(idx).xCoord = xCoords;
        movieInfo(idx).yCoord = yCoords;
        movieInfo(idx).zCoord = zCoords;
        movieInfo(idx).amp = amp;
    else
        movieInfo(idx).xCoord = [];
        movieInfo(idx).yCoord = [];
        movieInfo(idx).zCoord = [];
        movieInfo(idx).amp = [];
    end
end

% will always create a utrack file regardless of whether cells are 
% separate yet -- current directory is the utrack folder
all_spots_filename = strcat(root_name,'_all_spots.mat');
save(all_spots_filename,'movieInfo');
utrack_all = 1;

% confirm utrack output per cell if it exists
utrack_cells = 0;
if ~isempty(cell_signals{1})
    
    num_cells = size(cell_signals,1);
    for cell_idx=1:num_cells
        
        % initialize movieInfo
        movieInfo = struct;
        
        for frame_idx=1:num_frames
        
            top_kf_idx = max(kf_ref_arr(:,frame_idx));
            curr_kf = KEYFRAMES{top_kf_idx};
            curr_spotInfo = curr_kf.spotInfo{frame_idx};
            curr_incl_excl = curr_kf.incl_excl{frame_idx};
            if ~isempty(curr_spotInfo)
                curr_cell = cell_signals{cell_idx,top_kf_idx};
                cell_in_frame = curr_cell{frame_idx};
            
                % remove erroneous signals
                cell_in_frame(curr_incl_excl==0) = 0;

                % pull all relevant coordinates
                objCoords = curr_spotInfo.objCoords;
                signal_values = curr_spotInfo.SIG_VALS;
                background_values = curr_spotInfo.BG_VALS;

                mean_bg_vals = cellfun(@mean,background_values(:,2));
                tmp_intensity_vals = zeros(size(signal_values,1),1);
                for tmp_idx=1:size(signal_values,1)
                    tmp_intensity_vals(tmp_idx) = mean(cell2mat(signal_values(tmp_idx)) - mean_bg_vals(tmp_idx));
                end

                xCoords = objCoords(cell_in_frame,1);
                xCoords = cat(2,xCoords,zeros(size(xCoords,1),1));

                yCoords = objCoords(cell_in_frame,2);
                yCoords = cat(2,yCoords,zeros(size(yCoords,1),1));

                zCoords = objCoords(cell_in_frame,3);
                zCoords = cat(2,zCoords,zeros(size(zCoords,1),1));

                amp = tmp_intensity_vals(cell_in_frame);
                amp = cat(2,amp,zeros(size(amp,1),1));

                movieInfo(frame_idx).xCoord = xCoords;
                movieInfo(frame_idx).yCoord = yCoords;
                movieInfo(frame_idx).zCoord = zCoords;
                movieInfo(frame_idx).amp = amp;
            else
                movieInfo(idx).xCoord = [];
                movieInfo(idx).yCoord = [];
                movieInfo(idx).zCoord = [];
                movieInfo(idx).amp = [];
            end
            
        end
        
        cell_results_filename = strcat(root_name,'utrack_cell_0',num2str(cell_idx),'.mat');
        save(cell_results_filename,'movieInfo');
        
    end
    utrack_cells = 1;
end




