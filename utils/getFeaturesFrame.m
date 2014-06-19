% Script to generate the node features

% Based off code from from http://vis-www.cs.umass.edu/GLOC/

% Parameters
%
% name: name of person
% id: id of person 
% frameid: frame in the video of the person
% features_dir: directory containing features

% Return
% 
% numNodes: number of superpixels in frame
% H: set of node features
% E: adjacency matrix
% S: set of edge features

function [numNodes H E S] = getFeaturesFrame(name, id, frameid, features_dir)
  ffn = sprintf('%s/%s/%d/%s_%d.%d.dat', features_dir, name, id, name, id, frameid);
  fidf = fopen(ffn);
  
  numNodes = fscanf(fidf, '%d', 1);
  numNodeFeatures = fscanf(fidf, '%d', 1);
  
  Hp = fscanf(fidf, '%f', [numNodeFeatures numNodes]);
  H = Hp(2:end,:);
  
  numEdges = fscanf(fidf, '%d', 1);
  numEdgeFeatures = fscanf(fidf, '%d', 1);
  E = sparse(numNodes, numNodes);
  S = cell(numNodes);
  
  for i=1:numEdges
    a = fscanf(fidf, '%d', 1)+1;
    b = fscanf(fidf, '%d', 1)+1;
    E(a,b) = 1;
    Sp = fscanf(fidf, '%f', numEdgeFeatures);
    S{a,b} = Sp(2:end);
  end
  
  fclose(fidf);
  

