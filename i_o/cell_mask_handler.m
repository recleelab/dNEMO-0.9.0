function [] = cell_mask_handler(hand, evt, APP)
%% callback function which handles importing mask data to application
%  
%  initiates process for user to select data to import to create
%  cellular masks, which are then converted into cell-polygon objects
%  and saved to the application.
%
%  if user cancels prompt to select import data, process returns without
%  creating cell-polygons / updating the polygon structure
%
%  INPUT: 
%  . hand -- (graphics object input handle) 
%  . evt -- (user click register event)
%  . APP -- (application structure)
%  
%  OUTPUT:
%  . None
%


valid_args = '*.tif;*.tiff;*.TIF;*.TIFF;*.csv;*.CSV;*.xls;*.xlsx';
[mask_filename, mask_folderpath, ~] = uigetfile(valid_args,'Select cell mask input image');
if mask_filename
    
    % need image data
    IMG = getappdata(APP.MAIN,'IMG');
    num_frames = IMG.T;
    
    switch hand.Label
        case 'Import Cell Mask CSV/XLS'
            [import_polygon_list] = import_mask_spreadsheet(mask_filename, mask_folderpath, num_frames);
        case 'Import Cell Mask TIFF'
            [import_polygon_list] = import_mask_tif(mask_filename, mask_folderpath, num_frames);
    end
    
    setappdata(APP.MAIN,'polygon_list',import_polygon_list);
    
    % update cell signals
    coordinate_spots_to_cells(APP);

    % update keyframing map
    APP.keyframing_map.Enable = 'on';
    update_keyframe_data(APP);

    % update cell selection
    update_cell_selection_dropdown(APP);

    % display call
    cla(APP.ax2);
    APP.cell_boundary_toggle.Value = 1;
    display_call(hand, 1, APP);
    
end

%
%%%
%%%%%
%%%
%