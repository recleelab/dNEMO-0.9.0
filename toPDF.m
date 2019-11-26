function [] = toPDF(figure_handle,figure_filename)
%% <placeholder>
%

% manipulating printe elements for the pdf
figure_handle.Units = 'inches';
tmp_pos = figure_handle.Position;

figure_handle.PaperPositionMode = 'auto';
figure_handle.PaperUnits = 'inches';
figure_handle.PaperSize = [tmp_pos(3) tmp_pos(4)];

print(figure_handle,figure_filename,'-dpdf','-r0');
% delete(full_figure_handle);

%
%%%
%%%%%
%%%
%