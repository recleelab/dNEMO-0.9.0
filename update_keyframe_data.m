function [] = update_keyframe_data(APP)
%% <placeholder>
%

APP.keyframing_map.FontWeight = 'bold';

kf_string = {'Collapse All'};

% pull spot data
spot_detect = getappdata(APP.MAIN,'spot_detect');
if ~isempty(spot_detect)
    [spot_strings] = pull_spot_strings(spot_detect);
    kf_string = cat(1,kf_string,spot_strings);
end

% pull param data
if ~isempty(spot_detect)
    [param_strings] = pull_param_strings(spot_detect);
    kf_string = cat(1,kf_string,param_strings);
end

% pull manual curation data
if ~isempty(spot_detect)
    [man_cur_strings] = pull_curation_strings(spot_detect);
    kf_string = cat(1,kf_string,man_cur_strings);
end

% pull cell data
polygon_list = getappdata(APP.MAIN,'polygon_list');
if ~isempty(polygon_list)
    [cell_strings] = pull_cell_strings(polygon_list);
    kf_string = cat(1,kf_string,cell_strings);
end

% reassign string set to keyframing map
APP.keyframing_map.String = kf_string;

% assign callback
APP.keyframing_map.Callback = {@keyframing_map_call, APP};

if length(APP.keyframing_map.String)==1
    APP.keyframing_map.Value = 1;
end

if APP.keyframing_map.Value > length(APP.keyframing_map.String)
    APP.keyframing_map.Value = 1;
end

%
%%%
%%%%%
%%%
%

function [spot_strings] = pull_spot_strings(spot_detect)
%% <placeholder>
%

spot_strings = {'[+] SPOTS'};
% keyframe_strings = spot_detect.getKeyframeDescriptions();
% spot_strings = cat(1,spot_strings,keyframe_strings);

%
%%%
%%%%%
%%%
%

function [param_strings] = pull_param_strings(spot_detect)
%% <placeholder>
%

param_strings = {'[+] PARAMETERS'};

%
%%%
%%%%%
%%%
%

function [man_cur_strings] = pull_curation_strings(spot_detect)
%% <placeholder>
%

man_cur_strings = {'[+] MANUAL_CURATION'};

%
%%%
%%%%%
%%%
%

function [cell_strings] = pull_cell_strings(polygon_list)
%% <placeholder>
%
cell_strings = {};
for poly_idx=1:length(polygon_list)
    if poly_idx < 10
        num_token = strcat('0',num2str(poly_idx));
    else
        num_token = num2str(poly_idx);
    end
    new_string = strcat('[+] CELL',{' '},num_token);
    cell_strings = cat(1,cell_strings,new_string);
end

%
%%%
%%%%%
%%%
%

function [] = keyframing_map_call(hand, evt, APP)
%% <placeholder>
%

kf_strings = hand.String;
curr_sel = hand.Value;
curr_string = kf_strings{curr_sel};

if strcmp(curr_string,'Collapse All')
    
    % iterate through the keyframe strings, collapsing all w/ token '[-]'
    logically_remove = zeros(length(kf_strings),1);
    within_removal = 0;
    for ii=2:length(kf_strings)
        if within_removal
            % check to make sure current string doesn't have +, -
            if contains(kf_strings{ii},{'[+]','[-]'})
                within_removal = 0;
            else
                logically_remove(ii) = 1;
            end
        end
        % check
        if contains(kf_strings{ii},'[-]')
            kf_tokens = strsplit(kf_strings{ii},' ');
            tmp_str = '[+]';
            for tok_idx=2:length(kf_tokens)
                tmp_str = strcat(tmp_str,{' '},kf_tokens{tok_idx});
            end
            kf_strings{ii} = char(tmp_str);
            within_removal = 1;
        end
    end
    
    kf_strings(logical(logically_remove)) = [];
    hand.String = kf_strings;
    
    APP.created_cell_selection.Value = 1;
    display_call(APP.film_slider, 1, APP);
    
