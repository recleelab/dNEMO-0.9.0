function [] = return_to_app(hand, evt, APP)
%% <placeholder>
%

switch hand
    case APP.cancel_keyframe_button
        setappdata(APP.figure_handle,'apply_kf_arg',0);
    case APP.create_keyframe_button
        setappdata(APP.figure_handle,'apply_kf_arg',1);
end
APP.figure_handle.Name = '';

%
%%%
%%%%%
%%%
%