function [] = spot_detect_modify(hand, evt, APP)
%% <placeholder>
%

% basically app_setup, only make sure everything's already assigned the
% proper callbacks
APP.quick_detect_button.Enable = 'on';
APP.full_detect_button.Enable = 'on';

APP.create_keyframe_button.Enable = 'on';
APP.create_keyframe_button.Callback = {@create_spot_info_struct, APP};

%
%%%
%%%%%
%%%
%