end

kf_tokens = strsplit(curr_string,' ');

if contains(kf_tokens{1},'+')
    % check next token
    switch kf_tokens{2}
        case 'CELL'
            
            % check next token
            cell_idx = str2num(kf_tokens{3});
            
            polygon_list = getappdata(APP.MAIN,'polygon_list');
            curr_cell = polygon_list{cell_idx};
            
            adj_mat = curr_cell.pseudoAdjMatrix;
            % [~,frames,~] = unique(adj_mat(1,:));
            frames = find(adj_mat(2,:));
            frame_strings = {};
            
            for frame_idx=1:length(frames)
                frame_strings = cat(1,frame_strings,strcat('    >Frame',num2str(frames(frame_idx)),'_cell_modified'));
            end
            
            % update strings
            kf_strings{curr_sel} = char(strcat('[-]',{' '},kf_tokens{2},{' '},kf_tokens{3}));
            if curr_sel ~= length(kf_strings)
                kf_strings = cat(1,kf_strings(1:curr_sel),frame_strings,kf_strings(curr_sel+1:end));
            else
                kf_strings = cat(1,kf_strings,frame_strings);
            end
            
            assignin('base','tmp_strs',kf_strings);
            
            hand.String = kf_strings;
            
            % update uimenu
            update_mapping_selection_menu(hand, APP);
        
        case 'SPOTS'
            spot_detect = getappdata(APP.MAIN,'spot_detect');
            spot_kf_strings = spot_detect.getKeyframeDescriptions();
            % spot_feat_strings = spot_detect.pullFeatureKeyframeStrings();
            kf_strings{curr_sel} = char(strcat('[-]',{' '},kf_tokens{2}));
            if curr_sel ~= length(kf_strings)
                % kf_strings = cat(1,kf_strings(1:curr_sel),spot_kf_strings,spot_feat_strings,kf_strings(curr_sel+1:end));
                kf_strings = cat(1,kf_strings(1:curr_sel),spot_kf_strings,kf_strings(curr_sel+1:end));
            else
                % kf_strings = cat(1,kf_strings,spot_kf_strings,spot_feat_strings);
                kf_strings = cat(1,kf_strings,spot_kf_strings);
            end
            
            hand.String = kf_strings;
            
            % update uimenu
            update_mapping_selection_menu(hand, APP);
    
        case 'PARAMETERS'
            spot_detect = getappdata(APP.MAIN,'spot_detect');
            param_strings = spot_detect.getParamDescriptions();
            kf_strings{curr_sel} = char(strcat('[-]',{' '},kf_tokens{2}));
            if curr_sel ~= length(kf_strings)
                kf_strings = cat(1,kf_strings(1:curr_sel),param_strings,kf_strings(curr_sel+1:end));
            else
                kf_strings = cat(1,kf_strings,param_strings);
            end
            
            hand.String = kf_strings;
            
            % update uimenu
            update_mapping_selection_menu(hand, APP);
            
        case 'MANUAL_CURATION'
            spot_detect = getappdata(APP.MAIN,'spot_detect');
            man_cur_strings = spot_detect.pullFeatureKeyframeStrings();
            kf_strings{curr_sel} = char(strcat('[-]',{' '},kf_tokens{2}));
            if curr_sel ~= length(kf_strings)
                kf_strings = cat(1,kf_strings(1:curr_sel),man_cur_strings,kf_strings(curr_sel+1:end));
            else
                kf_strings = cat(1,kf_strings,man_cur_strings);
            end
            
            hand.String = kf_strings;
    end
    
end

