function [] = centroid_overlay2(APP, num_arg)
%% <placeholder>
%

if ~isempty(num_arg)
    
    switch num_arg
    
        case 1
            
            IMG = getappdata(APP.MAIN,'IMG');
            APP_PARAM = getappdata(APP.MAIN,'APP_PARAM');
            user_threshold = APP.current_threshold_slider.Value;
            [spotInfo, interrupt_flag] = spot_finder_interruptible(IMG, APP_PARAM, user_threshold);
            
            % handle interruption HERE
            if interrupt_flag
                % check for existence of signal_search_toolbox
                prev_search_toolbox = getappdata(APP.MAIN,'signal_search_toolbox');
                if isempty(prev_search_toolbox{4})
                    return;
                else
                    prev_threshold = prev_search_toolbox{4};
                    APP.current_threshold_slider.Value = prev_threshold;
                    APP.current_threshold_display.String = num2str(prev_threshold);
                end
            end
            
            % temporary storage
            signal_search_toolbox = cell(1,6);
            signal_search_toolbox{1} = spotInfo;
            [hist_data] = create_distribution_data(IMG,APP_PARAM,spotInfo);
            signal_search_toolbox{2} = hist_data;
            signal_search_toolbox{3} = logical(ones(size(spotInfo.objCoords,1),1));
            signal_search_toolbox{4} = user_threshold;
            signal_search_toolbox{5} = APP_PARAM;
            % signal_search_toolbox{6} = [0, 0; max(hist_data(:,1)), max(hist_data(:,2))];
            signal_search_toolbox{6} = [-1 -1; -1 -1];
            
            setappdata(APP.MAIN,'signal_search_toolbox',signal_search_toolbox);
            
            % histogram call
            signal_histogram_call2(APP);
            
			% writing / updating keyframe description
			str_arr = keyframe_description(APP,2);
			APP.keyframe_information_box.String = str_arr;
            
        case  2
            
            IMG = getappdata(APP.MAIN,'IMG');
            APP_PARAM = getappdata(APP.MAIN,'APP_PARAM');
            
            % redo histogram data, same spotInfo
            signal_search_toolbox = getappdata(APP.MAIN,'signal_search_toolbox');
            spotInfo = signal_search_toolbox{1};
            [hist_data] = create_distribution_data(IMG,APP_PARAM,spotInfo);
            signal_search_toolbox{2} = hist_data;
            signal_search_toolbox{3} = logical(ones(size(spotInfo.objCoords,1),1));
            signal_search_toolbox{5} = APP_PARAM;
            signal_search_toolbox{6} = [-1 -1; -1 -1];
            
            setappdata(APP.MAIN,'signal_search_toolbox',signal_search_toolbox);
            
            % histogram_call
            signal_histogram_call2(APP);
            
            % writing / updating keyframe description
			str_arr = keyframe_description(APP,2);
			APP.keyframe_information_box.String = str_arr;
        
        case 3
            
            signal_search_toolbox = getappdata(APP.MAIN,'signal_search_toolbox');
            hist_data = signal_search_toolbox{2};
            logic_arr = signal_search_toolbox{3};
            
            selected_hist_text = APP.hist_ax_bg.SelectedObject.String;
            max_val = str2num(APP.hist_ax_max_box.String);
            min_val = str2num(APP.hist_ax_min_box.String);
            switch selected_hist_text
                case 'Intensity'
                    tmp_arr = hist_data(:,1) >= min_val;
                    tmp_arr(hist_data(:,1) > max_val) = 0;
                    logic_arr(:,1) = tmp_arr;
                case 'Size'
                    tmp_arr = hist_data(:,2) >= min_val;
                    tmp_arr(hist_data(:,2) > max_val) = 0;
                    logic_arr(:,2) = tmp_arr;
            end
            signal_search_toolbox{3} = logic_arr;
            setappdata(APP.MAIN,'signal_search_toolbox',signal_search_toolbox);
    end
       
    
end

% display component
display_frame_signals = APP.frame_signal_toggle.Value;
signal_search_toolbox = getappdata(APP.MAIN,'signal_search_toolbox');

cla(APP.ax2);

