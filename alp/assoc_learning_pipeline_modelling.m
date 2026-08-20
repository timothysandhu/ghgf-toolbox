%% set up model fitting function with given configs (nace_ehgf* scripts)

% notes
% still can't get propranolol right 
% try rt model for fh
% [ ] exclude drumstickers

%% data

addpath C:\Users\timot\Desktop\camraa_online\camraa_learning\alp_data_new

task_names = ["face_house","stick_snake"];
task_name = task_names(1);

% load data
data = readmatrix(strcat(task_name,"_hgf_bin.csv"));
processed_spreadsheet = readtable(strcat(task_name,'_processed_spreadsheet.csv'));

% split up 
id = data(:,1);
hgf_resp = data(:,2:end);

% exclude drumstickers
ds = readmatrix(strcat(task_name,"_drumstick.csv"));
data = data(~ismember(id,ds));

% get camraa input 
u = load('camraa_input.txt'); % camraa input

%% parameter recovery 

% for model fitting stuff - try seedRandInit to get reproducibility
% should maybe try inspecting parameter correlations here too as per
% Eddie's thesis

% pu - need noise column
% noise_col = 0.9*ones(200,1);
% noise_col(strcmp(processed_spreadsheet.noise,"no"))=.1;
% u2 = u;
% u2(:,2) = noise_col;

% new param recovery method
% define configs before 

% prc_config = tapas_hgf_binary_pu_tbt_2l_config();
% prc_config.omsa(2) = 2; % needed for pu_tbt otherwise too wide - errors
%u2(:,2) = noise_col;

prc_config = tapas_ehgf_binary_2l_config();
prc_config.omsa(2) = 1;
obs_config = tapas_unitsq_sgm_config();
n_sim = 100;

[simul,fitted]=pipeline_param_rec(u,prc_config,obs_config,n_sim);

%rw_config = tapas_rw_binary_config();
% [simul_rw,fitted_rw]=pipeline_param_rec(u,rw_config,obs_config,n_sim); % maybe not needed

% extract what variables you want
[sim_om2,fit_om2,corr_om2] = param_rec_extract(simul,fitted,"om_2");
[sim_zeta,fit_zeta,corr_zeta] = param_rec_extract(simul,fitted,"zeta");
%[sim_om3,fit_om3,corr_om3] = param_rec_extract(simul,fitted,"om_3");

% plot them with a regression line
subplot(1,3,1)
param_rec_plot(sim_om2,fit_om2,corr_om2,"om_2")
subplot(1,3,2)
param_rec_plot(sim_om3,fit_om3,corr_om3,"om_3")
subplot(1,3,3)
param_rec_plot(sim_zeta,fit_zeta,corr_zeta,"zeta")

% does param rec need to cover the full range parameter values that we see
% in the data (probably)

%% 2025 addition 

% added a try catch in the pipeline param loop

u = load('camraa_input.txt'); % camraa input
obs_config = tapas_unitsq_sgm_config();
n_sim = 200;

% 3 level old
prc_config = tapas_hgf_binary_config();
prc_config.omsa(2:3) = 4; % need to reduce these off the bat
[simul,fitted]=pipeline_param_rec(u,prc_config,obs_config,n_sim);
fitted(101:end)=[];
simul(101:end)=[];
[sim_om2,fit_om2,corr_om2] = param_rec_extract(simul,fitted,"om_2");
[sim_zeta,fit_zeta,corr_zeta] = param_rec_extract(simul,fitted,"zeta");
[sim_om3,fit_om3,corr_om3] = param_rec_extract(simul,fitted,"om_3");
figure('Units','inches','Position',[0 0 9.2 3.54])
subplot(1,3,1)
param_rec_plot(sim_om2,fit_om2,corr_om2,"om_2")
subplot(1,3,2)
param_rec_plot(sim_om3,fit_om3,corr_om3,"om_3")
subplot(1,3,3)
param_rec_plot(sim_zeta,fit_zeta,corr_zeta,"zeta")

% 3 level new
prc_config = tapas_ehgf_binary_config();
[simul,fitted]=pipeline_param_rec(u,prc_config,obs_config,n_sim);
[sim_om2,fit_om2,corr_om2] = param_rec_extract(simul,fitted,"om_2");
[sim_zeta,fit_zeta,corr_zeta] = param_rec_extract(simul,fitted,"zeta");
[sim_om3,fit_om3,corr_om3] = param_rec_extract(simul,fitted,"om_3");
fitted(101:end)=[];
simul(101:end)=[];
figure('Units','inches','Position',[0 0 9.2 3.54])
subplot(1,3,1)
param_rec_plot(sim_om2,fit_om2,corr_om2,"om_2")
subplot(1,3,2)
param_rec_plot(sim_om3,fit_om3,corr_om3,"om_3")
subplot(1,3,3)
param_rec_plot(sim_zeta,fit_zeta,corr_zeta,"zeta")

%% model fit 

