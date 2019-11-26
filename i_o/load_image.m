function [frameArray] = load_image(filename)
%% quick function to create a frameArray of a 3D image given the filename
% 
% 

image_info = imfinfo(filename);
nFrames = numel(image_info);
frameArray = zeros(image_info(1).Height,image_info(1).Width,nFrames);
for i=1:nFrames
    frameArray(:,:,i) = im2double(imread(filename,i));
end
