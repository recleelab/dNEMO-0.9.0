function [] = full_save(APP,results_filename)
%% function responsible for writing results to several file formats
%
%  results data will be written from the application structure to the main
%  mat-file save format, which can then be reloaded into dNEMO
%
%  saves a .mat file, the main save file, to directory previously set by
%  the user
%
%  INPUT:
%  . APP -- application structure
%  . results_filename -- filename previously selected by the user to save
%                        the various save-files as
%  
%  OUTPUT:
%  . None
%

% deprecated structure
%{
KEYFRAMES = getappdata(APP.MAIN,'KEYFRAMES');
keyframe_ref_array = getappdata(APP.MAIN,'keyframe_ref_array');
cell_signals = getappdata(APP.MAIN,'cell_signals');
polygon_list = getappdata(APP.MAIN,'polygon_list');
%}

% pulling main structures
spot_detect = getappdata(APP.MAIN,'spot_detect');
KEYFRAMES = struct;
spot_detect_fields = spot_detect.getSpotDetectFields();
for field_idx=1:length(spot_detect_fields)
    KEYFRAMES.(spot_detect_fields{field_idx}) = spot_detect.(spot_detect_fields{field_idx});
end

cell_signals = getappdata(APP.MAIN,'cell_signals');
polygon_list = getappdata(APP.MAIN,'polygon_list');
KEYFRAMES.spotInfo = KEYFRAMES.spotInfoArr;

% save(results_filename,'KEYFRAMES','keyframe_ref_array','cell_signals','polygon_list','-v7.3');
save(results_filename,'KEYFRAMES','cell_signals','polygon_list','-v7.3');

%
%%%
%%%%%
%%%
%