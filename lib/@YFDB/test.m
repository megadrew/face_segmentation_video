% This script is used to evaluate all models

% Parameters:

% this: reference to the YFDB object
% model: an instance of the Model class
% config: configuration setting

function this = test(this, model, config)

global yt_gt_dir;

global yt_tsp_dir;
global yt_temporal_edge_dir;
global global_model_dir;

%% For every fold, evaluate the model

fprintf('Evaluating test set for model: %s\n', model.model_type);

for foldid = 1:config.num_folds    
        
    % Retrieve parameters for this fold
    fold_params = this.params(foldid, :);
    output_metric_file = sprintf('%s/foldid_confusion_%d.mat', this.metric_dir, foldid);
        
    try
        %Try to load the metric file.  If it already exists, don't re-evaluate.
        load(output_metric_file, 'confusion');        
        
        this.confusionMatrix(:,:,:,:,foldid) = confusion;
        
        fprintf('Loading stored results for fold %d.\n', foldid);
        
        continue;
        
    catch ex
        fprintf('Evaluating fold %d.\n', foldid);
    end
    
    % Load the evaluation set
    fold_file = ['../folds/fold_' num2str(foldid) '.test' ];
    
    % Read in the parameters for this fold
    % names: list of names
    % id: list of ids
    % start_indices: contains the first frameid for each person.  
    % start_range: contains the first index of the labeled frames 
    % end_range: contains the last index of the labeled frames 
    [names ids start_indices start_ranges end_ranges] = textread(fold_file, '%s %d %d %d %d');          
        
    % Update model parameters
    model.update_params(fold_params, global_model_dir);      
    
    try 
        % Load the appropriate model
        model.load_model(foldid, config);
    catch ex
        ex.rethrow;
    end    
    
    clear confusion;
    clear X;
    
    %% Go through each name in the fold
        
    for i = 1:numel(names)    
        
        fprintf('%d : Name: %s, ID: %d \n', i, names{i}, ids(i));               
        
        offset = start_ranges(i) - start_indices(i);
        
        % Load the temporal edge features (if applicable)                       
        if model.use_temporal
            
            % Load temporal features            
            % temporal_edge_feats: temporal features for frames t>1.  For each frame, load
            % following:
            % * feats : for all sp in previous frame to current frame, give the color and texture
            % * adj : adjacency matrix of superpixels from previous frame into current frame
            feature_file = sprintf('%s/%s/%d/%s_%d_edge_feats.mat', yt_temporal_edge_dir, names{i}, ids(i), names{i}, ids(i));
            load(feature_file, 'temporal_edge_feats');
                        
            % Load the temporal superpixels (TSP)
            % using code from J. Chang, D. Wei, and J. W. F. III. A Video Representation Using Temporal Superpixels. In CVPR, 2013.
            % sp_labels: contains superpixel ids of each frame of size 250 x 250 x Num Frames
            tsp_file = sprintf('%s/%s/%s_%d_sp.mat', yt_tsp_dir, names{i}, names{i}, ids(i));
            load(tsp_file, 'sp_labels');
        end
        
        % Load the Ground Truth                        
        gt_casename = sprintf('%s/%s/%s_%d_gt.mat', yt_gt_dir, names{i}, names{i}, ids(i));
        load(gt_casename, 'gt_labels');
                
        %% Set up parameters for inference
                        
        if (model.use_temporal) || (model.use_crbm)
            % Store the label probability guesses from the previous frame
            old_labelprob = [];
            
            %Label frames from the beginning until the end of the chunk           
            start_t = -offset + 1;            
            end_t = config.chunk_size;            
        else
            % Since the model does not use any temporal features, label the chunk only
            start_t = 1;
            end_t = config.chunk_size;
        end
        
        if (model.use_crbm)
            % store the last W2 label guesses
            % because we can skip frames W2 = W * S
            history_samples = zeros(config.nn, config.num_labels, model.W2);
        end
                
        %% Perform Inference       
        
        for t=start_t:end_t
            
            fprintf('\tProcessing frame [%d/%d]\n', t, end_t);
                       
            %get the frame id
            frameid = start_ranges(i) + t - 1;
            
            % generate node features for this instance
            X = generate_node_feats(config, names{i}, ids(i), frameid, config.sds, config.esds);                        
            
            if (model.use_temporal)
                %compute temporal potential                 
                if (t > start_t)                    
                    % generate temporal features for this instance
                    [tpot1, tpot2] = generate_temporal_feats(model, config, offset, t, ...
                        temporal_edge_feats, old_labelprob, sp_labels, config.tsds);               
    
                    %weight the temporal potentials
                    X.tpot = model.kappa1 * tpot1 + model.kappa2 * tpot2;                    
                end
            end
            
            if (model.use_crbm)
                %compute CRBM potentials
                
                if (t > 0)                                        
                    % Compute features from history in the local neighborhood
                    X.history_samples = history_samples(:,:,1:model.S:model.W2);
                    X.history_feats = compute_history(X.history_samples, config.Q);
                end
            end
            
            % Perform inference.
            % By specifying 0, we're using defualt maximum number of iterations.            
            labelprob = model.inference(config, X, 0);
            
            % Store label probabilities for guesses if using temporal potentials
            if (model.use_temporal)                
                old_labelprob = labelprob;
            end
            
            % Store the "history" features if using CRBM potentials
            if (model.use_crbm)                                                
                
                % move previous 1..W-1 to the "left"
                history_samples(:,:,1:model.W2 - 1) = history_samples(:,:,2:end);
                
                % put newest guess at the rightmost place
                history_samples(:,:,model.W2) =  X.mapping_rbm * labelprob';
            end

            clear X;            
                                    
            % Only evaluate if it's within the chunk range
            if (t > 0) && (t <= config.chunk_size)
                
                % Perform evaluation
                gt_splabels = gt_labels{t + offset};
                [~, pred] = max(labelprob ,[], 1);
                
                % Compute Confusion Matrix
                confusion(:,:,t,i) = confusionmat(pred(:), gt_splabels(:));
            end
        end        
    end    
    
    % Save metrics for this fold    
    save(output_metric_file, 'confusion');
    
    this.confusionMatrix(:,:,:,:,foldid) = confusion;    
end
