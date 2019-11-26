function [new_incl_excl] = quick_incl_excl(prev_incl_excl,image,spotInfo,param_struct)
%% <placeholder>
%

new_incl_excl = ones(size(prev_incl_excl,1),1);

% get corrected intensity info and signal size information
[bg_vals,~] = assign_bg_pixels(image,spotInfo,1,1);

signal_values = spotInfo.SIG_VALS;
bg_means = cellfun(@mean,bg_vals);

tmp_intensity_vals = zeros(size(signal_values,1),1);
for tmp_idx=1:size(signal_values,1)
    tmp_intensity_vals(tmp_idx) = mean(cell2mat(signal_values(tmp_idx)) - bg_means(tmp_idx));
end

size_info = cellfun('length',signal_values);

min_size = param_struct.paramSize(1,1);
max_size = param_struct.paramSize(1,2);

new_incl_excl(size_info < min_size) = 0;
new_incl_excl(size_info > max_size) = 0;

min_intensity = param_struct.paramIntensity(1,1);
max_intensity = param_struct.paramIntensity(1,2);

new_incl_excl(tmp_intensity_vals < min_intensity) = 0;
new_incl_excl(tmp_intensity_vals > max_intensity) = 0;


%
%%%
%%%%%
%%%
%