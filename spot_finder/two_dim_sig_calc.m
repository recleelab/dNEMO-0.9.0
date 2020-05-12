function [spotInfo] = two_dim_sig_calc(image,centroids,lbl,indices)
%% fxn which creates the (originally) 3D info structure spotInfo for results
%  from 2D images.
%
% INPUT:
% . image - image object
% . centroids - array of 2D centroids
% . label matrix - matrix representing unique spots identified in the image
%                  object. max of label matrix is length(centroids) + 1.
% . indices - pointers to centroids which were resolved in the additional
%             oversegmentation step. actual adjustment happens in
%             'adjust_label_matrix.m'
% OUTPUT:
% . spotInfo - structure containing all spot information in the following
%              fields:
%     > objCoords - (num_signals) x (3) array containing [x y z] coords
%                   for every detected signal in the 3D image.
%     > spotLocs2d - [x y z ind] array containing each 2D centroid detected
%                    as part of the 3D signal. the fourth column (ind)
%                    indicates the start of a new signal moving down the
%                    length of the array.
%     > SIG_VALS - (num_signals) x (2) cell array containing raw intensity
%                  values for the detected signals. the first column
%                  contains every pixel intensity value (double) and the
%                  second column contains pixel values of only the middle
%                  slice of the signal (@ the centroid's z-coordinate).
%     > spotMat - (num_signals) x (z_slices) containing references to each
%                 object within the label matrices which correspond to the
%                 indicated signal (indexed by row). the value within
%                 spotMat will refer to the centroid in <lbl_centroids> for
%                 that given slice, but is off-by-1 for its actual integer
%                 in the label matrix (as all values in the label matrix
%                 are off-by-1).
%     > UL - label matrices identifying the regions detected as signals
%            within the given image. can be used to grab additional
%            properties and dilated to grab local background to associate
%            with each signal.
%     > lbl_centroids - all valid signals identified within the label
%                       matrix. coordinates stored as standard (x,y,z).
% 

% code to ensure watershed edges are included as part of the signal
[ii,jj] = find(lbl==0);
borderlocs_sub = [jj ii];
borderlocs_ind = lbl==0;
closestcentroid = knnsearch(centroids,borderlocs_sub);
lbl(borderlocs_ind) = lbl(sub2ind(size(image),...
    round(centroids(closestcentroid,2)),round(centroids(closestcentroid,1))));

% updating lbl matrix to reflect clustered objects
remove_me = find(indices==1);
updated_lbl = adjust_label_matrix(image,lbl,remove_me,centroids);
alt_props = regionprops(updated_lbl,'PixelList');
tmp_pixlist = {alt_props.PixelList}';
pixlist = tmp_pixlist(2:end,1);

% spotMat, objCoords, SIG_VALS assembly
spotMat = 1:size(centroids,1);
spotCount = length(spotMat);
objCoords = cat(2,centroids,ones(size(centroids,1),1));
SIG_VALS = cell(spotCount,1);

% input signal values
for i=1:spotCount
    pixlist_currentframe = pixlist{i};
    SIG_VALS{i} = image(sub2ind(size(image),...
        pixlist_currentframe(:,2),...
        pixlist_currentframe(:,1)));
end

SIG_VALS = cat(2,SIG_VALS,SIG_VALS);

% reporting results structure
spotInfo = struct;
spotInfo.objCoords = objCoords;
spotInfo.spotLocs2d = objCoords;
spotInfo.SIG_VALS = SIG_VALS;
spotInfo.spotMat = spotMat;
spotInfo.UL = updated_lbl;
spotInfo.lbl_centroids = centroids;

%
%%%
%%%%%
%%%
%