if display_frame_signals
    
    APP.ax2.NextPlot = 'add';
    
    spotInfo = signal_search_toolbox{1,1};
    centroids = spotInfo.objCoords;
    
    hist_incl_arr = signal_search_toolbox{1,3};
    hist_incl_arr = min(hist_incl_arr,[],2);
    assignin('base','hist_incl_arr',hist_incl_arr);
    
    co = getappdata(APP.MAIN,'color_matrix');
    
    % get state of z_slice_slider
    z_slice_slider_state = APP.z_slice_slider.Enable;
    
    if strcmp(z_slice_slider_state,'on') == 1
			
        % z_slice_slider is active, only want spots which show up @ current slice
        curr_z_slice = APP.z_slice_slider.Value;
        
        spotLocs2d = spotInfo.spotLocs2d;
        slice_centroids = spotLocs2d(spotLocs2d(:,3)==curr_z_slice,:);
        % scatter(APP.ax2, slice_centroids(:,1),slice_centroids(:,2),[],co(1,:));
        
        tmp_incl = find(hist_incl_arr);
        tmp_excl = find(~hist_incl_arr);
        
        %
        incl_centroids = spotLocs2d(ismember(spotLocs2d(:,4),tmp_incl),:);
        incl_slice_centroids = incl_centroids(incl_centroids(:,3)==curr_z_slice,:);
        scatter(APP.ax2,incl_slice_centroids(:,1),incl_slice_centroids(:,2),[],co(1,:));

        excl_centroids = spotLocs2d(ismember(spotLocs2d(:,4),tmp_excl),:);
        excl_slice_centroids = excl_centroids(excl_centroids(:,3)==curr_z_slice,:);
        scatter(APP.ax2,excl_slice_centroids(:,1),excl_slice_centroids(:,2),[],'red');
        %}

    else
        
        incl_centroids = centroids(logical(hist_incl_arr),:);
        excl_centroids = centroids(logical(~hist_incl_arr),:);
        
        
        scatter(APP.ax2,incl_centroids(:,1),incl_centroids(:,2),[],co(1,:));
        scatter(APP.ax2,excl_centroids(:,1),excl_centroids(:,2),[],'red');
        
        % show all signals
        % scatter(APP.ax2,centroids(:,1),centroids(:,2),[],co(1,:));

    end
    
end

[err_flag] = backup_ax_check(APP);
if err_flag
    backup_ax_fix(APP, err_flag);
end


%
%%%
%%%%%
%%%
%

function [hist_data] = create_distribution_data(IMG, APP_PARAM, spotInfo)
%% <placeholder>
%

num_pix_off = APP_PARAM.NUM_PIX_OFF;
num_pix_bg = APP_PARAM.NUM_PIX_BG;

Z = IMG.getZ();
curr_frame = IMG.getCurrFrame();
curr_frame = im2double(curr_frame);

SIG_VALS = spotInfo.SIG_VALS;

if isempty(Z)
    Z = 1;
end

if Z==1
    [BG_VALS,~] = two_dim_bg_calc(curr_frame,spotInfo,num_pix_off,num_pix_bg);
else
	[BG_VALS,~] = assign_bg_pixels(curr_frame,spotInfo,num_pix_off,num_pix_bg);
end

curr_sig_setting = APP_PARAM.SIG_MEASURE;
switch curr_sig_setting
    case 'ZCOORD'
        col_idx = 2;
    case 'FULL'
        col_idx = 1;
end

hist_data = zeros(size(SIG_VALS,1),2);
curr_int_setting = APP_PARAM.INT_MEASURE;

switch curr_int_setting
    case 'MEAN'
        for idx=1:length(hist_data)
            hist_data(idx,1) = mean(SIG_VALS{idx,col_idx} - mean(BG_VALS{idx,col_idx}));
        end
    case 'SUM'
        for idx=1:length(hist_data)
            hist_data(idx,1) = sum(SIG_VALS{idx,col_idx} - mean(BG_VALS{idx,col_idx}));
        end
    case 'MEDIAN'
        for idx=1:length(hist_data)
            hist_data(idx,1) = me(SIG_VALS{idx,col_idx} - mean(BG_VALS{idx,col_idx}));
        end
end

hist_data(:,2) = cellfun('length',SIG_VALS(:,col_idx));

%
%%%
%%%%%
%%%
%