function [frameArray,Z,T] = load_dv_file(filename)
%% function to open a dv file and return image, z-slices, and framecount
%  

% UPDATE - March 2019
new_reader = bfGetReader(filename);
Z = new_reader.getSizeZ();
T = new_reader.getSizeT();

frameArray = cell(T,1);

for frame_ind = 1:T
	tmp_image = [];
	for zz=1:Z
		next_pointer = ((frame_ind-1)*Z)+zz;
		next_plane = bfGetPlane(new_reader,next_pointer);
		tmp_image = cat(3,tmp_image,flip(im2double(next_plane)));
	end
	frameArray{frame_ind} = tmp_image;
end

%{
% gather initial file information
data = bfopen(filename);
series = data{1,1};
planeCount = size(series,1);
imSize = size(series{1});
frameArray = zeros(imSize(1),imSize(2),planeCount);

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
%}

%{
first_frame_info_description = series{1,2};
k_start = strfind(first_frame_info_description,'Z=1/');
disp(k_start);
k_end = strfind(first_frame_info_description,'; T=');
disp(k_end);
num_digits_z = k_end - (k_start+4);
if num_digits_z == 1
    disp('trbleshoot: z is only one digit');
    z_slices = str2double(first_frame_info_description(1,k_start+4));
    disp(z_slices);
else
    disp('trbleshoot: z is 2 or more digits');
    num_digits_z = size(first_frame_info_description,2) - (k_start+3);
    num_digits_z = (k_end - k_start) - 4;
    disp(num_digits_z);
    temp_z_string = '';
    k_start = k_start+3;
    for i=1:num_digits_z
        temp_z_string(1,i) = strcat(first_frame_info_description(1,k_start+i));
    end
    z_slices = str2num(char(temp_z_string));
end

Z = z_slices;
T = size(frameArray,3)/z_slices;
%}

