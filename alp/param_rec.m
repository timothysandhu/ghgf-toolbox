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
% need seed for fitting routines
% ? ppc function for muhat1

%% in new money 

config_2l = make_hgf_2l(config);
config_2l = update_config(config_2l,"om_2","sa",1,"none");

obs_config = unitsq_sgm_config();
n_sim = 100;

[simul,fitted]=pipeline_param_rec(u,config_2l,obs_config,n_sim,2);
% think two runs were both indeitcal

[sim_om2,fit_om2,corr_om2] = param_rec_extract(simul,fitted,"om_2");
[sim_zeta,fit_zeta,corr_zeta] = param_rec_extract(simul,fitted,"zeta");
%[sim_om3,fit_om3,corr_om3] = param_rec_extract(simul,fitted,"om_3");

% plot them with a regression line
clf
subplot(1,2,1)
param_rec_plot(sim_om2,fit_om2,corr_om2,"om_2")
subplot(1,2,2)
param_rec_plot(log(sim_zeta),log(fit_zeta),corr_zeta,"zeta")

clf
plot(sim_om2,fit_om2-sim_om2,'o')
clf
plot(log(sim_zeta),log(fit_zeta)-log(sim_zeta),'o')
clf
plot(fit_om2-sim_om2,log(fit_zeta)-log(sim_zeta),'o')