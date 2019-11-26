classdef TMP_OVERLAY
    % TMP_OVERLAY class
    
    properties
        spotInfo
        frameNo
        userThreshold
        wavLevel
        overSeg
        zMin
        bgOff = 0;
        bgPix = 0;
        bgCorr = 0;
        sizeArg = 2;
        spotFeatures = [];
        spotFeatureNames = [];
        spotFeatureMax = [];
        spotFeatureMin = [];
        spotFeaturePointer = 1;
        spotDetectFlag = 0;
        spotDetectKFExcl = [];
    end
    
    methods
        
        % constructor
        function obj = TMP_OVERLAY(spotInfo, param_struct)
            obj.spotInfo = spotInfo;
            obj.frameNo = param_struct.FRAME_NO;
            obj.userThreshold = param_struct.USER_THRESH;
            obj.wavLevel = param_struct.WAV_LEVEL;
            obj.overSeg = param_struct.OVERSEG;
            obj.zMin = param_struct.FRAME_LIMIT;
            obj.bgOff = 0;
            obj.bgPix = 0;
            obj.bgCorr = 0;
        end
        
        % TMP_OVERLAY.updateSpotFeatures
        function obj = updateSpotFeatures(obj,bg_off,bg_pix)
            
            obj.bgOff = bg_off;
            obj.bgPix = bg_pix;
            
            if bg_pix
                % full feature suite
                obj.bgCorr = 1;
                [spot_arr, fields] = spotFeat1(obj);
                obj.spotFeatures = spot_arr;
                obj.spotFeatureNames = fields;
                obj.spotFeatureMax = nan(1,size(spot_arr,2));
                obj.spotFeatureMin = zeros(1,size(spot_arr,2));
            else
                % partial feature suite
                obj.bgCorr = 0;
                [spot_arr, fields] = spotFeat2(obj);
                obj.spotFeatures = spot_arr;
                obj.spotFeatureNames = fields;
                obj.spotFeatureMax = nan(1,size(spot_arr,2));
                obj.spotFeatureMin = zeros(1,size(spot_arr,2));
            end
            

            
        end
        
        % TMP_OVERLAY.spotFeat1
        function [spot_arr, fields] = spotFeat1(obj)
            
            bg_off = obj.bgOff;
            bg_pix = obj.bgPix;
            col_idx = obj.sizeArg;
            
            SIG_VALS = obj.spotInfo.SIG_VALS(:,col_idx);
            BG_VALS = obj.spotInfo.BG_VALS(:,col_idx);
            
            [spot_arr] = pull_spot_information(SIG_VALS, BG_VALS);
            fields = {'MEAN','MEDIAN','SUM','SIZE','MAX'};
            
        end
        
        % TMP_OVERLAY.spotFeat2
        function [spot_arr, fields] = spotFeat2(obj)
            
            col_idx = obj.sizeArg;
            SIG_VALS = obj.spotInfo.SIG_VALS(:,col_idx);
            spot_arr = zeros(length(SIG_VALS),5);
            
            fields = {'INT_AVG_RAW','INT_MED_RAW','INT_SUM_RAW','INT_MAX_RAW','SIZE'};
            
            spot_arr(:,1) = cellfun(@mean,SIG_VALS);
            spot_arr(:,2) = cellfun(@median,SIG_VALS);
            spot_arr(:,3) = cellfun(@sum,SIG_VALS);
            spot_arr(:,4) = cellfun(@length,SIG_VALS);
            spot_arr(:,5) = cellfun(@max,SIG_VALS);
            
        end
        
        % TMP_OVERLAY.getFrameCoords
        function [incl_centroids, excl_centroids] = getFrameCoords(obj)
            
            if obj.spotDetectFlag
                
                % curr_mins = obj.spotFeatureMin;
                % curr_maxes = obj.spotFeatureMax;
                
                curr_feat = obj.spotFeaturePointer;
                data_arr = obj.spotFeatures(:,obj.spotFeaturePointer);
                logic_arr = logical(ones(size(obj.spotInfo.objCoords,1),1));
                assignin('base','pre_pre_logic_arr',logic_arr);
                logic_arr(data_arr <= obj.spotFeatureMin(curr_feat)) = 0;
                logic_arr(data_arr > obj.spotFeatureMax(curr_feat)) = 0;
                
                assignin('base','pre_kf_logic_arr',logic_arr);
                
                logic_arr(obj.spotDetectKFExcl) = 0;
                
                assignin('base','post_kf_logic_arr',logic_arr);
                
                %{
                logic_arr = logical(ones(size(obj.spotInfo.objCoords,1),1));
                for i=1:length(curr_mins)
                    data_arr = obj.spotFeatures(:,i);
                    if ~isnan(curr_mins(i)) && ~isnan(curr_maxes(i))
                        logic_arr(data_arr <= curr_mins(i)) = 0;
                        logic_arr(data_arr > curr_maxes(i)) = 0;
                    end
                end
                %}
                
                incl_centroids = obj.spotInfo.objCoords(logic_arr,:);
                excl_centroids = obj.spotInfo.objCoords(~logic_arr,:);
                
            else
                curr_feat = obj.spotFeaturePointer;
                data_arr = obj.spotFeatures(:,obj.spotFeaturePointer);

                logic_arr = logical(ones(size(obj.spotInfo.objCoords,1),1));
                logic_arr(data_arr <= obj.spotFeatureMin(curr_feat)) = 0;
                logic_arr(data_arr > obj.spotFeatureMax(curr_feat)) = 0;

                incl_centroids = obj.spotInfo.objCoords(logic_arr,:);
                excl_centroids = obj.spotInfo.objCoords(~logic_arr,:);
            end
            
        end
        
        % TMP_OVERLAY.getSliceCoords
        function [incl_centroids, excl_centroids] = getSliceCoords(obj, slice_no)
            
            spot_locs_2d = obj.spotInfo.spotLocs2d;
            incl_centroids = spot_locs_2d(spot_locs_2d(:,3)==slice_no,:);
            excl_centroids = [];
            
        end
        
        % TMP_OVERLAY.getLogicalInclusions
        function [incl_arr] = getLogicalInclusions(obj)
            
            if obj.spotDetectFlag
                
                curr_feat = obj.spotFeaturePointer;
                data_arr = obj.spotFeatures(:,obj.spotFeaturePointer);
                logic_arr = logical(ones(size(obj.spotInfo.objCoords,1),1));
                logic_arr(data_arr <= obj.spotFeatureMin(curr_feat)) = 0;
                logic_arr(data_arr > obj.spotFeatureMax(curr_feat)) = 0;
                logic_arr(obj.spotDetectKFExcl) = 0;
                
            else
                
                curr_feat = obj.spotFeaturePointer;
                data_arr = obj.spotFeatures(:,obj.spotFeaturePointer);

                logic_arr = logical(ones(size(obj.spotInfo.objCoords,1),1));
                logic_arr(data_arr <= obj.spotFeatureMin(curr_feat)) = 0;
                logic_arr(data_arr > obj.spotFeatureMax(curr_feat)) = 0;

            end
            
            incl_arr = logic_arr;
            
        end
        
    end
    
end

