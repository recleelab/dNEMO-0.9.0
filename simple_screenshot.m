function [] = simple_screenshot(hand, evt, ax_handle)
%% <placeholder>
%

% get current parent
figure_parent = ax_handle.Parent;

% get current position
norm_pos = ax_handle.Position;

% create new figure
tmp_fig = figure('units','normalized');

% assign axis to new figure
ax_handle.Parent = tmp_fig;
ax_handle.Position = [0.2 0.2 0.6 0.6];

% get output filename from user
[output_filename, output_filepath] = uiputfile('*');
prev_dir = cd(output_filepath);
toPDF(tmp_fig,output_filename);
cd(prev_dir);

% redo dimensions
ax_handle.Position = norm_pos;
ax_handle.Parent = figure_parent;

% cleanup
delete(tmp_fig);

%
%%%
%%%%%
%%%
%