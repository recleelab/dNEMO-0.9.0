function [I,T,Z,image_filename] = image_in(user_filename,user_filepath)
%% fxn for opening an image and setting it to the workspace.
%  
%  formats supported: TIFF, DV (bioformats package required, see below)
%  
%  bioformats required to open .dv files, package can be 
%  found here: downloads.openmicroscopy.org/bio-formats/5.5.3/
%
%  INPUT: 
%  .  [no arg] - calling method without an argument runs a uigetfile
%     interaction with the user which allows user to search for the image
%     they'd like to open.
%  .  user_filename - filename of image user wants to open. calling method
%     with only user_filename searches for the image file within the
%     current directory. warning displayed if image not found.
%  .  user_filepath - location of directory in which to find the desired
%                     image. warning displayed if image not found.
%  
%  OUTPUT:
%  .  I - array of size [x y z] containing all images from user-
%		  selected file. type double.
%  .  T - double indicating number of frames in image. if the 
%         image is 3D, T = size(I,3) / Z.
%  .  Z - double indicating number of z-slices for the selected
%         image file. if the image is 2D, Z = 0.
%  .  image_filename - string denoting image file selected by user
%

% breadcrumbs
init_folder = pwd;

I = 0;
T = 0;
Z = 0;
image_filename = '';
image_filepath = '';
if nargin < 1
    [filename,filepath,~] = uigetfile({'*.tif;*.dv'},'Load Image');
    if isequal(filename,0)
        cd(init_folder);
        return;
    end
    image_filename = filename;
    image_filepath = filepath;
    
elseif nargin < 2 && strcmp(image_filename,'')
    % user supplied filename only, search for it in the current folder
    if exist(fullfile(cd,user_filename),'file')
        disp('image found in current directory.');
        image_filename = user_filename;
        image_filepath = init_folder;
    else
        % check supplied filename against all .tif,.dv files within the 
        % current directory. user potentially didn't supply file extension.
        disp('checking supplied filename against current directory.');
        test_tif_filename = strcat(user_filename,'.tif');
        test_dv_filename = strcat(user_filename,'.dv');
        if exist(fullfile(init_folder,test_tif_filename),'file')
            disp('TIFF found for supplied filename.');
            image_filename = test_tif_filename;
            image_filepath = init_folder;
        elseif exist(fullfile(init_folder,test_dv_filename),'file')
            disp('DV found for supplied filename.');
            image_filename = test_dv_filename;
            image_filepath = init_folder;
        else
            % display warning that image file was not found at indicated dir.
            warningMessage = sprintf('Warning: image file not found at indicated directory:\n%s',fullfile(init_folder,user_filename));
            uiwait(msgbox(warningMessage));
            return;
        end
    end
else
    % user supplied both the filename and the filepath, search for it in
    % the supplied filepath. 
    if exist(fullfile(user_filepath,user_filename),'file')
        disp('image found in supplied directory.');
        image_filename = user_filename;
        image_filepath = user_filepath;
    else
        % check supplied filename against all .tif,.dv files within the
        % supplied directory. user potentially didn't supply the file
        % extension.
        disp('checking supplied filename against supplied directory.');
        test_tif_filename = strcat(user_filename,'.tif');
        test_dv_filename = strcat(user_filename,'.dv');
        if exist(fullfile(user_filepath,test_tif_filename),'file')
            disp('TIFF found for supplied filename.');
            image_filename = test_tif_filename;
            image_filepath = user_filepath;
        elseif exist(fullfile(user_filepath,test_dv_filename),'file')
            disp('DV found for supplied filename.');
            image_filename = test_dv_filename;
            image_filepath = user_filepath;
        else
            % display warning that image file was not found at indicated dir.
            warningMessage = sprintf('Warning: image file not found at indicated directory:\n%s',fullfile(user_filepath,user_filename));
            uiwait(msgbox(warningMessage));
            return;
        end
    end
end

% check filetype.
string_tokens = strsplit(image_filename,'.');
file_type = string_tokens{size(string_tokens,2)};

% if filetype is dv, check to see that bfmatlab is on the current path. 
if strcmp(file_type,'dv')
	is_bioformats_here = exist('bfmatlab','dir');
	if is_bioformats_here ~= 7
		disp('Unable to find Bio-Formats package for MATLAB.');
		disp('Add Bio-Formats package to current path before opening DV file.');
		return;
	end
