function [] = dnemo_results_to_excel(root_name, cell_arr)
%% <placeholder>
%

xls_answer = questdlg('Additionally save results file as xls/csv spreadsheet?',...
    'Save to Excel', 'Yes', 'No', 'No');
if strcmp(xls_answer, 'No')
    return
end

if ispc
    
    xls_filename = strcat(root_name,'.xls');
    
    spot_arr = cell_arr{1};
    spot_sheet = 'SPOTS';
    
    header = fieldnames(spot_arr).';
    print_mat = header;
    for frame_idx=1:length(spot_arr)
        tmp_mat = [];
        for field_idx=1:length(header)
            tmp_field = [spot_arr(frame_idx).(header{field_idx})];
            tmp_mat = cat(2, tmp_mat, tmp_field);
        end
        print_mat = cat(1, print_mat, num2cell(tmp_mat));
    end
    
    xlswrite(xls_filename, print_mat, spot_sheet);
    
    if len(cell_arr) > 1
        
        cells = cell_arr{2};
        if isempty(cells) || isempty(fieldnames(cells{1}))
            return;
        end
        for cell_idx=1:length(cells)
            
            tmp_struct = cells{cell_idx};
            cell_str = char(strcat('CELL #',num2str(cell_idx)));
            print_mat = header;
            
            for frame_idx=1:length(tmp_struct)
                tmp_mat = [];
                for field_idx=1:length(header)
                    tmp_field = [tmp_struct(frame_idx).(header{field_idx})];
                    tmp_mat = cat(2, tmp_mat, tmp_field);
                end
                print_mat = cat(1, print_mat, num2cell(tmp_mat));
            end
            % xlswrite(xls_filename, print_mat, cell_str);
        end
        
    end
    
else
    xls_filename = strcat(root_name,'.csv');
    spot_arr = cell_arr{1};
    header = fieldnames(spot_arr);
    
    print_mat = [];
    
    for frame_idx=1:length(spot_arr)
        tmp_mat = [];
        for field_idx=1:length(header)
            tmp_field = [spot_arr(frame_idx).(header{field_idx})];
            tmp_mat = cat(2, tmp_mat, tmp_field);
        end
        print_mat = cat(1, print_mat, tmp_mat);
    end
    
    csvwrite(xls_filename, print_mat);
    
end

%
%%%
%%%%%
%%%
%