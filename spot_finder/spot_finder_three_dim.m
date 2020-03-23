function [spotInfo] = spot_finder_three_dim(image,threshold,frame_limit,overseg,wav_level)
%% main 'spot_finder' method. calls spot_finder_two_dim to operate on every slice
%  in the 3D image, passing along the wavelet threshold and oversegmentation arguments 
%  (in:threshold & in:overseg). returns large results struct with all relevant information
%  and label matrices upon which to operate on and gather more information.
%  
%  INPUT:
%  .  image - standard 3D image [x y z] to be processed.
%  .  threshold - threshold value to apply when performing the wavelet transform. 
%  .  frame_limit - minimum number of frames a signal has to appear in to be 
%                   considered a valid signal.
%  .  overseg - simply binary argument [0||1] which determines whether oversegmentation
%               check is run in spot_finder_two_dim. without oversegmentation check,
%               runtime speeds up considerably, at the cost of potentially losing signal 
%               information, such as bifurcating valid signals into two separately 
%               identified signals.
% 
%  OUTPUT:
%  .  spotInfo - structure array containing the following fields.
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

% for ease
z_slices = size(image,3);

% centroids -- signal localization coordinates determined to be valid 
% for every slice in the 3D stack.
centroids = cell(z_slices,1);

% spot_mat -- [num_signals x num_frames] matrix which identifies which
% frames a given signal turns up in. each row represents a signal, each
% column represents a frame. the value is zero where the signal does not 
% appear and the value >= 1 when it does; the value corresponds to the 
% region identified in the label matrix associated with that frame.
spotMat = zeros(20000,z_slices);

% pixlist -- cell array containing pixels associated w/ each region.
% indices correspond to individual regions identified in the label matrices
pixlist = cell(z_slices,1);

% STILL NEED VALID DESCRIPTIONS
updated_lbls = cell(z_slices,1);