end

% navigate to selected image's filepath
cd(image_filepath);

% delineate based on file type
switch file_type
    
    case 'tif'
        disp('loading image from .tif file.');
        I = load_image(image_filename);
        if size(I,3) == 1
            Z = 0;
            T = 1;
        else
            dim_choice = questdlg('Is movie 2D or 3D?',...
                'Number of dims','2D','3D','Cancel','2D');
            switch dim_choice

                case '2D'
                    Z = 0;
                    T = size(I,3);
                %
                %%%
                %
                case '3D'
                    [Z,T] = guess_z_slices(I);
                %
                %%%
                %
                case 'Cancel'
                    I = 0;
                    cd(init_folder);
                    return;
            end
        end
    
    %
    %%%
    %
    case 'dv'
        disp('loading image from .dv file.');
        [I,Z,T] = load_dv_file(image_filename);
        
end

% return to initial folder
cd(init_folder);

%
%%%
%%%%%
%%%
%

function [frameArray,Z,T] = load_dv_file(filename)
%% fxn for loading image from a dv file.
%  DV files always 3D, always need BFMATLAB to be opened.
% 
%  INPUT:
%  .  filename - string filename indicating file to be opened
%  
%  OUTPUT:
%  .  frameArray - matrix containing resulting image
%  .  Z - number of z-slices per frame in the resulting image
%  .  T - number of frames in the resulting time-series image

% gather initial file information
data = bfopen(filename);
series = data{1,1};
planeCount = size(series,1);
imSize = size(series{1});
frameArray = zeros(imSize(1),imSize(2),planeCount);

% read image into frameArray
for i=1:planeCount
    frameArray(:,:,i) = flip(im2double(series{i,1}));
end

% parse additional information from bioformats to get T and Z
info_string = series{1,2};
z_str_pattern = 'Z=1/';
t_str_pattern = '; T=';

%
k_start = strfind(info_string,z_str_pattern);
k_end = strfind(info_string,t_str_pattern);
%

if isempty(k_end)
    k_end = length(info_string);
else
    k_end = k_end - 1;
end

z_substr = extractBetween(info_string,k_start+length(z_str_pattern),k_end);
Z = str2double(char(z_substr));
T = size(frameArray,3) / Z;

%
%%%
%%%%%
%%%
%

function [frameArray] = load_image(filename)
%% fxn for loading image from some filename (quick, inelegant)
%  

image_info = imfinfo(filename);
nFrames = numel(image_info);
frameArray = zeros(image_info(1).Height,image_info(1).Width,nFrames);
for i=1:nFrames
    frameArray(:,:,i) = im2double(imread(filename,i));
end

%
%%%
%%%%%
%%%
%

function [Z,T] = guess_z_slices(I)
%% fxn for guessing z-slices based on image pixel values.
%  before committing to Z & T values, the function prompts 
%  user to confirm / write in their own value for z.
%  
%  NOTE: command needs to properly handle invalid z / t configurations,
%        which needs to be handled.
%  
%  INPUT:
%  .  I - matrix containing the image
% 
%  OUTPUT:
%  .  Z - number of z slices, 
%  .  T - number of frames, determined by both Z and size of I
%

% determine background pixels' trend over time
hi_lo_arr = zeros(size(I,3),2);
for m=1:size(I,3)
    hi_lo_arr(m,:) = stretchlim(I(:,:,m));
end
[~,locs] = findpeaks(hi_lo_arr(:,1));

% find distance betwen each of the peaks, make mode likely z, but
% confirm with the user
if size(locs,1) > 1
    locs_dist = zeros(size(locs,1)-1,1);
    locs_dist(1,1) = locs(1,1)-1;
    for n=2:size(locs,1)
        locs_dist(n,1) = locs(n,1)-locs(n-1,1);
    end
    likely_z_dist = mode(locs_dist);
else
    likely_z_dist = size(I,3);
end

% dialog box to confirm number of z-slices
prompt = {'Confirm number of z-slices:'};
dlg_title = 'No. of slices';
num_lines = 1;
defaultans = {num2str(likely_z_dist)};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);

Z = str2double(answer);
T = round(size(I,3)/Z);

%
%%%
%%%%%
%%%
%