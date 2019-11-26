function [] = i_o_setup(APP)
%% fxn just to keep i/o setup separate from the figure creation, also so
%  it's a bit more organized so I know it's all under one roof.

slash_character = '\';
if ismac || isunix
	slash_character = '/';
end

current_folder = pwd;
S = strsplit(current_folder,slash_character);
matlab_dir = '';
for i=1:length(S)
	matlab_dir = strcat(matlab_dir,S(i),slash_character);
	if strcmp(S(i),'MATLAB') == 1
		break
	end
end

% find out if bfmatlab exists somewhere w/in 

% get current pathway
current_filepath = pwd;
filepath_repeated = 0;
is_bfmatlab_here = 0;
while filepath_repeated == 0
    is_bfmatlab_here = exist('bfmatlab','dir');
    if is_bfmatlab_here == 7
        addpath('bfmatlab');
        break;
    else
        prev_folder = pwd;
        cd ../;
        new_folder = pwd;
        if strcmp(prev_folder,new_folder)==1
            filepath_repeated = 1;
        end
    end     
end
cd(current_filepath);

default_data_dir = strcat(current_folder,slash_character,'data');
default_results_dir = strcat(current_folder,slash_character,'results');

setappdata(APP.MAIN,'images_dir_path',default_data_dir);
setappdata(APP.MAIN,'results_dir_path',default_results_dir);
setappdata(APP.MAIN,'is_bfmatlab_here',is_bfmatlab_here);
setappdata(APP.MAIN,'matlab_dir',matlab_dir);

% TEMPORARY MEASURES W/ REGARDS TO BIOFORMATS, FINAL PRODUCT SHOULD HAVE IT PACKAGED
