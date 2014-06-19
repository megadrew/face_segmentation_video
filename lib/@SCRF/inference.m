% Inference method for SCRF
% From http://vis-www.cs.umass.edu/GLOC/

% if flag = 0, mean-field didn't converge, no update
% if flag = 1, mean-field converged, update

function [mu, flag] = inference(this, config, X, nMF)

if ~exist('nMF','var') || nMF == 0,
    nMF = 200;
end

proj = X.mapping_scrf;

% node potential
mu_node = zeros(config.num_labels, X.numNodes);
for ni = 1:size(this.weights.nodeWeights,2),
    mu_node(ni,:) = sum(X.nodeFeatures.*(squeeze(this.weights.nodeWeights(:,ni,:))*proj),1);
end

% initialize with logistic regression
mu_max = max(mu_node,[],1);
mu = bsxfun(@rdivide,exp(bsxfun(@minus,mu_node,mu_max)),sum(exp(bsxfun(@minus,mu_node,mu_max)),1));

if ~isfield(X,'edgeFeaturesrs'),
    [xi, xj] = find(X.adjmat > 0);
    edgeFeaturesrs = zeros(size(this.weights.edgeWeights,1),1,1,length(xi));
    for j = 1:length(xi),
        edgeFeaturesrs(:,:,:,j) = X.edgeFeatures{xi(j), xj(j)};
    end
    X.edgeFeaturesrs = edgeFeaturesrs;
end

% edge potential (preprocess)
[xi, xj] = find(X.adjmat > 0);
edgeFeat = zeros(config.num_labels, config.num_labels,X.numNodes,X.numNodes);
for ei = 1:X.numNodes,
    edgeFeat(:,:,ei,xj(xi == ei)) = reshape(sum(bsxfun(@times,X.edgeFeaturesrs(:,:,:,xi == ei),this.weights.edgeWeights),1),config.num_labels,config.num_labels,1,sum(xi == ei));
    edgeFeat(:,:,ei,xi(xj == ei)) = reshape(sum(bsxfun(@times,X.edgeFeaturesrs(:,:,:,xj == ei),this.weights.edgeWeights),1),config.num_labels,config.num_labels,1,sum(xj == ei));
end

edgeFeat = permute(edgeFeat,[1 3 2 4]);
edgeFeat = reshape(edgeFeat,size(edgeFeat,1)*size(edgeFeat,2),size(edgeFeat,3)*size(edgeFeat,4));

flag = 0;
% mean-field iteration (full block)
mu_old = mu;
for nmf = 1:nMF,
   
    mu = mu_node + reshape(edgeFeat*mu(:),config.num_labels,size(edgeFeat,1)/config.num_labels);
    
    mu_max = max(mu,[],1);
    mu = bsxfun(@rdivide,exp(bsxfun(@minus,mu,mu_max)),sum(exp(bsxfun(@minus,mu,mu_max)),1));
    err = norm(mu(:) - mu_old(:));
    if err < 1e-4,
        flag = 1;
        break;
    else
        mu_old = mu;
    end
end
