function wavmap = atrous_wavelettrans(input_image, levels)
%%
% computes and displays a trous wavelet transform for a given image, up to
% the given number of levels. Original image and wavelet maps at each level
% can be displayed, output is currently highest level wavelet map.

filtervals = [1/16 1/4 3/8]; % from 3rd order B-spline

prev_image = input_image;

% figure;
% imshow(input_image,'InitialMagnification','fit');

for i=1:levels
    % generate appropriate filter for level - each level adds zeros between
    % values of original low pass filter (LPF), so at second level filter
    % vector becomes [1/16 0 1/4 0 3/8 0 1/4 0 1/16], etc and nonzero values
    % occur at powers of 2
    if i==1
        LPF = zeros(5,1);
        LPF(1:3) = filtervals(1:3);
        LPF(4) = LPF(2);
        LPF(5) = LPF(1);
    else
        LPF = zeros(length(LPF)+2^i,1);
        LPF(1) = filtervals(1);
        LPF(end) = LPF(1);
        LPF(ceil(length(LPF)/2)) = filtervals(3);
        LPF(ceil(length(LPF)/4)) = filtervals(2);
        LPF(ceil(3*length(LPF)/4)) = filtervals(2);
    end
    
    % 2D filter is just filter vector ^2
    filter = LPF*LPF';
    
    % convolve filter with original image
    im_nextlevel = conv2(prev_image,filter,'same');
    % wavelet map is difference between newest image and previous image
    wavelet_nextlevel = prev_image - im_nextlevel;
    prev_image = im_nextlevel;
    
%     figure; imshow(wavelet_nextlevel,[]);
end

wavmap = wavelet_nextlevel;
 %figure; imshow(wavelet_nextlevel,'InitialMagnification','fit');

