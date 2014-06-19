% Script to generate the node features

% Based off code from from http://vis-www.cs.umass.edu/GLOC/
 
% Parameters
%
% config: set of configuration parameters
% name: name of person
% id: id of person 
% frameid: frame in the video of the person
% sds: node scaling factors
% esds: edge scaling factors

% Return
%
% X: structure containing node, edge features, and mappings

function X = generate_node_feats(config, name, id, frameid, sds, esds);

global yt_features_dir;
global yt_spmat_dir;

% read superpixel features
[numNodes, H, E, S] = getFeaturesFrame(name, id, frameid, yt_features_dir);

X = struct('numNodes', numNodes, 'adjmat', {E}, 'nodeFeatures', {H}, 'edgeFeatures', {S});
[~, num_sp] = size(X.nodeFeatures);

% scale features
X.nodeFeatures(65:128,:) = [];
X.nodeFeatures = bsxfun(@rdivide,X.nodeFeatures,sds);
X.nodeFeatures(end+1,:) = 1;

[xe, ye] = find(X.adjmat > 0);
for j=1:length(xe)
    X.edgeFeatures{xe(j),ye(j)} = X.edgeFeatures{xe(j),ye(j)} ./ esds;
    X.edgeFeatures{xe(j),ye(j)}(end+1) = 1;
end

% read superpixel data
spfile = sprintf('%s/%s/%d/%s_%d.%d.dat', yt_spmat_dir, name, id, name, id, frameid);
sp = load(spfile) + 1;

% create projection matrices
[~, proj_sp] = create_mapping(sp, num_sp, config.dim_scrf, config.olddim);
[proj_block, ~] = create_mapping(sp,num_sp, config.dim_rbm, config.olddim);

X.mapping_scrf = proj_sp;
X.mapping_rbm = proj_block;
