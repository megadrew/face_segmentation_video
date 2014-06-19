% Script to generate temporal features

% Parameters
%
% model: current model
% config: set of configuration parameters
% offset: offset in the video
% t: time
% temporal_edge_feats: temporal features from previous frame
% old_labelprob: previous label guess
% sp_labels: superpixel ids
% tsds: scaling factor for temporal features

% Return
%
% tpot1, tpot2: temporal potentials

function [tpot1, tpot2] = generate_temporal_feats(model, config, offset, t, temporal_edge_feats, ...
    old_labelprob, sp_labels, tsds)

% prepare temporal edges from previous frame
[xi, xj] = find(temporal_edge_feats{offset+t}.adj > 0);
edgeFeaturesrs = zeros(size(model.weights.tedgeWeights,1),1,1,length(xi));

% scale the features by the tsds
for j = 1:length(xi)
    edgeFeaturesrs(1:2,:,:,j) = squeeze(temporal_edge_feats{offset+t}.feats(xi(j), xj(j),:)) ./ tsds;
    edgeFeaturesrs(3,:,:,j) = 1;
end

[num_curr_tsp, num_prev_tsp] = size(temporal_edge_feats{offset+t}.adj);

edgeFeat = zeros(config.num_labels,config.num_labels,num_curr_tsp, num_prev_tsp);

% Compute temporal edge potentials
for ei = 1:num_curr_tsp
    % for all nodes connected to node ei
    % multiply in all the edge features and weights from previous time step,
    % for the corresponding TSP in the previous frame.
    edgeFeat(:,:,ei,xj(xi == ei)) = reshape(sum(bsxfun(@times,edgeFeaturesrs(:,:,:,xi == ei),model.weights.tedgeWeights),1),config.num_labels,config.num_labels,1,sum(xi == ei));
end

edgeFeat = permute(edgeFeat,[1 3 2 4]);
edgeFeat = reshape(edgeFeat,size(edgeFeat,1)*size(edgeFeat,2),size(edgeFeat,3)*size(edgeFeat,4));

% reformat the potential -- Position smoothness
tpot1 = reshape(edgeFeat*old_labelprob(:),config.num_labels,size(edgeFeat,1)/config.num_labels);

% Compute temporal potentials ONLY for the same TSP -- superpixel smoothness

% Find any TSPs in previous frame that match some TSPs in current frame.
old_tspids = unique(sp_labels(:,:,offset+t-1));
current_tspids = unique(sp_labels(:,:,offset+t));

common_tspids = intersect(old_tspids, current_tspids);

old_indices = find(ismember(old_tspids, common_tspids));
new_indices = find(ismember(current_tspids, common_tspids));

tpot2 = zeros(3, numel(current_tspids));

tpot2(:,new_indices) = old_labelprob(:,old_indices);
