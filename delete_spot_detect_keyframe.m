function [] = delete_spot_detect_keyframe(hand, evt, APP)
%% <placeholder>
%

spot_detect = getappdata(APP.MAIN,'spot_detect');
sel_string = APP.keyframing_map.String{APP.keyframing_map.Value};

[removal_flag, removal_des] = spot_detect.checkRemovalProp(sel_string);
if ~removal_flag
    % safe to remove, still check w/ user because operation is tough
    init_string = strcat('Warning. Deleting indicated keyframe will revert',...
        {' '},'current detection settings to previous spot detection keyframe.',...
        {' '},'All manual exclusions / inclusions for the current keyframe will',...
        {' '},'be deleted. Do you wish to continue?');
    answer = questdlg(init_string, 'Spot Detection Parameter Update',...
        'Yes','No','No');
    switch answer
        case 'Yes'
            IMG = getappdata(APP.MAIN,'IMG');
            spot_detect = spot_detect.removeSpotParam(removal_des, IMG, sel_string);
            
            setappdata(APP.MAIN,'spot_detect',spot_detect);
            % create new overlay object
            
            
        case 'No'
            % DO NOTHING
    end
    
    update_keyframe_data(APP);
    display_call(APP.film_slider, 1, APP);
    
else
    % removal will delete spots, confirm with user
    init_string = strcat('Warning. Deleting indicated keyframe will delete',...
            {' '},'currently detected spots. All related information (spot',...
            {' '},'detection settings, manual curations, etc.) will be deleted.',...
            {' '},'Do you wish to continue?');
        
    answer = questdlg(init_string, 'Spot Detection Parameter Update',...
        'Yes','No','No');
    switch answer
        case 'Yes'
            setappdata(APP.MAIN,'spot_detect',[]);
            setappdata(APP.MAIN,'OVERLAY',[]);
            setappdata(APP.MAIN,'cell_signals',{});
        case 'No'
            % DO NOTHING
    end
    
    update_keyframe_data(APP);
    display_call(APP.film_slider,1,APP);

end


%
%%%
%%%%%
%%%
%