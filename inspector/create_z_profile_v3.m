function [raw_zdata,frames] = create_z_profile_v3(INSPECT,image,spotInfo,true_ind)
%% <placeholder>
%  

disp('creating z profile');

% establishing necessary components
spotMat = spotInfo.spotMat;
UL = spotInfo.UL;
signal_coordinate = spotInfo.objCoords(true_ind,:);
z_coordinate = signal_coordinate(1,3);
frames = find(spotMat(true_ind,:)~=0);

% get full signal coordinates, find bounding box
sig_pixels = [];
for tmp_idx=1:size(frames,2)
    
    curr_frame = frames(tmp_idx);
    curr_lbl = UL{curr_frame};
    label_pointer = spotMat(true_ind,curr_frame);
    
    [tmp_pixels_y,tmp_pixels_x] = find(curr_lbl==label_pointer+1);
    if tmp_idx==1
        sig_pixels = [tmp_pixels_x,tmp_pixels_y];
    else
        sig_pixels = cat(1,sig_pixels,[tmp_pixels_x,tmp_pixels_y]);
    end
end

% sig_pixels should have all the values
assignin('base','sig_pixels',sig_pixels);

% find all unique x,y pairs to consider for the area which the signal
% covers in the maximum intensity projection - only necessary for bounding
% box creation for 'column' profile up and down the z axis
[unique_signal_xy] = unique(sig_pixels(:,1:2),'rows');
bbox = zeros(1,4);
bbox(1,1) = min(unique_signal_xy(:,1));
bbox(1,2) = max(unique_signal_xy(:,1));
bbox(1,3) = min(unique_signal_xy(:,2));
bbox(1,4) = max(unique_signal_xy(:,2));

% for now, column calculation performed using mean -- still finessing a
% couple of items
raw_zdata = zeros(size(image,3),2);
SIG_VALS = spotInfo.SIG_VALS;

for tmp_idx=1:size(image,3)
    raw_zdata(tmp_idx,1) = tmp_idx;
    curr_image = image(:,:,tmp_idx);
    curr_intensities = zeros(500,1);
    tmp_count = 1;
    
    if tmp_idx < frames(1,1) || tmp_idx > frames(1,size(frames,2))
        % signal not present in frame
        for bb=bbox(1,1):bbox(1,2)
            for ox=bbox(1,3):bbox(1,4)
                curr_intensities(tmp_count,1) = curr_image(ox,bb);
                tmp_count = tmp_count + 1;
            end
        end
        
        % raw data representation switch goes HERE
        raw_zdata(tmp_idx,2) = mean(curr_intensities(curr_intensities > 0));
    else
        % signal present in frame
        % TEMPORARY - NEED TO EXAMINE SOMETHING
        for bb=bbox(1,1):bbox(1,2)
            for ox=bbox(1,3):bbox(1,4)
                curr_intensities(tmp_count,1) = curr_image(ox,bb);
                tmp_count = tmp_count + 1;
            end
        end
        % raw data representation switch goes HERE
        raw_zdata(tmp_idx,2) = mean(curr_intensities(curr_intensities > 0));
    end
    
end

setappdata(INSPECT.figure_handle,'curr_bbox',bbox);

%
%%%
%%%%%
%%%
%