function [] = update_cell_selection_dropdown(APP)
%% <placeholder>
%

polygon_list = getappdata(APP.MAIN,'polygon_list');
if isempty(polygon_list)
    
    S = cell(1);
    S{1} = 'N/A';
    
    APP.created_cell_selection.String = S;
    APP.created_cell_selection.Value = 1;
    APP.created_cell_selection.Enable = 'inactive';
    
    APP.cell_boundary_toggle.Enable = 'off';
    APP.cell_boundary_toggle.Value = 0;
    
else
    num_cells = size(polygon_list,1);
    S = cell(num_cells+1,1);
    S{1,1} = 'ALL';
    for i=1:num_cells
        if i < 10
            cell_str = char(strcat('Cell 0',num2str(i)));
            S{i + 1} = cell_str;
        else
            cell_str = char(strcat('Cell',{' '},num2str(i)));
        end
    end
    
    APP.created_cell_selection.String = S;
    APP.created_cell_selection.Value = 1;
    APP.created_cell_selection.Enable = 'on';
    
    APP.cell_boundary_toggle.Enable = 'on';
    APP.cell_boundary_toggle.Value = 1;
    
end

%
%%%
%%%%%
%%%
%