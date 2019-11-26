function [spotInfo] = two_dim_sig_calc(image,centroids,lbl,indices)
%% <placeholder>
%  

% starting materials:
% . image
% . centroids
% . label matrix
% . indices

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