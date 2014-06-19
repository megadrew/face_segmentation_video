classdef SCRF < Model
       
    methods
       
        % Constructor
        function this = SCRF()   
            
            this.model_type = 'scrf';
            
            this.use_temporal = 0;
            this.use_crbm = 0;
        end
        
        % Update model parameters.
        %
        % For now, there are no parameters to update for this model, but there could be in the
        % future.
        function this = update_params(this, param, global_model_dir)    
            
        end
        
        % Load new model
        function load_model(this, foldid, config)
                        
            global global_model_dir;
            
            model_file = sprintf('%s/scrf/scrf_foldid_%d_chunksize_%d_append_%d.mat', ...
                global_model_dir, foldid, config.chunk_size, config.append_train);
                        
            try
                %load the model                
                load(model_file, 'w_scrf');                
                this.weights = w_scrf;
                
                fprintf('Loading model for SCRF.\n');
            catch
                % throw exception
                throw(MException('Error:LoadModelError',sprintf('Cannot load %s.\n', model_file)));
            end
            
            this.weights.nodeWeightsrs = reshape(this.weights.nodeWeights,size(this.weights.nodeWeights,1)*size(this.weights.nodeWeights,2),size(this.weights.nodeWeights,3));
        end                       
    end
end