if contains(kf_tokens{1},'-')
    
    % remove all tokens w/in heading
    switch kf_tokens{2}
        case 'CELL'
            % increment past curr value
            final_entry = curr_sel;
            for entry_idx=curr_sel+1:length(kf_strings)
                if contains(kf_strings{entry_idx},'>')
                    final_entry = entry_idx;
                else
                    break;
                end
            end
            
            kf_strings{curr_sel} = char(strcat('[+]',{' '},kf_tokens{2},{' '},kf_tokens{3}));
            kf_strings(curr_sel+1:final_entry) = [];
            
            hand.String = kf_strings;
        
        case 'SPOTS'
            % increment past curr value
            final_entry = curr_sel;
            for entry_idx=curr_sel+1:length(kf_strings)
                if contains(kf_strings{entry_idx},'>')
                    final_entry = entry_idx;
                else
                    break;
                end
            end
            
            kf_strings{curr_sel} = char(strcat('[+]',{' '},kf_tokens{2}));
            kf_strings(curr_sel+1:final_entry) = [];
            
            hand.String = kf_strings;
            
            % update uimenu
            update_mapping_selection_menu(hand, APP);
            
        case 'PARAMETERS'
            % increment past curr value
            final_entry = curr_sel;
            for entry_idx=curr_sel+1:length(kf_strings)
                if contains(kf_strings{entry_idx},'>')
                    final_entry = entry_idx;
                else
                    break;
                end
            end
            
            kf_strings{curr_sel} = char(strcat('[+]',{' '},kf_tokens{2}));
            kf_strings(curr_sel+1:final_entry) = [];
            
            hand.String = kf_strings;
            
            % update uimenu
            update_mapping_selection_menu(hand,APP);
        
        case 'MANUAL_CURATION'
            % increment past curr value
            final_entry = curr_sel;
            for entry_idx=curr_sel+1:length(kf_strings)
                if contains(kf_strings{entry_idx},'>')
                    final_entry = entry_idx;
                else
                    break;
                end
            end
            
            kf_strings{curr_sel} = char(strcat('[+]',{' '},kf_tokens{2}));
            kf_strings(curr_sel+1:final_entry)=[];
            
            hand.String = kf_strings;
            
            % update uimenu
            update_mapping_selection_menu(hand,APP);
                
    end
    
end

if contains(curr_string,'>')
    % update uimenu
    update_mapping_selection_menu(hand, APP);
end

%
%%%
%%%%%
%%%
%

function [] = update_mapping_selection_menu(hand, APP)
%% <placeholder>
%

curr_frame = APP.film_slider.Value;
curr_str = hand.String{hand.Value};

if contains(curr_str,'[+]') || contains(curr_str,'[-]')
    
    str_tokens = strsplit(curr_str,' ');
    switch str_tokens{2}
        case 'CELL'
    
            cell_edit_menu = uicontextmenu();
            modify_cell = uimenu('Parent',cell_edit_menu,'Label','Modify Cell',...
                                'callback',{@polygon_modify,APP});
            delete_cell = uimenu('Parent',cell_edit_menu,'Label','Delete Cell',...
                                'callback',{@polygon_remove,APP});
            hand.UIContextMenu = cell_edit_menu;
            
            cell_idx = str2num(str_tokens{3});
            APP.created_cell_selection.Value = cell_idx+1;
            APP.modify_cell_button.Enable = 'on';
            display_call(APP.created_cell_selection, 1, APP);
            
        case 'SPOTS'
            spot_edit_menu = uicontextmenu();
            modify_spots = uimenu('Parent',spot_edit_menu,'Label','Modify Spot Detection',...
                'callback',{@spot_detect_modify});
            hand.UIContextMenu = spot_edit_menu;
        
        case 'PARAMETERS'
            inspector_menu = uicontextmenu();
            bg_inspector = uimenu('Parent',inspector_menu,'Label','Modify Background Collection Parameters',...
                'callback',{@inspector_call,APP});
            bg_kf_delete = uimenu('Parent',inspector_menu,'Label','Delete Background Collection Parameters',...
                'callback',{@delete_bkgd_param_keyframe,APP});
            hand.UIContextMenu = inspector_menu;
            
    end
end

