function [BG_VALS,BG_LBLS] = assign_bg_pixels(image,spotInfo,num_pix_off,num_pix_bg)
%% 
%  

objCoords = spotInfo.objCoords;
spotMat = spotInfo.spotMat;
lbl_mats = spotInfo.UL;
% testing update
if ~iscell(lbl_mats)
    lbl_mats = {lbl_mats};
end

lbl_centroids = spotInfo.lbl_centroids;
if ~iscell(lbl_centroids)
    lbl_centroids = {lbl_centroids};
end

% storing results
BG_LBLS = cell(size(lbl_mats,1),1);
BG_PIXLIST = cell(size(lbl_mats,1));
BG_VALS = cell(size(objCoords,1),2);

% first need to create appropriate background label matrices for operations.
% with minimum amount of overhead
for i=1:size(lbl_mats,1)
	
	% pull current label
	lbl = lbl_mats{i};
	
	% define binary image whose regions are identified in the label matrix
	% with values > 1
	binary_mask = zeros(size(lbl,1),size(lbl,2));
	binary_mask(lbl > 1) = 1;
	
	% region dilation - pixel offset.
	if num_pix_off > 0
		
		% dilate by indicated offset
		off_strel = strel('square',(2*num_pix_off)+1);
		binary_mask = imdilate(logical(binary_mask),off_strel);
		binary_mask(lbl > 1) = 0;
		
		% assign newly dilated region the closest centroid index
		lbl(binary_mask) = 0;
		[yy,xx] = find(lbl==0);
		border_locs_sub = [xx yy];
		border_locs_ind = lbl==0;
		centroids = lbl_centroids{i};
        
        % attempt at fixing odd objects bug
        curr_centroid_values = lbl(round(centroids(:,2)),round(centroids(:,1)));
        curr_centroid_diag = diag(curr_centroid_values);
        logically_zero = find(curr_centroid_diag==0);
        if ~isempty(logically_zero)
            wrong_centroids = centroids(logically_zero,:);
            for wrong_pointer=1:size(wrong_centroids,1)
                lbl(round(wrong_centroids(wrong_pointer,2)),round(wrong_centroids(wrong_pointer,1))) = logically_zero(wrong_pointer) + 1;
            end
        end
        clear curr_centroid_values;
        
		closest_centroid = knnsearch(centroids,border_locs_sub);
		lbl(border_locs_ind) = lbl(sub2ind(size(lbl),...
			round(centroids(closest_centroid,2)),round(centroids(closest_centroid,1))));
		
		% reflect regional changes in the binary mask
		binary_mask(lbl > 1) = 1;
		
	end
	
	% region dilation - pixel background.
	bg_strel = strel('square',(2*num_pix_bg)+1);
	binary_mask = imdilate(logical(binary_mask),bg_strel);
	binary_mask(lbl > 1) = 0;
	
	% utilize binary mask to index into boundaries of all regions identified
	% in the label matrix
	lbl(binary_mask) = 0;
	
	% assign lbl values = 0 with their closest centroid index
	[yy,xx] = find(lbl==0);
	border_locs_sub = [xx yy];
	border_locs_ind = lbl==0;
	centroids = lbl_centroids{i};
    
     % attempt at fixing odd objects bug
    curr_centroid_values = lbl(round(centroids(:,2)),round(centroids(:,1)));
    curr_centroid_diag = diag(curr_centroid_values);
    logically_zero = find(curr_centroid_diag==0);
    if ~isempty(logically_zero)
        wrong_centroids = centroids(logically_zero,:);
        for wrong_pointer=1:size(wrong_centroids,1)
            lbl(round(wrong_centroids(wrong_pointer,2)),round(wrong_centroids(wrong_pointer,1))) = logically_zero(wrong_pointer) + 1;
        end
    end
    clear curr_centroid_values;
    
	closest_centroid = knnsearch(centroids,border_locs_sub);
	lbl(border_locs_ind) = lbl(sub2ind(size(lbl),...
		round(centroids(closest_centroid,2)),round(centroids(closest_centroid,1))));
	
	bg_lbl = double(lbl);
	bg_lbl(border_locs_ind) = -bg_lbl(border_locs_ind);
	BG_LBLS{i} = bg_lbl;
	
	% make adjustment so that regionprops >> pixlist can be called
	% to pull pixel information about associated background regions
	bg_lbl(bg_lbl >= 1) = 1;
	bg_lbl(bg_lbl < 0) = bg_lbl(bg_lbl < 0) * -1;
	
	bg_props = regionprops(bg_lbl,'PixelList');
	tmp_pixlist = {bg_props.PixelList}';
	BG_PIXLIST{i} = tmp_pixlist(2:end,1);
end
% second, need to associate background pixel values with the correct 
% identified signal
for i=1:size(objCoords,1)
	frames = find(spotMat(i,:)~=0);
    if length(frames)==1
        z_coord = frames;
    else
        z_coord = objCoords(i,3);
    end

	allintensities = zeros(1500,1);
	for j=1:length(frames)
		pixlist_currentframe = BG_PIXLIST{frames(j)};
		intensityvals = image(sub2ind(size(image),...
			pixlist_currentframe{spotMat(i,frames(j))}(:,2),... %y
			pixlist_currentframe{spotMat(i,frames(j))}(:,1),... %x
			frames(j)*ones(length(pixlist_currentframe{spotMat(i,frames(j))}(:,1)),1))); %z		
		firstnz = find(allintensities==0,1);
		while (firstnz + length(intensityvals)-2) > size(allintensities,1)
			larger_allintensities = quiet_resize(allintensities,firstnz);
			allintensities = larger_allintensities;
		end
		allintensities(firstnz:firstnz+length(intensityvals)-1) = intensityvals;

		% added for middle slice
		if frames(j) == z_coord
			BG_VALS{i,2} = intensityvals;
		end

	end

	allintensities(allintensities==0) = [];
	BG_VALS{i,1} = allintensities;

end

%
%%%
%%%%%
%%%
%

function [larger_val_storage] = quiet_resize(smaller_val_storage,first_nz)
%% quiet function to quickly handle the appropriate resize for the trouble
%  elements

current_size = size(smaller_val_storage,1);
larger_val_storage = zeros(current_size*2,1);
larger_val_storage(1:first_nz-1,1) = smaller_val_storage(1:first_nz-1,1);