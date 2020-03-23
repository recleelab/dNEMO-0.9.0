function [frame_centroids,lbl,indices] = spot_finder_two_dim(image,user_threshold,overseg, wav_level)
%% spotfinder for 2-dimensional image
%

% create wavelet map, establish threshold
c = user_threshold;
wavmap = atrous_wavelettrans(image,wav_level);
threshold = nanmean(wavmap(:)) + c*nanstd(wavmap(:));

% oversegcheck, might have to revisit
% overseg = 1;

% wavelet map (wavmap) created. remove values below the threshold
wavthresh = wavmap;
wavthresh(wavmap < threshold) = 0;

% remove edge artifacts, invert wavelet map values so peaks are considered
% valleys, create copy of wavthresh if blur == 1
wavthresh(1:4,:) = 0;
wavthresh(:,1:4) = 0;
wavthresh(end-3:end,:) = 0;
wavthresh(:,end-3:end) = 0;
wavthresh = 1 - wavthresh;
wavthresh(wavthresh == 1) = 0;

% actual watershed
lbl = watershed(wavthresh,4);

% regionprops on created L matrix
% props = regionprops(lbl,'centroid');
props = regionprops(lbl,'centroid');
frame_centroids = cat(1, props.Centroid);
frame_centroids = frame_centroids(2:end,:);
frame_centroids = frame_centroids(~any(isnan(frame_centroids),2),:);

% null case for oversegmentation
indices = zeros(size(frame_centroids,1),1);

% oversegcheck
if overseg == 1
    % first locate all spots within 10pix of another spot
    % closepts = find(triu(dist(frame_centroids,frame_centroids'))<10 & triu(dist(frame_centroids,frame_centroids')~=0));
    closepts = find(triu(dnemo_dist(frame_centroids,frame_centroids'))<10 & triu(dnemo_dist(frame_centroids,frame_centroids')~=0));
    [rows,cols] = ind2sub(length(frame_centroids),closepts);
    clustercell = cell(length(rows),1);
    for i=1:length(rows)
        % check line histogram between 2 centroids
        intensityprof = improfile(image, [frame_centroids(rows(i),1) frame_centroids(cols(i),1)], [frame_centroids(rows(i),2) frame_centroids(cols(i),2)]);
        invintensity = 1.01*max(intensityprof) - intensityprof;
        if length(invintensity) > 2
            % if there is a local min, probably should be 2 separate spots
            % (this condition could refined)
            minvals = findpeaks(invintensity);
            tooclose = 0;
        else
            % if centroids are less than 3 pixels apart, probably
            % oversegmentation (and findpeaks won't run)
            tooclose = 1;
            minvals = 0;
        end
        if isempty(minvals) || tooclose == 1 % if there is no minimum between
            % the 2 centroids and they are more than 3 pixels apart, cluster them for removal
            % check if one of the points is already part of a previous cluster
            if isempty(find([clustercell{:}] == cols(i), 1)) && isempty(find([clustercell{:}] == rows(i), 1))
                clustercell{find(cellfun('isempty', clustercell)==1,1)} = [rows(i) cols(i)];
            elseif isempty(find([clustercell{:}] == cols(i), 1))
                matchloc = cellfun(@(x) any(x(:)==rows(i)),clustercell);
                clustercell{matchloc} = ...
                    [clustercell{matchloc} cols(i)];
            elseif isempty(find([clustercell{:}] == rows(i), 1))
                matchloc = cellfun(@(x) any(x(:)==cols(i)),clustercell);
                clustercell{matchloc} = ...
                    [clustercell{matchloc} rows(i)];
            end
        end
        % now clustercell should contain points in each cell that are
        % likely part of the same spot
    end
    clustercell = clustercell(~cellfun('isempty',clustercell));
    for i = 1:length(clustercell)
        % delete all but 1 centroid (highest intensity) from each cluster
        idx = sub2ind(size(image),round(frame_centroids(clustercell{i},2)),round(frame_centroids(clustercell{i},1)) );
        intensityvals = image(idx);
        [~,maxloc] = max(intensityvals);
        frame_centroids(clustercell{i}(clustercell{i}~=clustercell{i}(maxloc)),:) = 0;
    end
    
    % ADDED for analysis -- speedier than what I was doing.
    indices = all(frame_centroids==0,2);
    % finished addition for additional data retrieval
    frame_centroids(all(frame_centroids==0,2),:)=[];
end

%
%%%
%%%%%
%%%
%