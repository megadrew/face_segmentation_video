% This script is used to write a report containing various metrics for the given model.

% In particular, the following metrics are computed, along with their Standard Error of Mean (SEM).

% Overall Accuracy
% Reduction in Error
% 
% Hair Accuracy
% Skin Accuracy
% BG Accuracy
% 
% Category Avg

% Parameters:

% this: reference to the YFDB object
% model_type: string identifying the model type
% config: configuration setting

function report_metrics(this, model_type, config)

fprintf('Reporting metrics.\n');

metric_output_file = sprintf('%s/%s.txt', this.metric_dir, model_type);

fid = fopen(metric_output_file, 'w');

fprintf(fid, 'Metrics for model %s\n', model_type);
fprintf(fid, '-----------------------------------\n');

% Sum across all folds, people, frames to get an LxL confusion matrix.
agg_confusion = sum(sum(sum(this.confusionMatrix, 5),4),3);

%% Overall Accuracy

% Compute mean accuracy and standard error
overall_means = zeros(config.num_folds, 1);
overall_errors = zeros(config.num_folds, 1);

for foldid=1:config.num_folds
    % Sum across all people, frames to get an LxL confusion matrix for this foldid
    conf = sum(sum(this.confusionMatrix(:,:,:,:,foldid), 4), 3);
    
    overall_means(foldid) = sum(diag(conf)) / sum(conf(:));
end

clear overall;

overall.mean_acc = mean(overall_means);
overall.std_err = std(overall_means) / sqrt(config.num_folds);

fprintf(fid, 'Overall Mean Accuracy: %0.3f, Standard Error of Mean (SEM): %0.3f\n', overall.mean_acc, overall.std_err);

%% Compute the error reduction

% Store the error of the SCRF, to compare against other models
base_file = sprintf('%s/../scrf/scrf_base.mat', this.metric_dir);

if strcmp(model_type, 'scrf')
    base_err = 1 - overall_means;
    
    %save it
    save(base_file, 'base_err');
else
    %load it
    load(base_file, 'base_err');
end

reduction_means = (base_err - (1 - overall_means)) ./ base_err;

clear reduction;

reduction.mean = mean(reduction_means);
reduction.std_err = std(reduction_means) / sqrt(config.num_folds);

fprintf(fid, 'Mean Reduction in Error: %0.3f, Standard Error of Mean (SEM): %0.3f\n', reduction.mean, reduction.std_err);

%% Per-Category metrics

classes{1} = 'Hair';
classes{2} = 'Skin';
classes{3} = 'BG';

clear category;

for c=1:config.num_labels
    correct = agg_confusion(c,c);
    total = sum(agg_confusion(:,c));
    
    category(c).acc = correct / total;        
end

category_means = zeros(config.num_folds, 3);
category_errors = zeros(config.num_folds, 3);

fprintf(fid, '\n');

for c=1:3
    
    for foldid=1:config.num_folds
        % Sum across all people, frames to get an LxL confusion matrix for this foldid
        conf = sum(sum(this.confusionMatrix(:,:,:,:,foldid), 4), 3);
        
        correct = conf(c,c);
        total = sum(conf(:,c));
        
        category_means(foldid, c) = correct / total;
    end
    
    category(c).mean_acc = mean(category_means(:,c));
    category(c).std_err = std(category_means(:,c)) / sqrt(config.num_folds);
    
    fprintf(fid, '%s: Mean Accuracy: %0.3f, Standard Error of mean (SEM): %0.3f\n', classes{c}, category(c).mean_acc, category(c).std_err);
end

%% Category Average

cat_avg_means = mean(category_means, 2);

clear cat_avg;

cat_avg.mean_acc = mean(cat_avg_means);
cat_avg.std_err = std(cat_avg_means) / sqrt(config.num_folds);

fprintf(fid, '\nAvg Mean Accuracy: %0.3f,  Standard Error of mean (SEM): %0.3f\n', cat_avg.mean_acc, cat_avg.std_err);