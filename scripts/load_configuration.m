% create a structure to store experiment parameters

function config = load_configuration

clear config;

% Number of labels for Hair/Skin/Background
config.num_labels = 3;

% how much LFW data to use?
config.append_train = 500;

% number of labeled frames per video
config.chunk_size = 11;

% 10 people per fold
config.num_names = 10;

% Number of folds
config.num_folds = 5;

% Original dimensions of image
config.olddim = 250;

% Pooling dimensions of the SCRF, RBM
config.dim_scrf = 16;
config.dim_rbm = 32;

% Number of visible units
config.nn = 1024;

% Number of node features
config.num_dim = 129;

% Size of local neighborhood to use for visible-visible interactions
config.Q = 3;

% Load the scaling parameters for the node and edge features.  
% Obtained using code from http://vis-www.cs.umass.edu/GLOC/index.html
load('sds_large.mat','sds');
load('esds_large.mat','esds');

% Remove the scaling factors for the position features since they are not used.
sds(65:128) = [];

% The scaling factors for the temporal features are reused from the edge scaling factors.
tsds = esds(2:3);

config.sds = sds;
config.esds = esds;
config.tsds = tsds;