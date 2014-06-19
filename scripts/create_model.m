% This script will create a model for the given model_name

function model = create_model(model_name)

% Pick the appropriate model
switch model_name
    case 'scrf'
        model = SCRF;
    case 'scrf_temporal'
        model = SCRF_Temporal;
    case 'scrf_rbm'
        model = SCRF_RBM;
    case 'scrf_rbm_temporal' 
        model = SCRF_RBM_Temporal;
    case 'scrf_crbm'
        model = SCRF_CRBM;
    case 'strf'  
        % i.e. SCRF+CRBM+Temporal
        model = STRF;
    otherwise 
        throw(MException('Error:UnsupportedModel',sprintf('Model %s not supported.  \n', model_name)));
end