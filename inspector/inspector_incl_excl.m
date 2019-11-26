function [incl_excl] = inspector_incl_excl(INSPECT)
%% <placeholder>
%  

% grab relevant structures from INSPECT
intensity_info = getappdata(INSPECT.figure_handle,'hist_data');
size_info = getappdata(INSPECT.figure_handle,'size_info');

% prepare incl_excl logic array
init_incl_excl = ones(size(intensity_info,1),2);

% intensity
% min_int = str2num(INSPECT.min_intensity_box.String);
init_incl_excl(intensity_info > str2num(INSPECT.max_intensity_box.String),1) = 0;
init_incl_excl(intensity_info < str2num(INSPECT.min_intensity_box.String),1) = 0;

% size
init_incl_excl(size_info > str2num(INSPECT.max_size_box.String),2) = 0;
init_incl_excl(size_info < str2num(INSPECT.min_size_box.String),2) = 0;

% multiply one row by the other, turn logical
incl_excl = logical(init_incl_excl(:,1).*init_incl_excl(:,2));

%
%%%
%%%%%
%%%
%