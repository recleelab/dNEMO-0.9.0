function [kf_param_struct, kf_thresh, kf_range] = pull_kf_param(KF)
%% <placeholder>
%

kf_param_struct = struct;

% pull frame limit
kf_param_struct.FRAME_LIMIT = KF.FrameLim;
kf_param_struct.WAV_LEVEL = 2;
kf_param_struct.OVERSEG = 1;
kf_param_struct.NUM_PIX_OFF = 1;
kf_param_struct.NUM_PIX_BG = 1;
kf_param_struct.INT_MEASURE = 'MEAN';

kf_thresh = KF.Threshold;
kf_range = [KF.KF_START KF.KF_END];

%{
APP_PARAM = struct;
APP_PARAM.WAV_LEVEL = 2;
APP_PARAM.FRAME_LIMIT = 2;
APP_PARAM.OVERSEG = 1;
APP_PARAM.NUM_PIX_OFF = 1;
APP_PARAM.NUM_PIX_BG = 1;
APP_PARAM.INT_MEASURE = 'MEAN';
%}

%
%%%
%%%%%
%%%
%