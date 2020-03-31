function [] = file_save(hand,evt,APP)
%% menu callback function to save current data 
%
%  current files produced include mat-files containing SPOT data, 
%  SPOTS PER CELL data, and sample TRAJECTORY data. optionally produced
%  files as determined by the user include an AVI of the created datasets
%  and 
%
%  INPUT: 
%  . hand -- menu object user clicked to initiate selection of new image
%            file
%  . evt -- evt object passed with any callback function
%  . APP -- application structure
%

IMG = getappdata(APP.MAIN,'IMG');
image_filename = IMG.img_filename;
S = strsplit(image_filename,'.');
root_name = S{1};

slash_character = '\';
if ismac || isunix
	slash_character = '/';
end

% prompt user for directory to store results, then navigate to said directory
[resulting_filename,resulting_filepath,some_idx] = uiputfile('*','save file',root_name);
if resulting_filename == 0
	return;
end

if length(resulting_filename) > 4
    if strcmp(resulting_filename(end-3:end),'.mat')
        resulting_filename = resulting_filename(1:end-4);
    end
end

root_name = resulting_filename;

results_filename = strcat(root_name,'_full_results.mat');

% navigate to results folder
cd(resulting_filepath);

mkdir(root_name);
addpath(root_name);
cd(root_name);

%{
% check for existence of utrack folder
folder_check = exist(utrack_foldername);
if folder_check == 7
	cd(utrack_foldername);
else
	mkdir(utrack_foldername);
	addpath(utrack_foldername);
	cd(utrack_foldername);
end
%}

% create utrack compatible output
% [utrack_all,utrack_cells] = create_utrack_output(APP,root_name);
% cd(resulting_filepath);

% save everything necessary for full results
full_save(APP,results_filename);

spot_detect = getappdata(APP.MAIN,'spot_detect');
[spot_arr, print_arr] = parse_keyframes(spot_detect);
spot_mat_file = strcat(root_name,'_ALL_SPOTS.mat');
% spot_xlsx_file = strcat(root_name,'_ALL_SPOTS.xlsx');

save(spot_mat_file,'spot_arr','-v7.3');

polygons = getappdata(APP.MAIN,'polygon_list');
cell_signals = getappdata(APP.MAIN,'cell_signals');
[cells, trajectories] = parse_cells(spot_detect, cell_signals);
cell_filename = strcat(root_name,'_ALL_CELLS');
save(cell_filename,'cells','trajectories','-v7.3');

% xls addendum
dnemo_results_to_excel(root_name, {spot_arr; cells; trajectories});

%{
KEYFRAMES = getappdata(APP.MAIN,'KEYFRAMES');
[spot_arr] = parse_keyframes(KEYFRAMES);
spot_filename = strcat(root_name,'_ALL_SPOTS');
save(spot_filename,'spot_arr','-v7.3');

polygons = getappdata(APP.MAIN,'polygon_list');
cell_signals = getappdata(APP.MAIN,'cell_signals');
[cells,trajectories] = parse_cells(KEYFRAMES, cell_signals);
cell_filename = strcat(root_name,'_ALL_CELLS');
save(cell_filename,'cells','polygons','trajectories','-v7.3');

% AVI
[avi_created] = create_avi(APP,root_name);
%}

%
%%%
%%%%%
%%%
%