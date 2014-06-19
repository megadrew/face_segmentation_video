% This is the base Model class that other models are derived from.

classdef Model < handle
    
	properties (SetAccess = protected)

        % Model Type
        model_type;
                        
        % Model weights
        weights;
                
        % Flags to determine if the model uses temporal or CRBM potentials
        use_temporal;
        use_crbm;
    end
       
    % Define member methods
    methods(Abstract)

        % Load the model
        load_model(this);
        
        % Perform Inference
        inference(this);
        
    end
    
end