% ehgf binary
prc_config = tapas_ehgf_binary_2l_config();
prc_config.omsa(2) = 1; % will people ask why 1? bms?
obs_config = tapas_unitsq_sgm_config();
fh_ehgf_fit = model_fit_all(u,hgf_resp,prc_config,obs_config,id);
%ss_ehgf_fit = model_fit_all(u,hgf_resp,prc_config,obs_config,id);

% ehgf increased var
prc_config = tapas_ehgf_binary_2l_config();
prc_config.omsa(2) = 2; % will people ask why 1? bms?
obs_config = tapas_unitsq_sgm_config();
fh_ehgf_fit_var2 = model_fit_all(u,hgf_resp,prc_config,obs_config,id);
%ss_ehgf_fit_var2 = model_fit_all(u,hgf_resp,prc_config,obs_config,id);

% hgf binary
prc_config = tapas_hgf_binary_2l_config();
prc_config.omsa(2) = 1;
obs_config = tapas_unitsq_sgm_config();
fh_hgf_fit = model_fit_all(u,hgf_resp,prc_config,obs_config,id);

% try pu
prc_config_2 = tapas_hgf_binary_pu_tbt_2l_config();
pu_tbt_2l_fit = model_fit_all(u2,hgf_resp,prc_config_2,obs_config,id);

% try lawson et al 2017 for rt 
prc_config = tapas_hgf_binary_pu_tbt_2_config(); % becky's was _2, updated one is without
prc_config.omsa(2) = 2; % for precision errors
obs_config = tapas_logrt_linear_binary_config();
lawson_2017_fit = model_fit_all(u2,log(hgf_resp),prc_config,obs_config,id);

% rw (why is al prior mean different)
rw_config = tapas_rw_binary_config();
obs_config = tapas_unitsq_sgm_config();
rw_fit = model_fit_all(u,hgf_resp,rw_config,obs_config,id);
%fh_rw_fit = rw_fit;
%save("fh_rw_fit.mat","fh_rw_fit")
ss_rw_fit = rw_fit;
save("ss_rw_fit.mat","ss_rw_fit")

% rw lower variance
rw_config = tapas_rw_binary_config();
rw_config.logitalsa = .5; % will people ask where .5 came from?
obs_config = tapas_unitsq_sgm_config();
rw_fit = model_fit_all(u,hgf_resp,rw_config,obs_config,id);
fh_rw_fit = rw_fit;
save("fh_rw_lowvar_fit.mat","fh_rw_fit")
%ss_rw_fit = rw_fit;
%save("ss_rw_lowvar_fit.mat","ss_rw_fit")

% sk1
sk1_config = tapas_sutton_k1_binary_config();
sk1_config.logmusa = 10; % the default is high
obs_config = tapas_unitsq_sgm_config();
sk1_fit = model_fit_all(u,hgf_resp,sk1_config,obs_config,id);
%fh_sk1_fit = sk1_fit;
%save("fh_sk1_fit.mat","fh_sk1_fit")
ss_sk1_fit = sk1_fit;
save("ss_sk1_fit.mat","ss_sk1_fit")

% sk1 low var
sk1_config = tapas_sutton_k1_binary_config();
sk1_config.logmusa = 10; % the default is high
sk1_config.logitvhat_1sa = 4;
sk1_config.logh_1sa = 4;
obs_config = tapas_unitsq_sgm_config();
sk1_fit = model_fit_all(u,hgf_resp,sk1_config,obs_config,id);
%fh_sk1_fit = sk1_fit;
%save("fh_sk1_lowvar_fit.mat","fh_sk1_fit")
ss_sk1_fit = sk1_fit;
save("ss_sk1_lowvar_fit.mat","ss_sk1_fit")

% ph 
ph_config = tapas_ph_binary_config();
obs_config = tapas_unitsq_sgm_config();
ph_fit = model_fit_all(u,hgf_resp,ph_config,obs_config,id);
fh_ph_fit = ph_fit;
save("fh_ph_fit.mat","fh_ph_fit")
% ss_ph_fit = ph_fit;
% save("ss_ph_fit.mat","ss_ph_fit")

%% do a bms with different prior variances (to justify the of use narrower variances?)

% should we do this on real data or fake data? I think fake, we want the
% parameters to be expected with respect to the priors
[simul_1,fitted_1]=ehgf_2l_param_rec(u,om2_var,n_sim);
[simul_2,fitted_2]=ehgf_2l_param_rec(u,om2_var,n_sim);
[simul_3,fitted_3]=ehgf_2l_param_rec(u,om2_var,n_sim);

var_1_lme = cellfun(@(x) x.LME,fitted_1);
var_2_lme = cellfun(@(x) x.LME,fitted_2);
var_3_lme = cellfun(@(x) x.LME,fitted_3);

% not sure this makes sense - not the same participants on different models
[alpha,exp_r,xp,pxp,bor] = spm_BMS(var_1_lme,var_2_lme,var_3_lme);