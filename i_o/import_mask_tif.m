function [polygon_list] = import_mask_tif(mask_filename, mask_folderpath, max_frames)
%% <placeholder>
%

polygon_list = {};

prev_dir = cd(mask_folderpath);
some_info = imfinfo(mask_filename);

num_frames = length(some_info);

frame_segmentations = cell(num_frames, 1);

for ff=1:num_frames
    
    next_entry = {};
    
    some_frame = imread(mask_filename, ff);
    if strcmp(mask_filename,'mask1.tif')
        some_frame = flip(some_frame);
    end
    max_num_objects = max(max(some_frame));
    for ii=1:max_num_objects
        
        [row, col] = find(some_frame==ii);
        if length(row) >= 3
            poly_ind = convhull(col, row);
            tmp_mat = cat(2,col(poly_ind), row(poly_ind));
            next_entry = cat(1,next_entry, {tmp_mat});
        end
        
    end
    
    frame_segmentations{ff} = next_entry;
    
end

cd(prev_dir);

% all mask segmentations are imported, now to make single cells
warning('off', 'all');

% something's going wrong, want to make sure there's nothing going weird
indexing_mat = [1:length(frame_segmentations{1})].';
for frame_idx=2:length(frame_segmentations)
    
    % prev_polygons = frame_segmentations{frame_idx-1};
    % more involved non-zero search through indexing mat
    last_poly_ind = [];
    last_poly_frame = [];
    prev_polygons = {};
    
    for tt=1:size(indexing_mat,1)
        
        prev_poly_frame = find(indexing_mat(tt,:),1,'last');
        last_poly_frame = cat(1,last_poly_frame, prev_poly_frame);
        
        prev_poly_ind = indexing_mat(tt, prev_poly_frame);
        last_poly_ind = cat(1,last_poly_ind,prev_poly_ind);
        
        tmp_polygon = frame_segmentations{prev_poly_frame}{prev_poly_ind};
        prev_polygons = cat(1,prev_polygons,tmp_polygon);
        
    end
    
    next_polygons = frame_segmentations{frame_idx};
    
    tmp_area_mat = zeros(length(prev_polygons), length(next_polygons));
    
    for pp=1:length(next_polygons)
        polyshape_01 = polyshape(next_polygons{pp});
        for oo=1:length(prev_polygons)
            
            polyshape_02 = polyshape(prev_polygons{oo});
            
            if overlaps(polyshape_01, polyshape_02)
                tmp_area_mat(oo, pp) = area(intersect(polyshape_01, polyshape_02));
            end
            
        end
    end
    
    next_entry = zeros(size(tmp_area_mat,1),1);
    
    for row_idx=1:size(tmp_area_mat,1)
        
        [max_val, max_loc] = max(tmp_area_mat(row_idx,:));
        if max_val==0
            next_entry(row_idx) = 0;
        else
            next_entry(row_idx) = max_loc;
            tmp_area_mat(:, max_loc) = 0;
        end

        
    end
    
    indexing_mat = cat(2, indexing_mat, next_entry);
    
end

% convert to TMP_CELL objects

for row_idx=1:size(indexing_mat, 1)
    
    next_row = indexing_mat(row_idx,:);
    
    starting_poly = frame_segmentations{1}{next_row(1)};
    reduced_poly = polyshape(starting_poly);
    new_cell = TMP_CELL(reduced_poly.Vertices, max_frames, 1);
    
    for ind = 2:length(next_row)-1
        
        if next_row(ind) ~= 0
            new_position = frame_segmentations{ind}{next_row(ind)};
            new_position = polyshape(new_position);
            new_cell = new_cell.updatePolygons(new_position.Vertices, ind);
            
        end
        
    end
    
    polygon_list = cat(1,polygon_list,{new_cell});
    
end

warning('on', 'all');

%
%%%
%%%%%
%%%
%