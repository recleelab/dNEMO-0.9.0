classdef SPOT_DETECT
    %SPOT_DETECT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        referenceFrames
        waveletLevel
        minFrameAbsolute
        maxFrameAbsolute
        spotInfoArr
        wavLevelArr
        wavThreshArr
        overSegArr
        zMinArr
        bgOffArr
        bgPixArr
        featureFields
        featureMinMaxes
        featureExclusion
        manualExclusion
    end
    
    methods
        % constructor
        function obj = SPOT_DETECT(IMG,OVERLAY)
            
            % reload case
            if nargin==1
                reload_struct = IMG;
                some_fields = obj.getSpotDetectFields();
                for field_idx=1:length(some_fields)
                    obj.(some_fields{field_idx}) = reload_struct.(some_fields{field_idx});
                end
            else
                % image / movie properties
                num_frames = IMG.T;
                num_slices = IMG.Z;
                obj.referenceFrames = OVERLAY.frameNo;
                obj.minFrameAbsolute = 1;
                obj.maxFrameAbsolute = num_frames;

                % wavelet transform properties
                wav_level = OVERLAY.wavLevel;
                obj.wavLevelArr = cat(1,ones(obj.minFrameAbsolute,obj.maxFrameAbsolute).*wav_level,zeros(obj.minFrameAbsolute,obj.maxFrameAbsolute));
                obj.wavLevelArr(2,1) = 1;
                overseg = OVERLAY.overSeg;
                obj.overSegArr = cat(1,ones(obj.minFrameAbsolute,obj.maxFrameAbsolute).*overseg,zeros(obj.minFrameAbsolute,obj.maxFrameAbsolute));
                obj.overSegArr(2,1) = 1;
                wav_thresh = OVERLAY.userThreshold;
                obj.wavThreshArr = cat(1,ones(obj.minFrameAbsolute,obj.maxFrameAbsolute).*wav_thresh,zeros(obj.minFrameAbsolute,obj.maxFrameAbsolute));
                obj.wavThreshArr(2,1) = 1;
                frame_lim = OVERLAY.zMin;
                obj.zMinArr = cat(1,ones(obj.minFrameAbsolute,obj.maxFrameAbsolute).*frame_lim,zeros(obj.minFrameAbsolute,obj.maxFrameAbsolute));
                obj.zMinArr(2,1) = 1;

                % spot info storage
                full_spotInfo = cell([1 num_frames]);
                
                % parallel process handling
                par_flag = 0;
                tmp_ver_struct = ver;
                avail_toolboxes = {tmp_ver_struct.Name}.';
                par_toolbox_present = max(strcmp(avail_toolboxes, 'Parallel Computing Toolbox'));
                if par_toolbox_present
                    if ~isempty(gcp('nocreate'))
                        par_flag = 1;
                    end
                end
                
                frame_ref = zeros(num_frames,1);
                par_marker = 1;

                % waitbar handling
                wbar = waitbar(0,'Wavelet Transform 0% Complete (1 of 2)');

                for i=1:num_frames
                    if i==OVERLAY.frameNo && ~isempty(OVERLAY.spotInfo) && ~par_flag

                        full_spotInfo{i} = OVERLAY.spotInfo;

                        % waitbar handling
                        percent_done = i/num_frames;
                        displayed_percent_done = num2str(round(percent_done*100));
                        percent_done_message = strcat('Wavelet Transform',{' '},displayed_percent_done,'% Complete (1 of 2)');
                        waitbar(percent_done,wbar,percent_done_message);
                        
                        if par_flag
                            par_marker = par_marker+1;
                        end

                    else

                        if num_slices==1

                            IMG = IMG.setCurrFrame(i);
                            curr_frame = im2double(IMG.getCurrFrame());

                            [centroids, lbl, indices] = spot_finder_two_dim(curr_frame, wav_thresh, overseg, wav_level);
                            [spotInfo] = two_dim_sig_calc(curr_frame, centroids, lbl, indices);
                            full_spotInfo{i} = spotInfo;

                            % waitbar handling
                            percent_done = i/num_frames;
                            displayed_percent_done = num2str(round(percent_done*100));
                            percent_done_message = strcat('Wavelet Transform',{' '},displayed_percent_done,'% Complete (1 of 2)');
                            waitbar(percent_done,wbar,percent_done_message);

                        else

                            IMG = IMG.setCurrFrame(i);
                            curr_frame = im2double(IMG.getCurrFrame());
                            
                            if par_flag
                                OUT(i) = parfeval(@spot_finder_three_dim, 1, curr_frame, wav_thresh, frame_lim, overseg, wav_level);
                                frame_ref(par_marker) = i;
                                par_marker = par_marker + 1;
                            else

                                [spotInfo] = spot_finder_three_dim(curr_frame, wav_thresh, frame_lim, overseg, wav_level);
                                full_spotInfo{i} = spotInfo;
                                
                                % waitbar handling
                                percent_done = i/num_frames;
                                displayed_percent_done = num2str(round(percent_done*100));
                                percent_done_message = strcat('Wavelet Transform',{' '},displayed_percent_done,'% Complete (1 of 2)');
                                waitbar(percent_done,wbar,percent_done_message);
                                
                            end



                        end

                    end
                end
                
                if par_flag
                    
                    assignin('base','OUT',OUT);
                    
                    frame_ref(frame_ref==0) = [];
                    mrkr2 = 1;
                    while mrkr2 <= length(frame_ref)
                        [out_idx, spotInfo] = fetchNext(OUT);
                        full_spotInfo{frame_ref(out_idx)} = spotInfo;
                        
                        % waitbar handling
                        percent_done = mrkr2/length(frame_ref);
                        displayed_percent_done = num2str(round(percent_done*100));
                        percent_done_message = strcat('Wavelet Transform',{' '},displayed_percent_done,'% Complete (1 of 2)');
                        waitbar(percent_done,wbar,percent_done_message);
                        
                        mrkr2 = mrkr2+1;
                    end
                end

                % remove waitbar
                delete(wbar);

                % apply background correction (if applicable)
                %obj.zMinArr = cat(1,ones(obj.minFrameAbsolute,obj.maxFrameAbsolute).*frame_lim,zeros(obj.minFrameAbsolute,obj.maxFrameAbsolute));
                % obj.zMinArr(2,OVERLAY.frameNo) = 1;
                bg_off = OVERLAY.bgOff;
                obj.bgOffArr = cat(1,ones(obj.minFrameAbsolute,obj.maxFrameAbsolute).*bg_off,zeros(obj.minFrameAbsolute,obj.maxFrameAbsolute));
                obj.bgOffArr(2,1) = 1;
                bg_pix = OVERLAY.bgPix;
                obj.bgPixArr = cat(1,ones(obj.minFrameAbsolute,obj.maxFrameAbsolute).*bg_pix,zeros(obj.minFrameAbsolute,obj.maxFrameAbsolute));
                obj.bgPixArr(2,1) = 1;

                if bg_pix

                    wbar = waitbar(0,'Applying Background Correction 0% (2 of 2)');
                    for i=1:num_frames

                        tmp_spotInfo = full_spotInfo{i};

                        IMG = IMG.setCurrFrame(i);
                        curr_frame = im2double(IMG.getCurrFrame());
                        if i==OVERLAY.frameNo && ~isempty(OVERLAY.spotInfo) && ~par_flag
                            % do nothing
                            % waitbar handling
                            percent_done = i/num_frames;
                            displayed_percent_done = num2str(round(percent_done*100));
                            percent_done_message = strcat('Applying Background Correction',{' '},displayed_percent_done,'% (2 of 2)');
                            waitbar(percent_done,wbar,percent_done_message);
                        elseif num_slices==1
                            [BG_VALS, ~] = two_dim_bg_calc(curr_frame, tmp_spotInfo, bg_off, bg_pix);
                            % SIG_VALS = tmp_spotInfo.SIG_VALS; 
                            % centroids = tmp_spotInfo.objCoords;
                            tmp_spotInfo.BG_VALS = BG_VALS;
                            percent_done = i/num_frames;
                            displayed_percent_done = num2str(round(percent_done*100));
                            percent_done_message = strcat('Applying Background Correction',{' '},displayed_percent_done,'% (2 of 2)');
                            waitbar(percent_done,wbar,percent_done_message);
                        else
                            [BG_VALS, ~] = assign_bg_pixels(curr_frame, tmp_spotInfo, bg_off, bg_pix);
                            % SIG_VALS = tmp_spotInfo.SIG_VALS;
                            % centroids = tmp_spotInfo.objCoords;
                            tmp_spotInfo.BG_VALS = BG_VALS;
                            percent_done = i/num_frames;
                            displayed_percent_done = num2str(round(percent_done*100));
                            percent_done_message = strcat('Applying Background Correction',{' '},displayed_percent_done,'% (2 of 2)');
                            waitbar(percent_done,wbar,percent_done_message);
                        end

                        full_spotInfo{i} = tmp_spotInfo;

                    end
                    delete(wbar);

                end

                obj.spotInfoArr = full_spotInfo;

                % additional feature setup
                obj.featureMinMaxes = NaN(3,obj.maxFrameAbsolute,5);
                tmp_feature_excl = cell(obj.minFrameAbsolute,obj.maxFrameAbsolute);
                for frame_idx=1:obj.maxFrameAbsolute
                    tmp_feature_excl{frame_idx} = logical(zeros(size(full_spotInfo{frame_idx}.objCoords,1),1));
                end
                obj.featureExclusion = tmp_feature_excl;
                obj.manualExclusion = tmp_feature_excl;


            end
        end
        
        % secondary construct -- reload
        
        % SPOT_DETECT.getKeyframeDescriptions
        function [string_arr] = getKeyframeDescriptions(obj)
            
            string_arr = {};
            lv_str = obj.getArrInfoStrings(obj.wavLevelArr, 'wavelet_level_set_to_L');
            % wav_level = obj.wavLevelArr(1,1);
            % tmp_str = strcat('_L',num2str(wav_level));
            % lv_str = strcat(lv_str,tmp_str);
            string_arr = cat(1,string_arr,lv_str);
            thresh_str = obj.getArrInfoStrings(obj.wavThreshArr, 'user_wavelet_threshold_set_to_');
            string_arr = cat(1,string_arr,thresh_str);
            overseg_str = obj.getArrInfoStrings(obj.overSegArr, 'spot_oversegmentation_check_set_to_');
            string_arr = cat(1,string_arr,overseg_str);
            zmin_str = obj.getArrInfoStrings(obj.zMinArr, 'spot_axial_minimum_set_to_');
            string_arr = cat(1,string_arr,zmin_str);
            % bgoff_str = obj.getArrInfoStrings(obj.bgOffArr, 'bg_off_defined');
            % string_arr = cat(1,string_arr,bgoff_str);
            % bgpix_str = obj.getArrInfoStrings(obj.bgPixArr, 'bg_pix_defined');
            % string_arr = cat(1,string_arr,bgpix_str);
            
        end
        
        % SPOT_DETECT.getParamDescriptions
        function [string_arr] = getParamDescriptions(obj)
            string_arr = {};
            bgoff_str = obj.getArrInfoStrings(obj.bgOffArr, 'background_offset_radius_set_to_');
            string_arr = cat(1,string_arr,bgoff_str);
            bgpix_str = obj.getArrInfoStrings(obj.bgPixArr,'background_pixel_radius_set_to_');
            string_arr = cat(1,string_arr,bgpix_str);
        end
        
        % SPOT_DETECT.getArrInfoStrings
        function [string_arr] = getArrInfoStrings(obj, object_arr, des_string)
            string_arr = {};
            frame_locs = find(object_arr(2,:));
            for i=1:length(frame_locs)
                
                next_str = strcat('    >Frame',num2str(frame_locs(i)),'_',des_string,num2str(object_arr(1,frame_locs(i))));
                string_arr = cat(1,string_arr,next_str);

            end
        end
        
        % SPOT_DETECT.getOverlayParam
        function [overlay_param] = getOverlayParam(obj, frame_no)
            overlay_param = struct;
            overlay_param.FRAME_NO = frame_no;
            overlay_param.USER_THRESH = obj.wavThreshArr(1,frame_no);
            overlay_param.OVERSEG = obj.overSegArr(1,frame_no);
            overlay_param.FRAME_LIMIT = obj.zMinArr(1,frame_no);
            overlay_param.WAV_LEVEL = obj.wavLevelArr(1,frame_no);
            overlay_param.BG_OFF = obj.bgOffArr(1,frame_no);
            overlay_param.BG_PIX = obj.bgPixArr(1,frame_no);
        end
        
        % SPOT_DETECT.addFeatureSelection
        function obj = addFeatureSelection(obj, OVERLAY)
            
            tmp_pointer = OVERLAY.spotFeaturePointer;
            if isempty(obj.featureFields)
                obj.featureFields = OVERLAY.spotFeatureNames;
            end
            
            curr_min = OVERLAY.spotFeatureMin(tmp_pointer);
            curr_max = OVERLAY.spotFeatureMax(tmp_pointer);
            
            curr_frame = OVERLAY.frameNo;
            
            if any(any(~isnan(obj.featureMinMaxes(1:2,:,tmp_pointer))))
                disp('prev_kf_detected');
                % something's been previously assigned
                curr_feat = obj.featureMinMaxes(:,:,tmp_pointer);
                curr_feat(1:2,curr_frame) = [curr_min; curr_max];
                curr_feat(3,curr_frame) = 1;
                if curr_frame < size(curr_feat,2)
                    next_kf_found = 0;
                    for feat_idx=curr_frame+1:size(curr_feat,2)
                        if curr_feat(3,feat_idx)==1
                            next_kf_found = 1;
                            disp('reassigning while flag');
                            disp('feat idx ==');
                            disp(feat_idx);
                        end
                        if isnan(curr_feat(3,feat_idx)) && ~next_kf_found
                            curr_feat(1:2,feat_idx) = [curr_min; curr_max];
                            disp('overwriting feature limits');
                            disp('feat idx ==');
                            disp(feat_idx);
                        end
                    end
                end
                obj.featureMinMaxes(:,:,tmp_pointer) = curr_feat; 
            else
                disp('did not find prev entries');
                obj.featureMinMaxes(1,OVERLAY.frameNo:end,tmp_pointer) = curr_min;
                obj.featureMinMaxes(2,OVERLAY.frameNo:end,tmp_pointer) = curr_max;
                obj.featureMinMaxes(3,OVERLAY.frameNo,tmp_pointer) = 1;
            end
            
            obj = obj.updateFeatureExclusion();
            
        end
        
        % SPOT_DETECT.updateFeatureExclusion
        function obj = updateFeatureExclusion(obj)
            
            curr_min_maxes = obj.featureMinMaxes;
            full_spotInfo = obj.spotInfoArr;
            curr_feature_exclusion = obj.featureExclusion;
            
            for frame_idx=1:length(curr_feature_exclusion)
                tmp_feature_excl = zeros(size(full_spotInfo{frame_idx}.objCoords,1),1);
                if any(any(all(~isnan(curr_min_maxes))))==0
                    curr_feature_exclusion{frame_idx} = logical(tmp_feature_excl);
                else
                    for ii=1:size(curr_min_maxes,3)
                        if any(any(all(~isnan(curr_min_maxes(:,:,ii)))))
                            [logically_excluded] = getFeatureExclusions(obj, curr_min_maxes(:,:,ii),ii,frame_idx);
                            tmp_feature_excl(logically_excluded) = 1;
                        end
                    end
                    curr_feature_exclusion{frame_idx} = logical(tmp_feature_excl);
                end
            end
            
            obj.featureExclusion = curr_feature_exclusion;
            
            %{
            for frame_idx=1:length(curr_feature_exclusion)
                for ii=1:size(curr_min_maxes,3)
                    if ~isnan(curr_min_maxes(1,1,ii))
                        [logically_excluded] = getFeatureExclusions(obj,curr_min_maxes(:,:,ii),ii);
                        assignin('base','returned_from_getFeatureExclusions',logically_excluded);
                        curr_excl = curr_feature_exclusion{frame_idx};
                        curr_excl(logically_excluded) = 1;
                        curr_feature_exclusion{frame_idx} = logical(curr_excl);
                    end
                end
            end
            
            if all(isnan(curr_min_maxes))
                full_spotInfo = obj.spotInfoArr;
                for frame_idx=1:length(curr_feature_exclusion)
                    for frame_idx=1:obj.maxFrameAbsolute
                        tmp_feature_excl{frame_idx} = logical(zeros(size(full_spotInfo{frame_idx}.objCoords,1),1));
                    end
                    curr_feature_exclusion = tmp_feature_excl;
                end
            end
            %}
            

            
        end
        
        % SPOT_DETECT.pullFeatureExclLogicArr
        function logic_arr = pullFeatureExclLogicArr(obj, frame_no)
            logic_arr = obj.featureExclusion{frame_no};
        end
        
        % SPOT_DETECT.removeFeatureSelection
        function obj = removeFeatureSelection(obj, keyframing_string)
            
            % figure out which one we're dealing with
            if contains(keyframing_string,'MEAN')
                tmp_pointer = 1;
            elseif contains(keyframing_string,'MEDIAN')
                tmp_pointer = 2;
            elseif contains(keyframing_string,'SUM')
                tmp_pointer = 3;
            elseif contains(keyframing_string,'SIZE')
                tmp_pointer = 4;
            elseif contains(keyframing_string,'MAX')
                tmp_pointer = 5;
            else
                tmp_pointer = 0;
            end
            
            str_tokens = strsplit(keyframing_string,'_');
            frame_string = str_tokens{1};
            some_str_loc = strfind(frame_string,'>');
            sub_str = frame_string(some_str_loc+6:end);
            frame_no = str2num(char(sub_str));
            
            curr_min_max = obj.featureMinMaxes(:,:,tmp_pointer);
            curr_min_max(3, frame_no) = NaN;
            
            prev_kf = find(~isnan(curr_min_max(3,1:frame_no)));
            next_kf = find(~isnan(curr_min_max(3,frame_no+1:end)));
            end_frame = frame_no;
            if isempty(next_kf)
                curr_min_max(:,frame_no:end) = NaN;
                end_frame = size(curr_min_max,2)+1;
            else
                curr_min_max(:,frame_no:frame_no+next_kf-1) = NaN;
                end_frame = frame_no+next_kf;
            end
            
            if isempty(prev_kf)
                curr_min_max(:,1:frame_no) = NaN;
                obj.featureMinMaxes(:,:,tmp_pointer) = curr_min_max;
            else
                nearest_kf = prev_kf(end);
                curr_min_max(1:2,nearest_kf:end_frame-1) = curr_min_max(1:2,nearest_kf);
                obj.featureMinMaxes(:,:,tmp_pointer) = curr_min_max;
            end
            
            obj = obj.updateFeatureExclusion();
            
        end
        
        % SPOT_DETECT.getFeatureExclusions
        function logic_arr = getFeatureExclusions(obj, min_max_arr, feat_pointer, frame_idx)
            
            spotInfo = obj.spotInfoArr{frame_idx};
            tmp_min = min_max_arr(1,frame_idx);
            tmp_max = min_max_arr(2,frame_idx);
            
            if isnan(tmp_min) && isnan(tmp_max)
                logic_arr = logical(zeros(size(spotInfo.objCoords,1),1));
            else
                SIG_VALS = spotInfo.SIG_VALS(:,2);
                BG_VALS = spotInfo.BG_VALS(:,2);
                avg_background = cellfun(@mean, BG_VALS);
                for tmp_idx=1:length(SIG_VALS)
                    SIG_VALS{tmp_idx} = SIG_VALS{tmp_idx} - avg_background(tmp_idx);
                end
                
                tmp_arr = zeros(size(spotInfo.objCoords,1),1);
                switch feat_pointer
                    case 1
                        %AVG
                        val_arr = cellfun(@mean,SIG_VALS);
                    case 2
                        %MED
                        val_arr = cellfun(@median,SIG_VALS);
                    case 3
                        %SUM
                        val_arr = cellfun(@sum,SIG_VALS);
                    case 4
                        %SIZE
                        val_arr = cellfun(@length,SIG_VALS);
                    case 5
                        %MAX
                        val_arr = cellfun(@max, SIG_VALS);
                        
                end
                
                tmp_arr(val_arr > tmp_max) = 1;
                tmp_arr(val_arr <= tmp_min) = 1;
                logic_arr = logical(tmp_arr);
            end
            
            %{
            for jj=1:size(min_max_arr,2)
                
                spotInfo = obj.spotInfoArr{jj};
                
                tmp_min = min_max_arr(1,jj);
                tmp_max = min_max_arr(2,jj);
                
                SIG_VALS = spotInfo.SIG_VALS(:,2);
                BG_VALS = spotInfo.BG_VALS(:,2);
                avg_background = cellfun(@mean, BG_VALS);
                for tmp_idx=1:length(SIG_VALS)
                    SIG_VALS{tmp_idx} = SIG_VALS{tmp_idx} - avg_background(tmp_idx);
                end
                
                tmp_arr = zeros(size(spotInfo.objCoords,1),1);
                
                % fields = {'MEAN','MEDIAN','SUM','SIZE','MAX'};
                switch feat_pointer
                    case 1
                        %AVG
                        val_arr = cellfun(@mean,SIG_VALS);
                    case 2
                        %MED
                        val_arr = cellfun(@median,SIG_VALS);
                    case 3
                        %SUM
                        val_arr = cellfun(@sum,SIG_VALS);
                    case 4
                        %SIZE
                        val_arr = cellfun(@length,SIG_VALS);
                    case 5
                        %MAX
                        val_arr = cellfun(@max, SIG_VALS);
                        
                end
                
                tmp_arr(val_arr > tmp_max) = 1;
                tmp_arr(val_arr <= tmp_min) = 1;
                logic_arr = logical(tmp_arr);
                
            end
            %}
            
        end
        
        % SPOT_DETECT.pullFeatureKeyframeStrings
        function [string_arr] = pullFeatureKeyframeStrings(obj)
            
            % looking specifically for features
            feature_frames = [];
            feature_strs = {};
            
            curr_min_maxes = obj.featureMinMaxes;
            curr_fields = obj.featureFields;
            
            for i=1:size(curr_min_maxes,3)
                tmp_arr = curr_min_maxes(:,:,i);
                tmp_des = curr_fields{i};
                frames = find(tmp_arr(3,:)==1);
                if ~isempty(frames)
                    for j=1:length(frames)
                        if frames(j)
                            feature_frames = cat(1,feature_frames,frames(j));
                            tmp_range = strcat('_[',num2str(tmp_arr(1,frames(j))),',',num2str(tmp_arr(2,frames(j))),']');
                            next_str = strcat('    >Frame',num2str(frames(j)),'_feature_sel_',tmp_des,tmp_range);
                            feature_strs = cat(1,feature_strs,next_str);
                        end
                    end
                end
            end
            
            % addendum - get manual exclusions
            manual_frames = obj.getExclusionFrames();
            if ~isempty(manual_frames)
                feature_frames = cat(1,feature_frames,manual_frames.');
                for ii=1:length(manual_frames)
                    new_string = strcat('    >Frame',num2str(manual_frames(ii)),'_manual_exclusion_set');
                    feature_strs = cat(1,feature_strs,new_string);
                end
            end
            
            [~, sorted_order] = sort(feature_frames);
            string_arr = feature_strs(sorted_order);
            
            
        end
        
        % SPOT_DETECT.checkWavChange
        function flag = checkWavChange(obj, overlay)
            
            flag = 0;
            start_frame = overlay.frameNo;
            
            % check to see if wavelet level changing over
            input_wav_level = overlay.wavLevel;
            curr_wav_arr = obj.wavLevelArr;
            if curr_wav_arr(1,start_frame) ~= input_wav_level
                flag = 1;
            end
            
            % check to see if threshold's changed
            input_wav_thresh = overlay.userThreshold;
            curr_thresh_arr = obj.wavThreshArr;
            if curr_thresh_arr(1,start_frame) ~= input_wav_thresh
                flag = 1;
            end
            
            % check to see if oversegmentation's changed
            input_overseg = overlay.overSeg;
            curr_overseg_arr = obj.overSegArr;
            if curr_overseg_arr(1,start_frame) ~= input_overseg
                flag = 1;
            end
            
            % check to see if axial limits have changed
            input_zmin = overlay.zMin;
            curr_zmin_arr = obj.zMinArr;
            if curr_zmin_arr(1,start_frame) ~= input_zmin
                flag = 1;
            end
            
        end
        
        % SPOT_DETECT.modifyWavData
        function obj = modifyWavData(obj, IMG, OVERLAY)
            
            start_frame = OVERLAY.frameNo;
            input_wav_level = OVERLAY.wavLevel;
            input_wav_thresh = OVERLAY.userThreshold;
            input_overseg = OVERLAY.overSeg;
            input_zmin = OVERLAY.zMin;
            
            max_frame = start_frame;
            
            % populate appropriate keyframing arrays
            curr_wav_arr = obj.wavLevelArr;
            if curr_wav_arr(1,start_frame) ~= input_wav_level
                
                next_kf = find(curr_wav_arr(2,start_frame:end));
                if isempty(next_kf)
                    next_kf = size(curr_wav_arr,2)+1;
                end
                
                curr_wav_arr(1,start_frame:next_kf(1)-1) = input_wav_level;
                curr_wav_arr(2,start_frame) = 1;
                if next_kf(1)-1 > max_frame
                    max_frame = next_kf(1)-1;
                end
            end
            obj.wavLevelArr = curr_wav_arr;
            
            curr_thresh_arr = obj.wavThreshArr;
            if curr_thresh_arr(1,start_frame) ~= input_wav_thresh
                next_kf = find(curr_thresh_arr(2,start_frame:end));
                if isempty(next_kf)
                    next_kf = size(curr_thresh_arr,2)+1;
                end
                
                curr_thresh_arr(1,start_frame:next_kf(1)-1) = input_wav_thresh;
                curr_thresh_arr(2,start_frame) = 1;
                if next_kf(1)-1 > max_frame
                    max_frame = next_kf(1)-1;
                end
            end
            obj.wavThreshArr = curr_thresh_arr;
            
            curr_overseg_arr = obj.overSegArr;
            if curr_overseg_arr(1,start_frame) ~= input_overseg
                next_kf = find(curr_overseg_arr(2,start_frame:end));
                if isempty(next_kf)
                    next_kf = size(curr_overseg_arr,2)+1;
                end
                
                curr_overseg_arr(1,start_frame:next_kf(1)-1) = input_overseg;
                curr_overseg_arr(2,start_frame) = 1;
                if next_kf(1)-1 > max_frame
                    max_frame = next_kf(1)-1;
                end
            end
            obj.overSegArr = curr_overseg_arr;
            
            curr_zmin_arr = obj.zMinArr;
            if curr_zmin_arr(1,start_frame) ~= input_zmin
                next_kf = find(curr_zmin_arr(2,start_frame:end));
                if isempty(next_kf)
                    next_kf = size(curr_zmin_arr,2)+1;
                end
                
                curr_zmin_arr(1,start_frame:next_kf(1)-1) = input_zmin;
                curr_zmin_arr(2,start_frame) = 1;
                if next_kf(1)-1 > max_frame
                    max_frame = next_kf(1)-1;
                end
            end
            obj.zMinArr = curr_zmin_arr;
           
            frame_range = [start_frame, max_frame];
            
            obj = obj.updateSpotInfo(IMG, OVERLAY, frame_range);
            
        end
        
        % SPOT_DETECT.updateSpotInfo
        function obj = updateSpotInfo(obj, IMG, OVERLAY, frame_range)
            
            num_slices = IMG.Z;
            
            frames = frame_range(1):frame_range(2);
            
            wbar = waitbar(0,'Wavelet Transform 0% Complete (1 of 2)');
            for i=1:length(frames)
                
                curr_frame_no = frames(i);
                wav_level = obj.wavLevelArr(1,curr_frame_no);
                wav_thresh = obj.wavThreshArr(1,curr_frame_no);
                overseg = obj.overSegArr(1,curr_frame_no);
                frame_lim = obj.zMinArr(1,curr_frame_no);
                
                if curr_frame_no==OVERLAY.frameNo
                    
                    obj.spotInfoArr{curr_frame_no} = OVERLAY.spotInfo;
                    
                    % waitbar handling
                    percent_done = i/length(frames);
                    displayed_percent_done = num2str(round(percent_done*100));
                    percent_done_message = strcat('Wavelet Transform',{' '},displayed_percent_done,'% Complete (1 of 2)');
                    waitbar(percent_done,wbar,percent_done_message);
                    
                else
                    
                    if num_slices==1
                        
                        IMG = IMG.setCurrFrame(curr_frame_no);
                        curr_frame = im2double(IMG.getCurrFrame());
                        
                        [centroids, lbl, indices] = spot_finder_two_dim(curr_frame, wav_thresh, overseg, wav_level);
                        [spotInfo] = two_dim_sig_calc(curr_frame, centroids, lbl, indices);
                        obj.spotInfoArr{curr_frame_no} = spotInfo;
                        
                        % waitbar handling
                        percent_done = i/length(frames);
                        displayed_percent_done = num2str(round(percent_done*100));
                        percent_done_message = strcat('Wavelet Transform',{' '},displayed_percent_done,'% Complete (1 of 2)');
                        waitbar(percent_done,wbar,percent_done_message);
                        
                    else
                        
                        IMG = IMG.setCurrFrame(curr_frame_no);
                        curr_frame = im2double(IMG.getCurrFrame());
                        
                        [spotInfo] = spot_finder_three_dim(curr_frame, wav_thresh, frame_lim, overseg, wav_level);
                        obj.spotInfoArr{curr_frame_no} = spotInfo;
                        
                        % waitbar handling
                        percent_done = i/length(frames);
                        displayed_percent_done = num2str(round(percent_done*100));
                        percent_done_message = strcat('Wavelet Transform',{' '},displayed_percent_done,'% Complete (1 of 2)');
                        waitbar(percent_done,wbar,percent_done_message);
                        
                    end
                    
                end
            end
            
            % remove waitbar
            delete(wbar);
            
        end
        
        % SPOT_DETECT.modifyBGData
        function obj = modifyBGData(obj, IMG, OVERLAY)
            
            start_frame = OVERLAY.frameNo;
            bg_off = OVERLAY.bgOff;
            bg_pix = OVERLAY.bgPix;
            
            curr_off_arr = obj.bgOffArr;
            curr_pix_arr = obj.bgPixArr;
            
            max_frame = start_frame;
            
            bg_flag = 0;
            
            if curr_off_arr(1,start_frame) ~= bg_off
                next_kf = find(curr_off_arr(2,start_frame:end));
                if isempty(next_kf)
                    next_kf = size(curr_off_arr,2)+1;
                end
                
                curr_off_arr(1,start_frame:next_kf(1)-1) = bg_off;
                curr_off_arr(2,start_frame) = 1;
                if next_kf(1)-1 > max_frame
                    max_frame = next_kf(1)-1;
                end
                bg_flag = 1;
            end
            obj.bgOffArr = curr_off_arr;
            
            if curr_pix_arr(1,start_frame) ~= bg_pix
                next_kf = find(curr_pix_arr(2,start_frame:end));
                if isempty(next_kf)
                    next_kf = size(curr_pix_arr,2)+1;
                end
                
                curr_pix_arr(1,start_frame:next_kf(1)-1) = bg_pix;
                curr_pix_arr(2,start_frame) = 1;
                if next_kf(1)-1 > max_frame
                    max_frame = next_kf(1)-1;
                end
                bg_flag = 1;
            end
            obj.bgPixArr = curr_pix_arr;
            
            frame_range = [start_frame, max_frame];
            if bg_flag == 0
                frame_range = [start_frame, size(curr_pix_arr,2)];
            end
            
            obj = obj.updateBGInfo(IMG, OVERLAY, frame_range);
            
        end
        
        % SPOT_DETECT.updateBGInfo
        function obj = updateBGInfo(obj, IMG, OVERLAY, frame_range)
            
            num_slices = IMG.Z;
            
            frames = frame_range(1):frame_range(2);
            
            bg_pix = obj.bgPixArr(1,frame_range(1));
            
            if bg_pix
                
                wbar = waitbar(0,'Applying Background Correction 0% (2 of 2)');
                for i=1:length(frames)
                    
                    curr_frame_no = frames(i);
                    bg_off = obj.bgOffArr(1,curr_frame_no);
                    bg_pix = obj.bgPixArr(1,curr_frame_no);
                    
                    tmp_spotInfo = obj.spotInfoArr{curr_frame_no};
                    
                    IMG = IMG.setCurrFrame(curr_frame_no);
                    curr_frame = im2double(IMG.getCurrFrame());
                    if i==OVERLAY.frameNo
                        % do nothing
                        % waitbar handling
                        percent_done = i/length(frames);
                        displayed_percent_done = num2str(round(percent_done*100));
                        percent_done_message = strcat('Applying Background Correction',{' '},displayed_percent_done,'% (2 of 2)');
                        waitbar(percent_done,wbar,percent_done_message);
                    elseif num_slices==1
                        [BG_VALS, ~] = two_dim_bg_calc(curr_frame, tmp_spotInfo, bg_off, bg_pix);
                        % SIG_VALS = tmp_spotInfo.SIG_VALS; 
                        % centroids = tmp_spotInfo.objCoords;
                        tmp_spotInfo.BG_VALS = BG_VALS;
                        percent_done = i/length(frames);
                        displayed_percent_done = num2str(round(percent_done*100));
                        percent_done_message = strcat('Applying Background Correction',{' '},displayed_percent_done,'% (2 of 2)');
                        waitbar(percent_done,wbar,percent_done_message);
                    else
                        [BG_VALS, ~] = assign_bg_pixels(curr_frame, tmp_spotInfo, bg_off, bg_pix);
                        % SIG_VALS = tmp_spotInfo.SIG_VALS;
                        % centroids = tmp_spotInfo.objCoords;
                        tmp_spotInfo.BG_VALS = BG_VALS;
                        percent_done = i/length(frames);
                        displayed_percent_done = num2str(round(percent_done*100));
                        percent_done_message = strcat('Applying Background Correction',{' '},displayed_percent_done,'% (2 of 2)');
                        waitbar(percent_done,wbar,percent_done_message);
                    end
                    
                    obj.spotInfoArr{curr_frame_no} = tmp_spotInfo;
                    
                end
                delete(wbar);
                
            end
        end
        
        % SPOT_DETECT.removeBGParam
        function obj = removeBGParam(obj, keyframing_string, IMG)
            
            if contains(keyframing_string,'offset')
                curr_bg_arr = obj.bgOffArr;
                assignment_field = 'bgOffArr';
            else
                curr_bg_arr = obj.bgPixArr;
                assignment_field = 'bgPixArr';
            end
            
            str_tokens = strsplit(keyframing_string,'_');
            frame_string = str_tokens{1};
            some_str_loc = strfind(frame_string,'>');
            sub_str = frame_string(some_str_loc+6:end);
            frame_no = str2num(char(sub_str));
            
            curr_bg_arr(2,frame_no) = 0;
            
            prev_kf = find(curr_bg_arr(2,1:frame_no));
            next_kf = find(curr_bg_arr(2,frame_no+1:end));
            end_frame = frame_no;
            
            if isempty(prev_kf) && isempty(next_kf)
                % no other keyframe data -- 
                curr_bg_arr(1,:) = 0;
                curr_bg_arr(2,1) = 1;
                
                frame_range = [1 size(curr_bg_arr,2)];
                
            else
                if isempty(next_kf)
                    curr_bg_arr(1,frame_no:end) = 0;
                    end_frame = size(curr_bg_arr,2)+1;
                else
                    curr_bg_arr(1,frame_no:frame_no+next_kf-1) = 0;
                    end_frame = frame_no+next_kf;
                end

                if isempty(prev_kf)
                    curr_bg_arr(1,1:frame_no) = 0;
                    frame_no = 1;
                    frame_range = [1 end_frame-1];
                else
                    nearest_kf = prev_kf(end);
                    curr_bg_arr(1,nearest_kf:end_frame-1) = curr_bg_arr(1,nearest_kf);
                    frame_range = [nearest_kf end_frame-1];
                end
            end
            
            tmp_overlay = struct;
            tmp_overlay.frameNo = 0;
            
            obj.(assignment_field) = curr_bg_arr;
            
            obj = obj.updateBGInfo(IMG, tmp_overlay, frame_range);
            
            
            
        end
        
        % SPOT_DETECT.checkRemovalProp
        function [flag, des] = checkRemovalProp(obj, keyframing_string)
            
            % get frame no first
            some_tokens = strsplit(keyframing_string,'_');
            frame_string = some_tokens{1};
            some_loc = strfind(frame_string,'>');
            frame_no = str2num(frame_string(some_loc+6:end));
            
            flag = 0;
            
            if contains(keyframing_string,'wavelet_level')
                des = 'WAVLEVEL';
                tmp_arr = obj.wavLevelArr;
            end
            
            if contains(keyframing_string,'wavelet_threshold')
                des = 'WAVTHRESH';
                tmp_arr = obj.wavThreshArr;
            end
            
            if contains(keyframing_string,'oversegmentation')
                des = 'OVERSEG';
                tmp_arr = obj.overSegArr;
            end
            
            if contains(keyframing_string,'axial_minimum')
                des = 'ZMIN';
                tmp_arr = obj.zMinArr;
            end
            
            tmp_arr(2,frame_no) = 0;
            if isempty(find(tmp_arr(2,:),1))
                flag = 1;
            end
        end
        
        % SPOT_DETECT.removeSpotParam
        function obj = removeSpotParam(obj, removal_des, IMG, keyframing_string)
            
            % get frame no first
            some_tokens = strsplit(keyframing_string,'_');
            frame_string = some_tokens{1};
            some_loc = strfind(frame_string,'>');
            frame_no = str2num(frame_string(some_loc+6:end));
            
            % first update object keyframing array
            switch removal_des
                case 'WAVLEVEL'
                    tmp_arr = obj.wavLevelArr;
                    tmp_arr(2,frame_no) = 0;
                    prev_val = tmp_arr(1,frame_no);
                    previous_frames = find(tmp_arr(1,:)==prev_val);
                    frame_end = previous_frames(end);
                    next_locs = find(tmp_arr(2,:));
                    if length(next_locs)==1
                        tmp_arr(1,:) = tmp_arr(1,next_locs);
                        tmp_arr(2,1) = 1;
                        tmp_arr(2,next_locs) = 0;
                    elseif next_locs(1) > frame_no
                        tmp_arr(1,1:next_locs(2)) = tmp_arr(1,next_locs(1));
                        tmp_arr(2,1) = 1;
                        tmp_arr(2,next_locs(1)) = 0;
                    else
                        true_loc = find(next_locs < frame_no);
                        tmp_arr(1,next_locs(true_loc(end)):frame_no) = tmp_arr(1,next_locs(1));
                    end
                    obj.wavLevelArr = tmp_arr;
                case 'WAVTHRESH'
                    tmp_arr = obj.wavThreshArr;
                    tmp_arr(2,frame_no) = 0;
                    prev_val = tmp_arr(1,frame_no);
                    previous_frames = find(tmp_arr(1,:)==prev_val);
                    frame_end = previous_frames(end);
                    next_locs = find(tmp_arr(2,:));
                    if length(next_locs)==1
                        tmp_arr(1,:) = tmp_arr(1,next_locs);
                        tmp_arr(2,1) = 1;
                        tmp_arr(2,next_locs) = 0;
                    elseif next_locs(1) > frame_no
                        tmp_arr(1,1:next_locs(2)) = tmp_arr(1,next_locs(1));
                        tmp_arr(2,1) = 1;
                        tmp_arr(2,next_locs(1)) = 0;
                    else
                        true_loc = find(next_locs < frame_no);
                        tmp_arr(1,next_locs(true_loc(end)):frame_no) = tmp_arr(1,next_locs(1));
                    end
                    obj.wavThreshArr = tmp_arr;
                case 'OVERSEG'
                    tmp_arr = obj.overSegArr;
                    tmp_arr(2,frame_no) = 0;
                    prev_val = tmp_arr(1,frame_no);
                    previous_frames = find(tmp_arr(1,:)==prev_val);
                    frame_end = previous_frames(end);
                    next_locs = find(tmp_arr(2,:));
                    if length(next_locs)==1
                        tmp_arr(1,:) = tmp_arr(1,next_locs);
                        tmp_arr(2,1) = 1;
                        tmp_arr(2,next_locs) = 0;
                    elseif next_locs(1) > frame_no
                        tmp_arr(1,1:next_locs(2)) = tmp_arr(1,next_locs(1));
                        tmp_arr(2,1) = 1;
                        tmp_arr(2,next_locs(1)) = 0;
                    else
                        true_loc = find(next_locs < frame_no);
                        tmp_arr(1,next_locs(true_loc(end)):frame_no) = tmp_arr(1,next_locs(1));
                    end
                    obj.overSegArr = tmp_arr;
                case 'ZMIN'
                    tmp_arr = obj.zMinArr;
                    tmp_arr(2,frame_no) = 0;
                    prev_val = tmp_arr(1,frame_no);
                    previous_frames = find(tmp_arr(1,:)==prev_val);
                    frame_end = previous_frames(end);
                    next_locs = find(tmp_arr(2,:));
                    if length(next_locs)==1
                        tmp_arr(1,:) = tmp_arr(1,next_locs);
                        tmp_arr(2,1) = 1;
                        tmp_arr(2,next_locs) = 0;
                    elseif next_locs(1) > frame_no
                        tmp_arr(1,1:next_locs(2)) = tmp_arr(1,next_locs(1));
                        tmp_arr(2,1) = 1;
                        tmp_arr(2,next_locs(1)) = 0;
                    else
                        true_loc = find(next_locs < frame_no);
                        tmp_arr(1,next_locs(true_loc(end)):frame_no) = tmp_arr(1,next_locs(1));
                    end
                    obj.zMinArr = tmp_arr;
            end
            
            frame_range = [frame_no frame_end];
            fake_overlay = struct;
            fake_overlay.frameNo = 0;
            
            obj = obj.updateSpotInfo(IMG, fake_overlay, frame_range);
            obj = obj.updateBGInfo(IMG, fake_overlay, frame_range);
            
        end
        
        % obj.getManualExclusions
        function [logic_arr] = getManualExclusions(obj, frame_no)
            logic_arr = obj.manualExclusion{frame_no};
        end
        
        % obj.removeManualExclusion
        function obj = removeManualExclusion(obj, keyframing_string)
            % get frame no first
            some_tokens = strsplit(keyframing_string,'_');
            frame_string = some_tokens{1};
            some_loc = strfind(frame_string,'>');
            frame_no = str2num(frame_string(some_loc+6:end));
            
            obj.manualExclusion{frame_no} = logical(zeros(size(obj.spotInfoArr{frame_no}.objCoords,1),1));
            
            
        end
        
        % obj.getExclusionLogicArray
        function [logic_arr] = getExclusionLogicArray(obj, frame_no)
            
            % feature exclusions
            [logic_arr] = obj.pullFeatureExclLogicArr(frame_no);
            
            % manual exclusions
            man_excl = obj.getManualExclusions(frame_no);
            logic_arr(man_excl) = 1;
        end
        
        % obj.getExclusionFrames
        function frames = getExclusionFrames(obj)
            frames = [];
            for ii=1:length(obj.manualExclusion)
                if any(obj.manualExclusion{ii})
                    frames = cat(2,frames,ii);
                end
            end
        end
        
        % obj.getSpotDetectFields
        function [cell_arr] = getSpotDetectFields(obj)
            cell_arr = {'minFrameAbsolute';'maxFrameAbsolute';'spotInfoArr';...
                'wavLevelArr';'wavThreshArr';'overSegArr';'zMinArr';...
                'bgOffArr';'bgPixArr';'featureFields';'featureMinMaxes';...
                'featureExclusion';'manualExclusion'};
        end

    end
end