if contains(curr_str,'>')
    
    % move up to confirm whether it's spots, feature, etc.
    if contains(curr_str,'cell_modified')
    
        cell_edit_menu = uicontextmenu();
        modify_cell = uimenu('Parent',cell_edit_menu,'Label','Modify Cell Keyframe',...
                            'callback',{@polygon_modify,APP});
        delete_cell = uimenu('Parent',cell_edit_menu,'Label','Delete Cell Keyframe',...
                            'callback',{@polygon_remove,APP});
        hand.UIContextMenu = cell_edit_menu;
    
        str_tokens = strsplit(curr_str,'_');
        frame_string = str_tokens{1};
        some_str_loc = strfind(frame_string,'>');
        sub_str = frame_string(some_str_loc+6:end);
        frame_no = str2num(char(sub_str));
        APP.film_slider.Value = frame_no;
    
        display_call(APP.film_slider,1,APP);
    end
    
    if contains(curr_str,{'MEAN','MEDIAN','SUM','SIZE','MAX'})
        feat_sel_menu = uicontextmenu();
        delete_feat = uimenu('Parent',feat_sel_menu,'Label','Delete Feature Keyframe',...
            'callback',{@delete_feature_sel_keyframe,APP});
        hand.UIContextMenu = feat_sel_menu;
        
        str_tokens = strsplit(curr_str,'_');
        frame_string = str_tokens{1};
        some_str_loc = strfind(frame_string,'>');
        sub_str = frame_string(some_str_loc+6:end);
        frame_no = str2num(char(sub_str));
        APP.film_slider.Value = frame_no;
    
        display_call(APP.film_slider,1,APP);
        
    end
    
    if contains(curr_str,'offset_') || contains(curr_str,'pixel_')
        inspector_menu = uicontextmenu();
        bg_inspector = uimenu('Parent',inspector_menu,'Label','Modify Background Parameter Keyframe',...
            'callback',{@inspector_call,APP});
        bg_deletion = uimenu('Parent',inspector_menu,'Label','Delete Background Parameter Keyframe',...
            'callback',{@delete_bkgd_param_keyframe,APP});
        hand.UIContextMenu = inspector_menu;
        str_tokens = strsplit(curr_str,'_');
        frame_string = str_tokens{1};
        some_str_loc = strfind(frame_string,'>');
        sub_str = frame_string(some_str_loc+6:end);
        frame_no = str2num(char(sub_str));
        APP.film_slider.Value = frame_no;
    
        display_call(APP.film_slider,1,APP);
    end
    
    if contains(curr_str,{'wavelet','oversegmentation','axial_minimum'})
        delete_param_menu = uicontextmenu();
        spot_delete_param = uimenu('Parent',delete_param_menu,'Label','Delete Spot Detection Param Keyframe',...
            'callback',{@delete_spot_detect_keyframe,APP});
        hand.UIContextMenu = delete_param_menu;
        str_tokens = strsplit(curr_str,'_');
        frame_string = str_tokens{1};
        some_str_loc = strfind(frame_string,'>');
        sub_str = frame_string(some_str_loc+6:end);
        frame_no = str2num(char(sub_str));
        APP.film_slider.Value = frame_no;
    
        display_call(APP.film_slider,1,APP);
    end
    
    if contains(curr_str,{'exclusion'})
        delete_excl_menu = uicontextmenu();
        delete_excl_kf = uimenu('parent',delete_excl_menu,'Label','Delete Exclusion Set',...
            'callback',{@delete_exclusion_keyframe_data, APP});
        hand.UIContextMenu = delete_excl_menu;
        str_tokens = strsplit(curr_str,'_');
        frame_string = str_tokens{1};
        some_str_loc = strfind(frame_string,'>');
        sub_str = frame_string(some_str_loc+6:end);
        frame_no = str2num(char(sub_str));
        APP.film_slider.Value = frame_no;
        
        display_call(APP.film_slider,1,APP);
    end
    
end



%
%%%
%%%%%
%%%
%