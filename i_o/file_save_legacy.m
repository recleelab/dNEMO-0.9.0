function [] = file_save(hand,evt,APP)
%% <placeholder> 
% 
%  still not sold on final results file, but time is short
% 

image_filename = getappdata(APP.MAIN,'filename');
S = strsplit(image_filename,'.');
root_name = S{1};

slash_character = '\';
if ismac || isunix
	slash_character = '/';
end

% ask user where to store but navigate to results directory currently stored first...
[resulting_filename,resulting_filepath,some_idx] = uiputfile('*.mat','save file',root_name);
if resulting_filename == 0
	return;
end

results_filename = strcat(root_name,'_full_results.mat');
utrack_filename = strcat(root_name,'_utrack_results.mat');

% utrack first, easier.
number_of_frames = APP.film_slider.Max;
[movieInfo] = create_utrack_output(APP,number_of_frames);
assignin('base','movieInfo',movieInfo);

% movieInfo is being correctly created - now to save to file which can be
% read by utrack
curr_folder = cd(resulting_filepath);
save(utrack_filename,'movieInfo');

% save utrack output per cell
cell_foldername = 'utrack_single_cell_files';
mkdir(cell_foldername);
prev_folder = cd(cell_foldername);
create_utrack_output_per_cell(APP,number_of_frames);
cd(prev_folder);

% quickly save everything absolutely necessary for full_results
full_save(APP,results_filename);

% now for the trajectories of cells over time (simple mat-file)
create_cellular_trajectories(APP,root_name,number_of_frames);

% TEMPORARY - 
tmp_answer = questdlg(strcat('Create single cell distributions of signal',...
    {' '},'intensity and size information? (works best with a single IMAGE, not MOVIE)'),...
    'Single Cell Distributions','Yes','No','No');
switch tmp_answer
    case 'Yes'
        single_cell_histogram_dists(APP,root_name);
    case 'No'
        % do nothing
end

% finally, quick AVI
AVI_answer = questdlg('Create a short AVI depicting signals captured using this application?',...
				'Record Film','Yes','No','Yes');
switch AVI_answer
	case 'Yes'
		create_avi(APP);
	case 'No'
		% do nothing
end



%
%%%
%%%%%
%%%
%

function [movieInfo] = create_utrack_output(APP,num_frames)
%% fxn for creating compatible utrack output struct array
%  
%  necessary fields -- 
%  xCoord - P x 2
%  yCoord - P x 2
%  zCoord - P x 2
%  amp - P x 2
%  

% use kf_ref_array, keyframes, incl_excl to get valid output
kf_ref_arr = getappdata(APP.MAIN,'keyframe_ref_array');
KEYFRAMES = getappdata(APP.MAIN,'KEYFRAMES');

% initialize movieInfo
movieInfo = struct;

for idx=1:num_frames
	
	top_kf_idx = max(kf_ref_arr(:,idx));
	curr_kf = KEYFRAMES{top_kf_idx};
	curr_spotInfo = curr_kf.spotInfo{idx};
	curr_incl_excl = curr_kf.incl_excl{idx};
	
	objCoords = curr_spotInfo.objCoords;
	signal_values = curr_spotInfo.SIG_VALS;
	mean_sig_vals = cellfun(@mean,signal_values(:,2));
	
	xCoords = objCoords(curr_incl_excl,1);
	xCoords = cat(2,xCoords,zeros(size(xCoords,1),1));
	
	yCoords = objCoords(curr_incl_excl,2);
	yCoords = cat(2,yCoords,zeros(size(yCoords,1),1));
	
	zCoords = objCoords(curr_incl_excl,3);
	zCoords = cat(2,zCoords,zeros(size(zCoords,1),1));
	
	amp = mean_sig_vals(curr_incl_excl);
	amp = cat(2,amp,zeros(size(amp,1),1));
	
	movieInfo(idx).xCoords = xCoords;
	movieInfo(idx).yCoords = yCoords;
	movieInfo(idx).zCoords = zCoords;
	movieInfo(idx).amp = amp;
	
end

%
%%%
%%%%%
%%%
%

function [] = create_cellular_trajectories(APP,root_name,num_frames)
%% fxn for creating summary of cellular trajectories
%  that is, the number of signals in cells over time
%  
%  needs to take into account cell signal assignment AND incl_excl for 
%  a given frame
% 

kf_ref_arr = getappdata(APP.MAIN,'keyframe_ref_array');
KEYFRAMES = getappdata(APP.MAIN,'KEYFRAMES');
cell_signals = getappdata(APP.MAIN,'cell_signals');

