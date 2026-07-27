% cd & path etc 
cd 'C:\Users\timot\Documents\GitHub\ghgf-toolbox'
addpath(genpath("C:\Users\timot\Documents\GitHub\ghgf-toolbox")) % should include funcs

% load iglesias
u = load(fullfile('demo', 'example_binary_input.txt'));

% classic hgf

bopars_o = fitModel([],...
                         u,...
                         'hgf_binary_config',...
                         'bayes_optimal_binary_config',...
                         'quasinewton_optim_config');
isequal(bopars_o,bopars) % doesnt seem to work but should be right

% should make a model checking function 
% prints correlations between params
% print se of params
1.96*sqrt(diag(bopars.optim.Sigma))

% ehgf 

% ehgf_config c.ommu = [NaN,  -3,   2];

e_bopars_o = fitModel([],...
                         u,...
                         'ehgf_binary_config',...
                         'bayes_optimal_binary_config',...
                         'quasinewton_optim_config');

1.96*sqrt(diag(e_bopars_o.optim.Sigma))


% uhgf 

u_bopars_o = fitModel([],...
                         u,...
                         'uhgf_binary_config',...
                         'bayes_optimal_binary_config',...
                         'quasinewton_optim_config');

1.96*sqrt(diag(u_bopars_o.optim.Sigma))

% use function
bopars = hgf_binary_bopars(u,'hgf_binary_config',true);
e_bopars = hgf_binary_bopars(u,'ehgf_binary_config',true);
u_bopars = hgf_binary_bopars(u,'uhgf_binary_config',true);

% try higher om3 

u_config = uhgf_binary_config();
u_config.ommu(3) = 3; 
u_config = align_priors(u_config);

u_bopars_om3 = hgf_binary_bopars(u,u_config,true);


%% update config function

% test on binary, ar1

% LOOK AT ALIGN PRIORS

% update(config,param_name,mu_or_sa,new_value)

% param_name - split to param level 
% check level 

% check param_name against all possible params in the prc
% - if not found, maybe add transformation tag

% list field names

% find which params are free

% find the location of the param

% change it

% perform align_priors

% print transforms every time and free parameters every time
% log/logit/exp?

% add full print option

% Print results
ftbrm = {'p', 'ptrans'};
dispprc = rmfield(r.p_prc, ftbrm);
dispobs = rmfield(r.p_obs, ftbrm);

disp(' ')
disp('Results:');
disp(' ')
disp('Parameter estimates for the perceptual model:');
disp(dispprc)
if ~isempty(fieldnames(dispobs))
    disp(' ')
    disp('Parameter estimates for the observation model:');
    disp(dispobs)
end

%% initialize model function 
% wrapper around update_config

% takes in the string for the original config 
% calls the config function
% then takes in a cell/table with incoming parameters
% run through update_config

%% 

% think its probably more intuitive to use the config throughout any model
% fitting 




%% could also make sim_unitsq function

% sim_unitsq(u,prc_config,zeta,seed)

% check if priors has been done, if not return an erro
% (user should check if its normal or fields)

% get model from prc_config

sim = simModel(u,...
                     'hgf_binary',...
                     [NaN 0 1 NaN 1 1 NaN 0 0 1 1 NaN -2.5 -6],...
                     'unitsq_sgm',...
                     5,...
                     123456789);

e_sim = simModel(u,...
                     'ehgf_binary',...
                     [NaN 0 1 NaN 1 1 NaN 0 0 1 1.5 NaN -4 3],...
                     'unitsq_sgm',...
                     5,...
                     123456789); 

u_sim = simModel(u,...
                     'uhgf_binary',...
                     [NaN 0 1 NaN 1 1 NaN 0 0 1 1 NaN -2.5 -6],...
                     'unitsq_sgm',...
                     5,...
                     123456789);
