function [] = get_image_info_display(hand, evt, APP)
%% <placeholder>
%

% pull current image from the application
IMG = getappdata(APP.MAIN,'TMP_IMG');
if isempty(IMG)
    return;
end

current_Z = IMG.getZ();
current_T = IMG.getT();
current_C = IMG.getC();

% populate small gui displaying image data
D.fig = figure('units','normalized',...
               'position',[0.425 0.3 0.15 0.4],...
               'menubar','none',...
               'name','Image Information',...
               'numbertitle','off',...
               'resize','on');
%
D.current_z_label = uicontrol('style','text',...
                              'units','normalized',...
                              'parent',D.fig,...
                              'position',[0.05 0.86 0.4 0.1],...
                              'string','Image Z:');
%
D.current_z_display = uicontrol('style','edit',...
                                'units','normalized',...
                                'parent',D.fig,...
                                'position',[0.55 0.86 0.4 0.1],...
                                'enable','on',...
                                'visible','on',...
                                'string',num2str(current_Z));
%
D.current_c_label = uicontrol('style','text',...
                              'units','normalized',...
                              'parent',D.fig,...
                              'position',[0.05 0.72 0.4 0.1],...
                              'string','Image C:');
%
D.current_c_display = uicontrol('style','edit',...
                                'units','normalized',...
                                'parent',D.fig,...
                                'position',[0.55 0.72 0.4 0.1],...
                                'enable','on',...
                                'visible','on',...
                                'string',num2str(current_C));
%
D.current_t_label = uicontrol('style','text',...
                                'units','normalized',...
                                'parent',D.fig,...
                                'position',[0.05 0.58 0.4 0.1],...
                                'string','Image T:');
%
D.current_t_display = uicontrol('style','edit',...
                                'units','normalized',...
                                'parent',D.fig,...
                                'position',[0.55 0.58 0.4 0.1],...
                                'string',num2str(current_T));
%

%
%%%
%%%%%
%%%
%