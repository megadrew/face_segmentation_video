% Computes the LxL confusion matrix for the given set of guesses and ground truth.

% Parameters:
% * pred: guesses
% * gt: ground truth
% * (optional) L: number of labels

function confusion = confusionmat(pred, gt, L)

if ~exist('L','var')    
    L = 3;
end

confusion = zeros(L,L);

for i=1:L
    guesses = find(pred == i);
    
    for j=1:L
        actual = find(gt == j);
        
        confusion(i,j) = numel(intersect(guesses, actual));
    end
end