function [BG_VALS,BG_LBLS] = two_dim_bg_calc(image,spotInfo,num_pix_off,num_pix_bg)
%% <placeholder>
%

objCoords = spotInfo.objCoords;
spotMat = spotInfo.spotMat;
lbl = spotInfo.UL;
lbl_centroids = spotInfo.lbl_centroids;

% storing results
BG_VALS = cell(size(objCoords,1),1);

% only one label matrix (2D)
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
    centroids = lbl_centroids;
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
centroids = lbl_centroids;
closest_centroid = knnsearch(centroids,border_locs_sub);
lbl(border_locs_ind) = lbl(sub2ind(size(lbl),...
    round(centroids(closest_centroid,2)),round(centroids(closest_centroid,1))));

bg_lbl = double(lbl);
bg_lbl(border_locs_ind) = -bg_lbl(border_locs_ind);

BG_LBLS = bg_lbl;

% make adjustment so that regionprops >> pixlist can be called
% to pull pixel information about associated background regions
bg_lbl(bg_lbl >= 1) = 1;
bg_lbl(bg_lbl < 0) = bg_lbl(bg_lbl < 0) * -1;

bg_props = regionprops(bg_lbl,'PixelList');
tmp_pixlist = {bg_props.PixelList}';
BG_PIXLIST = tmp_pixlist(2:end,1);

% second, need to associate background pixel values with the correct 
% identified signal
for i=1:size(objCoords,1)
    
    pixlist_currentframe = BG_PIXLIST{i};
    BG_VALS{i} = image(sub2ind(size(image),...
        pixlist_currentframe(:,2),...
        pixlist_currentframe(:,1)));
end

BG_VALS = cat(2,BG_VALS,BG_VALS);

%
%%%
%%%%%
%%%
%