% compose table of relevant data
results_mat = zeros(size(cell_signals,1),num_frames);
for cell_idx=1:size(cell_signals,1)
	
	for frame_idx=1:num_frames
		
		top_kf_idx = max(kf_ref_arr(:,frame_idx));
		curr_kf = KEYFRAMES{top_kf_idx};
		curr_spotInfo = curr_kf.spotInfo{frame_idx};
		curr_incl_excl = curr_kf.incl_excl{frame_idx};
		
		curr_cell = cell_signals{cell_idx,top_kf_idx};
		cell_in_frame = curr_cell{frame_idx};
		
		% remove any signals that should be excluded
		cell_in_frame(curr_incl_excl==0) = 0;
		
		% just need signal count per cell
		num_signals_in_cell = sum(cell_in_frame);
		results_mat(cell_idx,frame_idx) = num_signals_in_cell;
		
	end

end


% create new file
traj_filename = strcat(root_name,'_trajectories.mat');
save(traj_filename,'results_mat');

% 
%%%
%%%%%
%%%
%

function [] = create_utrack_output_per_cell(APP,num_frames)
%% <placeholder>
% 
%  necessary fields -- 
%  xCoord - P x 2
%  yCoord - P x 2
%  zCoord - P x 2
%  amp - P x 2
%  

% use kf_ref_array, keyframes, incl_excl to get valid output
kf_ref_arr = getappdata(APP.MAIN,'keyframe_ref_array');
KEYFRAMES = getappdata(APP.MAIN,'KEYFRAMES');

% get cell signals
cell_signals = getappdata(APP.MAIN,'cell_signals');

for cell_idx=1:size(cell_signals,1)
	
	cell_results_filename = strcat('utrack_cell_0',num2str(cell_idx),'.mat');
	
	% initialize movieInfo
	movieInfo = struct;
	
	for frame_idx=1:num_frames
		
		top_kf_idx = max(kf_ref_arr(:,frame_idx));
		curr_kf = KEYFRAMES{top_kf_idx};
		curr_spotInfo = curr_kf.spotInfo{frame_idx};
		curr_incl_excl = curr_kf.incl_excl{frame_idx};
		
		curr_cell = cell_signals{cell_idx,top_kf_idx};
		cell_in_frame = curr_cell{frame_idx};
		
		% remove any signals that should be excluded
		cell_in_frame(curr_incl_excl==0) = 0;
		
		% pull all relevant coordinates
		objCoords = curr_spotInfo.objCoords;
		signal_values = curr_spotInfo.SIG_VALS;
		mean_sig_vals = cellfun(@mean,signal_values(:,2));
	
		xCoords = objCoords(cell_in_frame,1);
		xCoords = cat(2,xCoords,zeros(size(xCoords,1),1));
	
		yCoords = objCoords(cell_in_frame,2);
		yCoords = cat(2,yCoords,zeros(size(yCoords,1),1));
	
		zCoords = objCoords(cell_in_frame,3);
		zCoords = cat(2,zCoords,zeros(size(zCoords,1),1));
	
		amp = mean_sig_vals(cell_in_frame);
		amp = cat(2,amp,zeros(size(amp,1),1));
	
		movieInfo(frame_idx).xCoords = xCoords;
		movieInfo(frame_idx).yCoords = yCoords;
		movieInfo(frame_idx).zCoords = zCoords;
		movieInfo(frame_idx).amp = amp;
	
	end
	
	% save
	save(cell_results_filename,'movieInfo');
	
end

%
%%%
%%%%%
%%%
%

function [] = full_save(APP,results_filename)
%%
% 

KEYFRAMES = getappdata(APP.MAIN,'KEYFRAMES');
keyframe_ref_array = getappdata(APP.MAIN,'keyframe_ref_array');
cell_signals = getappdata(APP.MAIN,'cell_signals');
polygon_list = getappdata(APP.MAIN,'polygon_list');

save(results_filename,'KEYFRAMES','keyframe_ref_array','cell_signals','polygon_list');

%
%%%
%%%%%
%%%
%

function [] = create_avi(APP)
%% <placeholder>
% 
% 

filename = getappdata(APP.MAIN,'filename');
U = strsplit(filename,'.');
root_name = U{1};

avi_suffix = '_detected_spots.avi';
avi_file = strcat(root_name,avi_suffix);
avi_scatter = VideoWriter(avi_file);

num_frames = APP.film_slider.Max;
APP.film_slider.Value = 1;
APP.cell_boundary_toggle.Value = 0;
APP.excluded_signals_toggle.Value = 0;
APP.frame_signal_toggle.Value = 0;
APP.cell_signal_toggle.Value = 1;
APP.created_cell_selection.Value = 1;

display_call(APP.film_slider,1,APP);

set(APP.ax2,'units','pixel');
axis_pos = get(APP.ax2,'position');
set(APP.ax2,'units','normalized');

