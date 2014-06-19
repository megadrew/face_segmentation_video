% This file specifies directory paths to be used by the STRF package.  You should modify the paths
% for your own system.

%% General directory paths

addpath('../common');
addpath('../utils');
addpath(genpath('../lib'));

global root_dir;
 
% Main directory
root_dir = '/Users/drew/workspace/faces/segmentation/ytfaces/cvpr14_release/';

global global_model_dir;
global global_metric_dir;

% directory to store models
global_model_dir = [root_dir '/models_release/'];

if ~exist(global_model_dir)
    mkdir(global_model_dir);
end

% directory to store the metrics
global_metric_dir = [root_dir '/metrics_release/'];

if ~exist(global_metric_dir)
    mkdir(global_metric_dir);
end

%% Paths for features, ground truth, superpixels

global default_img_dir;
global yt_features_dir;
global yt_spmat_dir;
global yt_gt_dir;

global yt_tsp_dir;
global yt_temporal_edge_dir;

% Features
yt_features_dir = [root_dir '/data/yt_spseg_features/'];

% Superpixels
yt_tsp_dir = [root_dir '/data/tsp/'];

% Alternative representaiton of Superpixels
yt_spmat_dir = [root_dir '/data/tsp_mat/'];

% Ground Truth
yt_gt_dir = [root_dir '/data/gt/'];

% Temporal Features
yt_temporal_edge_dir = [root_dir '/data/temporal_edge_features/'];