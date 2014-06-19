% This class is used to run experiments for all models.

classdef YFDB < handle   
    
	properties (SetAccess = private)
        
        % the confusion matrix of the experiment results
        confusionMatrix;
        
        % directory in which to store experiment results
        metric_dir;
                               
        % parameters
        params;
        
    end
       
    methods
        
        % Constructor
        function this = YFDB(model, param_file, config)            
           
            % Load parameters for each of the folds
            this.params = load(param_file);

            % confusion matrix of size: L x L x Num Frames x Num People x Num Folds
            this.confusionMatrix = zeros(config.num_labels, config.num_labels, config.chunk_size, config.num_names, config.num_folds);                
                
            global global_metric_dir;
            
            % Metrics directory
            this.metric_dir = sprintf('%s/%s/', global_metric_dir, model.model_type);

            if ~exist(this.metric_dir, 'dir')
                mkdir(this.metric_dir);
            end                        
        end
                                
    end

end