fig_dims = APP.MAIN.Position;


for i=1:num_frames
	
	APP.film_slider.Value = i;
	display_call(APP.film_slider,1,APP);
	the_ax = getframe(APP.MAIN,axis_pos);
	spotMov(:,:,i) = the_ax;
	
end

open(avi_scatter);
for j=1:num_frames
	writeVideo(avi_scatter,spotMov(:,:,j));
end
close(avi_scatter);
APP.film_slider.Value = 1;
display_call(APP.film_slider,1,APP);

%
%%%
%%%%%
%%%
%

function [] = single_cell_histogram_dists(APP,root_name)
%% <placeholder>
%  

% pull image data from the application
raw_image_data = getappdata(APP.MAIN,'raw_image_data');
image = raw_image_data{1};

% pull keyframe, cell signal data
KEYFRAMES = getappdata(APP.MAIN,'KEYFRAMES');
KF = KEYFRAMES{1};

% pull cell signal information from the application
cell_signals = getappdata(APP.MAIN,'cell_signals');

% create new folder w/in existing results folder to store jpegs
dist_filename = strcat(root_name,'_signal_dists');
mkdir(dist_filename);
previously_here = cd(dist_filename);

spotInfo = KF.spotInfo;
incl_excl = KF.incl_excl{1};
SIG_VALS = spotInfo{1}.SIG_VALS;

num_cells = size(cell_signals,1);

intensity_info = cell(num_cells,1);
size_info = cell(num_cells,1);

% confirm background label information using assign_bg_pixels.m 
num_pix_off = getappdata(APP.MAIN,'NUM_PIX_OFF');
num_pix_bg = getappdata(APP.MAIN,'NUM_PIX_BG');
[BG_VALS,BG_LBLS] = assign_bg_pixels(image,spotInfo{1},num_pix_off,num_pix_bg);

% iterate through the cells, getting info and assigning where appropriate.
for cell_idx=1:num_cells
    
    disp(strcat('cell #',num2str(cell_idx)));
    
    % get bg corrected intensity information
    curr_cell = cell_signals{cell_idx,1};
    curr_cell_logic = curr_cell{1};
    curr_cell_logic(incl_excl==0) = 0;
    
    signal_values = SIG_VALS(curr_cell_logic,2);
    background_values = BG_VALS(curr_cell_logic,2);
    bg_means = cellfun(@mean,background_values);
    
    corr_intensity_info = zeros(size(signal_values,1),1);
    
    for tmp_idx=1:size(signal_values,1)
        corr_intensity_info(tmp_idx) = mean(cell2mat(signal_values(tmp_idx)) - bg_means(tmp_idx));
    end
    intensity_info{cell_idx,1} = corr_intensity_info;
    
    % get signal size information
    full_signals = SIG_VALS(curr_cell_logic,1);
    num_pixels_info = cellfun('length',full_signals);
    size_info{cell_idx,1} = num_pixels_info;
    
    % create new figure to save as a jpeg
    fig_handle = figure;
    hold on
    subplot(2,1,1);
    histogram(corr_intensity_info,'FaceColor','blue');
    xlabel('Corrected pixel intensity');
    % ylabel('Distribution of signal intensities in single cell');
    
    title('Distributions of signal properties in single cell');
    set(fig_handle,'units','normalized');
    % tmp_position = getpixelposition(fig_handle);
    annotation(fig_handle,'textbox',fig_handle.Position,...
                   'String',num2str(size(corr_intensity_info,1)),...
                   'color','black',...
                   'HorizontalAlignment','right',...
                   'VerticalAlignment','top',...
                   'EdgeColor','none',...
                   'FontSize',14,...
                   'FitBoxToText','on');
    
    subplot(2,1,2);
    histogram(size_info{cell_idx,1},'FaceColor','red');
    xlabel('Signal size (number of pixels)');
    % ylabel('Distribution of signal sizes in single cell');
    
    set(fig_handle,'units','normalized');
    % tmp_position = getpixelposition(fig_handle);
    annotation(fig_handle,'textbox',fig_handle.Position,...
                   'String',num2str(size(corr_intensity_info,1)),...
                   'color','black',...
                   'HorizontalAlignment','right',...
                   'VerticalAlignment','top',...
                   'EdgeColor','none',...
                   'FontSize',14,...
                   'FitBoxToText','on');
    hold off
    
    saveas(fig_handle,strcat(root_name,'_SIG_DIST_CELL_0',num2str(cell_idx)),'jpeg');
    delete(fig_handle);
    
end

% save results to mat-file
save(strcat(root_name,'_signal_values.mat'),'intensity_info','size_info');

% return
cd(previously_here);

