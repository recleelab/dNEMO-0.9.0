classdef TMP_CELL
    %TMP_CELL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        polygons
        pseudoAdjMatrix
        minFrame = 1;
        maxFrame
    end
    
    methods
        % constructor
        function obj = TMP_CELL(starting_poly, max_frames, frame_no)
            
            polygon_path = cell(1, max_frames);
            for i=1:size(polygon_path, 2)
                polygon_path{i} = starting_poly;
            end
            
            obj.polygons = polygon_path;
            obj.maxFrame = max_frames;
            
            pseudo_adj_mat = zeros(2,max_frames);
            if frame_no==1
                pseudo_adj_mat(1,1:end) = 1;
            else
                pseudo_adj_mat(1,1:frame_no-1) = 1;
                pseudo_adj_mat(1,frame_no:end) = 2;
            end
            pseudo_adj_mat(2,frame_no) = 1;
            obj.pseudoAdjMatrix = pseudo_adj_mat;
        end
        
        % getPolygon
        function polygon = getPolygon(obj,frame_no)
            polygon = obj.polygons{frame_no};
        end
        
        % updatePolygons
        function obj = updatePolygons(obj, pos, frame_no)
            
            actual_polygon_paths = obj.polygons;
            pseudo_adj_matrix = obj.pseudoAdjMatrix;
            
            highest_level = max(pseudo_adj_matrix(1,:));
            next_level = highest_level + 1;
            actual_polygon_paths{frame_no} = pos;
            pseudo_adj_matrix(1,frame_no) = next_level;
            pseudo_adj_matrix(2,frame_no) = 1;
            
            if size(pseudo_adj_matrix,2) > 1
                next_kf_found = 0;
                count = frame_no + 1;
                
                while next_kf_found == 0
                    
                    tmp_val = pseudo_adj_matrix(2,count);
                    if tmp_val==0 && count < length(pseudo_adj_matrix)
                        pseudo_adj_matrix(1,count) = next_level;
                        actual_polygon_paths{count} = pos;
                        count = count+1;
                    else
                        if tmp_val==0
                            endpoint = length(pseudo_adj_matrix);
                            actual_polygon_paths{1,endpoint} = pos;
                            next_kf_found = 1;
                        else
                            next_kf_found = 1;
                        end
                    end
                end
            end
            
            obj.polygons = actual_polygon_paths;
            obj.pseudoAdjMatrix = pseudo_adj_matrix;
            
        end
        
        % removePolygonKF
        function [] = removePolygonKF(obj, keyframing_string)
            
            str_tokens = strsplit(keyframing_string,'_');
            frame_string = str_tokens{1};
            some_str_loc = strfind(frame_string,'>');
            sub_str = frame_string(some_str_loc+6:end);
            frame_no = str2num(char(sub_str));
            
            actual_polygon_paths = obj.polygons;
            pseudo_adj_matrix = obj.pseudoAdjMatrix;
            
            poly_marker = pseudo_adj_matrix(1,frame_no);
            kf_frames = find(pseudo_adj_matrix(1,:)==poly_marker);
            pseudo_adj_matrix(2,frame_no) = 0;
            next_kf = find(pseudo_adj_matrix(2,frame_no+1:end));
            prev_kf = find(pseudo_adj_matrix(2,1:frame_no));
            
            if isempty(prev_kf)
                % go to next_kf
                new_poly = actual_polygon_paths{next_kf(1)};
                actual_polygon_paths{kf_frames} = new_poly;
            else
                % use previous keyframe data
            end
            
        end
    end
end

