function [] = file_load(hand, evt, APP)
%% function for initiating loading images into the application
%
%  INPUT: 
%  . hand -- menu object user clicked to initiate selection of new image
%            file
%  . evt -- evt object passed with any callback function
%  . APP -- application structure
%
%  supported image formats: TIFF, DV
%  
%  bioformats required for image input, should be packaged with tool but
%  can be downloaded by navigating to the following URL:
%
%  downloads.openmicroscopy.org/bio-formats/5.5.3/
%

% breadcrumbs
init_folder = pwd;

% currently available image formats: TIFF, DV
valid_format_args = {'*.tif;*.TIF;*.dv;*.DV'};

curr_image_path = getappdata(APP.MAIN,'images_dir_path');
[input_filename, input_filepath] = uigetfile(valid_format_args, 'Load Image');
if isequal(input_filename, 0)
    cd(init_folder);
    return;
end
cd(init_folder);

% create new image object
IMG = TMP_IMG(input_filename, input_filepath);

% run application setup
app_setup(APP, IMG); 

is_same_path = strcmp(curr_image_path, input_filepath);
if ~is_same_path
    disp('reassigning current images directory');
    setappdata(APP.MAIN, 'images_dir_path',input_filepath);
end

%
%%%
%%%%%
%%%
%