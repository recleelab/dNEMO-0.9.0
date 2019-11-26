%% RUN_INSPECT.m
%  
%  Script to call 'inspector'
%  
%  Inspector ideal for dealing with a single image.
%  

% breadcrumbs
init_dir = cd;

% OPTIONAL USER ARGUMENTS HERE
%

image_filename = [];
image_folderpath = [];

%
% NO EDITING PAST THIS POINT

if isempty(image_filename)
    disp('user input required. select image file.');
    [I,T,Z,image_filename] = image_in();
    if I==0
        disp('image not selected. terminating script.');
        return;
    end
else
    if isempty(image_folderpath)
        [I,T,Z,~] = image_in(image_filename,init_dir);
        if I==0
            disp('indicated image file not in current directory.');
            disp('user input required. select image file.');
            [I,T,Z,image_filename] = image_in();
            if I==0
                disp('image not selected. terminating script.');
                return;
            end
        end
    else
        [I,T,Z,~] = image_in(image_filename,image_folderpath);
        if I==0
            disp('indicated image file not found in indicated directory.');
            disp('user input required. select image file.');
            [I,T,Z,image_filename] = image_in();
            if I==0
                disp('image not selected. terminating script.');
                return;
            end
        end
    end
end

% image should be successfully loaded into the workspace. 
% run inspector.

%
%%%
%%%%%
%%%
%