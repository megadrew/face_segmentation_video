% This script is used to run all other scripts.

% Parameters are
% * param_file : contains parameters for a specific model
% * model_name : model name

% Model names are:
    
% scrf : baseline SCRF
% scrf_temporal : SCRF + Temporal potentials
% scrf_rbm : SCRF + RBM 
% scrf_rbm_temporal: SCRF + RBM + Temporal
% scrf_crbm : SCRF + CRBM
% strf : SCRF + CRBM + Temporal

% The param_file is named: param_test_{model_name}

% An example usage is 
% > drive_models('../params/param_test_scrf', 'scrf')

function drive_models(param_file, model_name)

% load directory paths
startup_directory;

% load the common set of configurations for all models
config = load_configuration;

% create the specified model
try 
    model = create_model(model_name);
catch ex
    fprintf(['Error: ' ex.message '\n']);
    return;
end

% create an instance of the YFDB class to run the experiments
yfdb = YFDB(model, param_file, config);

% Evaluate Model
try 
    yfdb.test(model, config);
catch ex
    fprintf(['Error: ' ex.message '\n']);
    return;
end

% Report the metrics and write them to file
yfdb.report_metrics(model.model_type, config);

fprintf('Exiting.\n');