function [] = simple_settings_input(hand,evt,APP)
%% <placeholder>
% 
%  

APP_PARAM = getappdata(APP.MAIN,'APP_PARAM');

curr_frame_limit = APP_PARAM.FRAME_LIMIT;
curr_pix_off = APP_PARAM.NUM_PIX_OFF;
curr_pix_bg = APP_PARAM.NUM_PIX_BG;

prompt = {'Enter minimum frame limit:','Enter number of offset pixels','Enter number of background pixels'};
title = 'Simple settings call';
dims = [1 12];
definput = {num2str(curr_frame_limit),num2str(curr_pix_off),num2str(curr_pix_bg)};

answer = inputdlg(prompt,title,dims,definput);

if ~isempty(answer)
    new_frame_limit = answer{1};
    % setappdata(APP.MAIN,'FRAME_LIMIT',str2num(new_frame_limit));
    APP_PARAM.FRAME_LIMIT = str2num(new_frame_limit);
    new_pix_off = answer{2};
    % setappdata(APP.MAIN,'NUM_PIX_OFF',str2num(new_pix_off));
    APP_PARAM.NUM_PIX_OFF = str2num(new_pix_off);
    new_pix_bg = answer{3};
    % setappdata(APP.MAIN,'NUM_PIX_BG',str2num(new_pix_bg));
    APP_PARAM.NUM_PIX_BG = str2num(new_pix_bg);
    
    [process,~,~] = display_check(APP);
    if process == 1
        % in the middle of keyframe creation, rerun keyframe_handler w/ 
        % current settings
        keyframe_handler(APP.film_slider,1,APP);
    end
    
end

setappdata(APP.MAIN,'APP_PARAM',APP_PARAM);

%
%%%
%%%%%
%%%
%