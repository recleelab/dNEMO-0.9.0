function [spot_value_mat] = pull_spot_information(SIG_VALS,BG_VALS)
%%
%  INPUT:
%  .  SIG_VALS
%  .  BG_VALS
%  
%  OUTPUT:
%  .  spot_value_mat
%

spot_value_mat = zeros(length(SIG_VALS),5);
avg_background = cellfun(@mean,BG_VALS);

for tmp_idx=1:length(SIG_VALS)
    SIG_VALS{tmp_idx} = SIG_VALS{tmp_idx} - avg_background(tmp_idx);
end

spot_value_mat(:,1) = cellfun(@mean,SIG_VALS);
spot_value_mat(:,2) = cellfun(@median,SIG_VALS);
spot_value_mat(:,3) = cellfun(@sum,SIG_VALS);
spot_value_mat(:,4) = cellfun(@length,SIG_VALS);
spot_value_mat(:,5) = cellfun(@max, SIG_VALS);


%
%%%
%%%%%
%%%
%