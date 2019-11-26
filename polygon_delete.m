function [updated_polygon_list] = polygon_delete(polygon_list,del_idx)
%% fxn to delete polygon from relevant
% 

msgbox_string = strcat('Delete Cell #',num2str(del_idx),'?');
del_answer = questdlg(msgbox_string,'Delete Selected Cell','Yes','No','No');
del_comp = strcmp('Yes',del_answer);

if del_comp
	
	% remove cell
	num_cells = size(polygon_list,1);
	if del_idx == 1 && num_cells == 1
		% no more cells - revert relevant storage structures
		updated_polygon_list = [];
	else
		% removing one cell - update relevant structures
		updated_polygon_list = cell(num_cells-1,1);
		% CELL SIGNALS TOO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!!!!!!!!!!!!!!!!
		
		for i=1:size(polygon_list,1)
			if i < del_idx
				% insert into new struct @ same location
				updated_polygon_list{i} = polygon_list{i};
			elseif i > del_idx
				% insert into new struct @ (loc - 1)
				updated_polygon_list{i-1} = polygon_list{i};
			else
				% del_idx == i, do nothing
			end
		end
	end
	
else
	
	% return identical polygon list
	updated_polygon_list = polygon_list;

end

%
%%%
%%%%%
%%%
%