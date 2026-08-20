%% init 

% cd & path etc 
cd 'C:\Users\timot\Documents\GitHub\ghgf-toolbox'
addpath(genpath("C:\Users\timot\Documents\GitHub\ghgf-toolbox")) % should include funcs

% load iglesias
u = load(fullfile('demo', 'example_binary_input.txt'));

%% 

% https://github.com/translationalneuromodeling/tapas/issues/35
prc_config = ehgf_binary_config();
prc_config.logkamu(2) = -Inf;
prc_config.omsa(3) = 0;
prc_config.omsa(2) = 1;
obs_config = unitsq_sgm_config();
n_sim = 100;

[simul,fitted]=pipeline_param_rec(u,prc_config,obs_config,n_sim);

% need seed for simulating from priors 
% need seed for fitting routes
% ? ppc function for muhat1

%% in new money 

config_2l = make_hgf_2l(config);
config_2l = update_config(config_2l,"om_2","sa",1);

obs_config = unitsq_sgm_config();
n_sim = 100;

[simul,fitted]=pipeline_param_rec(u,prc_config,obs_config,n_sim);