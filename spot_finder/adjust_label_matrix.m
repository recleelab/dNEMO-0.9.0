function [updated_lbl_mat] = adjust_label_matrix(image,input_lbl_mat,removed_indices,centroids)
%% fxn which updates the label matrix when detected centroids are removed during 
%  the oversegmentation check in spot_finder_two_dim
%
%  INPUT:
%  .  image - the image being processed (single slice) [x y]
%  .  input_lbl_mat - inital label matrix which contains integer pointers
%                     referring to centroids which are no longer contained
%                     within the given slice's detected centroids.
%  .  removed_indices - integer values which remain in the input_lbl_mat and must
%                       be removed as the centroids they point to no longer exist
%                       within the centroids set.
%  .  centroids - valid centroids determined by spot_finder_two_dim. regions within
%                 the label matrix omitted during oversegmentation because they were
%                 too close to some other point must be assimilated into the closest
%                 valid centroid from the input set.
%  
%  OUTPUT:
%  .  updated_lbl_mat - label matrix which correctly coordinates the regions within
%                       the label matrix to the valid centroids supplied as input.
%  

% check to see if there are no removed indices. if so, return lbl matrix as is.
if isempty(removed_indices)
	updated_lbl_mat = input_lbl_mat;
	return;
end

input_lbl_mat(ismember(input_lbl_mat,removed_indices+1)) = 0;
[ii,jj] = find(input_lbl_mat==0);
borderlocs_sub = [jj ii];
borderlocs_ind = input_lbl_mat==0;
closestcentroid = knnsearch(centroids, borderlocs_sub);
input_lbl_mat(borderlocs_ind) = input_lbl_mat(sub2ind(size(image),...
    round(centroids(closestcentroid,2)),round(centroids(closestcentroid,1))));

% removed_indices are removed from label matrix, and clustered areas are
% accurately reflected. NOW, to update those areas w/ their correct values
% according to spotMat
% disp(min(min(input_lbl_mat)));

updated_lbl_mat = input_lbl_mat - 1;
subtract_me_mat = zeros(size(input_lbl_mat));
for i=1:size(removed_indices)
    some_mat = updated_lbl_mat > removed_indices(i);
    subtract_me_mat(some_mat) = subtract_me_mat(some_mat) + 1;
end

lbl_class = class(updated_lbl_mat);
typecast_subtract_me = cast(subtract_me_mat,lbl_class);
updated_lbl_mat = updated_lbl_mat - typecast_subtract_me;
updated_lbl_mat = updated_lbl_mat + 1;