for i=1:z_slices
    
	[centroids{i},lbl,indices] = spot_finder_two_dim(image(:,:,i),threshold,overseg,wav_level);

    % code to ensure watershed edges are included as part of the signal
    [ii, jj] = find(lbl==0);
    borderlocs_sub = [jj ii];
    borderlocs_ind = lbl==0;
    closestcentroid = knnsearch(centroids{i}, borderlocs_sub);
    lbl(borderlocs_ind) = lbl(sub2ind(size(image(:,:,i)),...
        round(centroids{i}(closestcentroid,2)),round(centroids{i}(closestcentroid,1))));
    
	% updating lbl matrix to reflect clustered objects
	remove_me = find(indices==1);
	updated_lbls{i} = adjust_label_matrix(image(:,:,i),lbl,remove_me,centroids{i});
	alt_props = regionprops(updated_lbls{i},'PixelList');
	tmp_pixlist = {alt_props.PixelList}';
	pixlist{i} = tmp_pixlist(2:end,1);

    % code for handling user-established frame_limit
    if i>1
        centroidsCurrent = centroids{i};
        centroidsPrev = centroids{i-1};
        % check prev frame for matching spots
        padlength = size(centroidsCurrent,1)-size(centroidsPrev,1);
        if padlength > 0 % to compare distances, centroid lists have to be same length
            centroidsPrev = [centroidsPrev; zeros(padlength,2)];
        elseif padlength < 0
            centroidsCurrent = [centroidsCurrent; zeros(-padlength,2)];
        end
        % find all spots in previous frame within Euclidean dist of 2 of
        % each spot in current frame
        % matchLocs = find(dist(centroidsPrev, centroidsCurrent')<2);
        % distance_arr = dist(centroidsPrev, centroidsCurrent');
        distance_arr = dnemo_dist(centroidsPrev, centroidsCurrent');
        actual_dists = distance_arr<2;
        matchLocs = find(distance_arr<2);
        [prevRows,currRows] = ind2sub(length(centroidsPrev),matchLocs);
        % check if this spot is new, or already represented in spotMat in a
        % previous frame
        [indLogic, indLoc] = ismember(prevRows,spotMat(:,i-1));
        % store info on all centroids per spot in spotMat
        if sum(indLogic)>0
            % there are already values in spotMat corresponding to this
            % spot, store new values in same row
            spotMat(nonzeros(indLoc),i) = nonzeros(currRows.*indLogic);
        end
        % addendum - remove rows where currRows has already
        % been assigned
        addedRows = nonzeros(currRows.*indLogic);
        toAddRows = currRows.*~indLogic;
        logically_copies = ismember(toAddRows, addedRows);
        prevRows(logically_copies) = [];
        currRows(logically_copies) = [];
        indLogic(logically_copies) = [];
        actual_dists(logically_copies) = [];
        % end addendum - remove rows where currRows has already
        % been assigned
        % addendum - duplicate values in new rows
        [~,unique_ind] = unique(prevRows);
        dup_ind = setdiff(1:length(prevRows),unique_ind);
        dup_vals = prevRows(dup_ind);
        for tt=1:length(dup_vals)
            logically_dups = find(prevRows==dup_vals(tt));
            some_dists = actual_dists(logically_dups);
            [~,max_loc] = max(some_dists);
            logically_dups(max_loc) = [];
            prevRows(logically_dups) = [];
            indLogic(logically_dups) = [];
            currRows(logically_dups) = [];
        end
        [~,unique_ind] = unique(currRows);
        dup_ind = setdiff(1:length(currRows),unique_ind);
        dup_vals = currRows(dup_ind);
        for tt=1:length(dup_vals)
            logically_dups = find(currRows==dup_vals(tt));
            some_dists = actual_dists(logically_dups);
            [~,max_loc] = max(some_dists);
            logically_dups(max_loc) = [];
            prevRows(logically_dups) = [];
            indLogic(logically_dups) = [];
            currRows(logically_dups) = [];
        end
        % end addendum - duplicate values in new rows
        % for new spots, find first fully zero row of spotMat, record
        % centroid references
        nextrow = find(all(spotMat==0,2),1);
        spotMat(nextrow:nextrow+sum(indLogic==0)-1,i-1) = ...
            nonzeros(abs(indLogic-1).*prevRows);
        spotMat(nextrow:nextrow+sum(indLogic==0)-1,i) = ...
            nonzeros(abs(indLogic-1).*currRows);
    end
    
end

% testing...
if frame_limit == 1
    for centroid_idx=1:length(centroids)
        nextrow = find(all(spotMat==0,2),1);
        some_centroids = centroids{centroid_idx};
        if ~isempty(some_centroids)
            centroid_ind = 1:size(some_centroids,1);
            indices_included = ismember(1:size(some_centroids,1),spotMat(:,centroid_idx));
            centroid_ind(indices_included) = [];
            if ~isempty(centroid_ind)
                spotMat(nextrow:nextrow+length(centroid_ind)-1,centroid_idx) = centroid_ind;
            end
        end        
    end
end

% addendum - softening frame limit at bottom and top of stack
addendum_spot_mat_rows = [];
if frame_limit~=1

    lims = [1 length(centroids)];
    starting_ind = [];
    for centroid_idx=1:length(lims)
        some_centroids = centroids{lims(centroid_idx)};
        nextrow = find(all(spotMat==0,2),1);
        if isempty(starting_ind)
            starting_ind = nextrow;
        end
        if ~isempty(some_centroids)
            centroid_ind = 1:size(some_centroids,1);
            indices_included = ismember(1:size(some_centroids,1),spotMat(:,lims(centroid_idx)));
            centroid_ind(indices_included) = [];
            if ~isempty(centroid_ind)
                spotMat(nextrow:nextrow+length(centroid_ind)-1,lims(centroid_idx)) = centroid_ind;
            end
        end
    end
    nextrow = find(all(spotMat==0,2),1);
    ending_ind = nextrow-1;
    addendum_spot_mat_rows = spotMat(starting_ind:1:ending_ind,:);

end
% end addendum for softening the frame limit at axial limits

spotMat = spotMat(sum(spotMat~=0,2)>=frame_limit,:);
% addendum for softening the frame limit at axial limits
if ~isempty(addendum_spot_mat_rows)
    spotMat = cat(1,spotMat,addendum_spot_mat_rows);
end
% end addendum for softening the frame limit at axial limits
spotCount = size(spotMat,1);
objCoords = zeros(spotCount,3);
allobjCoords = zeros(nnz(spotMat),4); % records all 2D spots counted on each frame
SIG_VALS = cell(spotCount,2);

for i=1:spotCount
    
    frames = find(spotMat(i,:)~=0);
    objCoords(i,3) = mean(frames); % orignal manner for determining z-coordinate
    xvals = zeros(length(frames),1); % number of centroid x coordinates
    yvals = zeros(length(frames),1); % number of centroid y coordinates
    
    allintensities = zeros(750,1);
    max_mean_slice_intensity = 0;
    tmp_z_coord = 0;
	tmp_mid_intensities = [];
    
    coordNum = find(sum(allobjCoords,2)==0,1); % find first row of zeros
    for j=1:length(frames)
        % quick lookup key: 
        % . centroids{frame} --> cell containing centroids at indicated frame
        % . (spotMat(i,frames(j)),1||2) --> points to index within array
        %   at indicated frame and spot, either x or y coordinate
        xvals(j) = centroids{frames(j)}(spotMat(i,frames(j)),1);
        yvals(j) = centroids{frames(j)}(spotMat(i,frames(j)),2);
        allobjCoords(coordNum+j-1,:) = [xvals(j) yvals(j) frames(j) i];
        
        pixlist_currentframe = pixlist{frames(j)};
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
        
        % determining z_coordinate via raw intensity comparison
        mean_slice_intensity = mean(intensityvals(intensityvals>0));
        if (mean_slice_intensity > max_mean_slice_intensity)
            max_mean_slice_intensity = mean_slice_intensity;
            tmp_z_coord = frames(j);
			tmp_mid_intensities = intensityvals;
        end
        
    end
    
    objCoords(i,1) = mean(xvals);
    objCoords(i,2) = mean(yvals);
    objCoords(i,3) = tmp_z_coord;
	
	allintensities(allintensities==0) = [];
	SIG_VALS{i,1} = allintensities; % full signal intensities
	SIG_VALS{i,2} = tmp_mid_intensities; % middle slice intensities

end

% reporting results structure

spotInfo = struct;
spotInfo.objCoords = objCoords;
spotInfo.spotLocs2d = allobjCoords;
spotInfo.SIG_VALS = SIG_VALS;
spotInfo.spotMat = spotMat;
spotInfo.UL = updated_lbls;
spotInfo.lbl_centroids = centroids;

%
%%%
%%%%%
%%%
%

function [larger_val_storage] = quiet_resize(smaller_val_storage,first_nz)
%% quiet fxn to quickly handle appropriate resize
% 

current_size = size(smaller_val_storage,1);
larger_val_storage = zeros(current_size*2,1);
larger_val_storage(1:first_nz-1,1) = smaller_val_storage(1:first_nz-1,1);

%
%%%
%%%%%
%%%
%