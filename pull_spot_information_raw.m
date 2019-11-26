function [spot_value_mat] = pull_spot_information_raw(SIG_VALS,BG_VALS,image_type_arg)
%%
%  INPUT:
%  .  SIG_VALS
%  .  BG_VALS
%
%  OUTPUT:
%  .  spot_value_mat
%

if image_type_arg > 1
    SIG_VALS = cellfun(@convert_double_to_uint16,SIG_VALS,'UniformOutput',false);
    BG_VALS = cellfun(@convert_double_to_uint16,BG_VALS,'UniformOutput',false);
end

spot_value_mat = zeros(length(SIG_VALS),6);

% raw intensity values
spot_value_mat(:,1) = cellfun(@mean,SIG_VALS);
spot_value_mat(:,2) = cellfun(@max,SIG_VALS);
spot_value_mat(:,3) = cellfun(@sum,SIG_VALS);
spot_value_mat(:,4) = cellfun(@mean,BG_VALS);
if image_type_arg > 1
    tmp_BG_VALS = cellfun(@double,BG_VALS,'UniformOutput',false);
    spot_value_mat(:,5) = uint16(cellfun(@std,tmp_BG_VALS));
else
    spot_value_mat(:,5) = cellfun(@std,BG_VALS);
end
spot_value_mat(:,6) = cellfun(@max,BG_VALS);
spot_value_mat(:,7) = cellfun(@sum,BG_VALS);
spot_value_mat(:,8) = cellfun(@length,BG_VALS);

%
%%%
%%%%%
%%%
%