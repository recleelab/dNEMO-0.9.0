function [updated_polygon_list] = polygon_insert(polygon_list,new_polygon,insertion_pt)
%% fxn for insertion of polygon into existing data structure
%  

% disp(strcat('new polygon index is',{' '},num2str(insertion_pt)));

if isempty(polygon_list)
	polygon_list = cell(1);
	polygon_list{1,1} = new_polygon;
	updated_polygon_list = polygon_list;
else
	if insertion_pt > size(polygon_list,1)
		updated_polygon_list = cell(insertion_pt,1);
		updated_polygon_list(1:size(polygon_list,1),1) = polygon_list(:,1);
		updated_polygon_list{insertion_pt,1} = new_polygon;
	else
		% replacing existing polygon w/ updated polygon
		polygon_list{insertion_pt,1} = new_polygon;
		updated_polygon_list = polygon_list;
	end
end

% 


