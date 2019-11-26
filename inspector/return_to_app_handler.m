function [] = return_to_app_handler(hand,evt,INSPECT)
%% <placeholder>
%  

% need some level of user interaction to complete the issue - dlgbox prob

settings_struct = create_parameter_struct(INSPECT,2);
assignin('base','settings_struct',settings_struct);
% fields: paramIntensity, paramSize


% create msg
msg = {'Please confirm the following set parameters:',...
    strcat('Minimum signal intensity: ',num2str(settings_struct.paramIntensity(1,1))),...
    strcat('Maximum signal intensity: ',num2str(settings_struct.paramIntensity(1,2))),...
    strcat('Minimum signal size: ',num2str(settings_struct.paramSize(1,1))),...
    strcat('Maximum signal size: ',num2str(settings_struct.paramSize(1,2)))};
%{
msg = cell(1,5);
msg{1} = 'Please confirm the following set parameters:';
msg{2} = strcat('Minimum signal intensity:',{' '},num2str(settings_struct.paramIntensity(1,1)));
msg{3} = strcat('Maximum signal intensity:',{' '},num2str(settings_struct.paramIntensity(1,2)));
msg{4} = strcat('Minimum signal size:',{' '},num2str(settings_struct.paramSize(1,1)));
msg{5} = strcat('Maximum signal size:',{' '},num2str(settings_struct.paramSize(1,2)));
%}
first_answer = questdlg(msg,'Apply new parameters','Yes','No','Yes');

switch first_answer
    
    case 'Yes'
        % move forward
        all_or_one = 'Apply new parameters to ALL images within current keyframe, or ONLY this image?';
        second_answer = questdlg(all_or_one,'Apply new parameters','This image only','All images','Cancel','This image only');
        
        switch second_answer
            
            case 'This image only'
                
                setappdata(INSPECT.figure_handle,'param_struct',settings_struct);
                setappdata(INSPECT.figure_handle,'app_arg',1);
                INSPECT.figure_handle.Name = '';
                
                %{
                
                KEYFRAMES = getappdata(APP.MAIN,'KEYFRAMES');
                kf_ref_arr = getappdata(APP.MAIN,'keyframe_ref_array');
                current_keyframe = APP.keyframe_selection.Value;
                if current_keyframe == 0
                    % check for max in keyframe_ref_array
                    current_keyframe = max(kf_ref_arr(frame_no,:));
                end
                
                KF = KEYFRAMES{current_keyframe,1};
                curr_incl_excl = KF.incl_excl;
                
                new_incl_excl = inspector_incl_excl(INSPECT);
                
                curr_incl_excl{APP.film_slider.Value} = new_incl_excl;
                KF.incl_excl = curr_incl_excl;
                KEYFRAMES{current_keyframe,1} = KF;
                setappdata(APP.MAIN,'KEYFRAMES');
                
                % close up shop
                close(INSPECT);
            
            %}
            
            case 'All images'
                % apply to all images within a given keyframe
            
            case 'Cancel'
                % do nothing -- return
            
        end
    
    case 'No'
        % do nothing -- return
end

%
%%%
%%%%%
%%%
%