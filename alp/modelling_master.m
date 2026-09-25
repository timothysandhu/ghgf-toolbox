% this was originally assoc_learning_pipeline_modelling

% paths 
cd 'C:\Users\timot\Documents\GitHub\ghgf-toolbox'
addpath(genpath("C:\Users\timot\Documents\GitHub\ghgf-toolbox")) % should include funcs
addpath(genpath("C:\Users\timot\Documents\GitHub\core\matlab"))

% dirs
data_dir = 'C:\Users\timot\Documents\GitHub\gorillar\';
u_dir = 'C:\Users\timot\Documents\GitHub\assoc_learning\camraa\';

% get camraa input 
u = load(strcat(u_dir,'camraa_input.txt')); % camraa input

% do we want drumstickers in - yes, exclude after
drumstickers = true;
min_rt = 100;
min_rt_str = strcat("minrt",num2str(min_rt));

% prep task data 
if drumstickers % with drumstickers, set their exclusion to false
    [fh_data,fh_id]=prep_data(data_dir,"face_house",min_rt,false);
    [ss_data,ss_id]=prep_data(data_dir,"stick_snake",min_rt,false);
else % without drumstickers, exclusion = true
    [fh_data,fh_id]=prep_data(data_dir,"face_house",min_rt,true);
    [ss_data,ss_id]=prep_data(data_dir,"stick_snake",min_rt,true);
end

% drumstickers if needed 
fh_ds = readmatrix(strcat(data_dir,"data\",min_rt_str,"\","face_house_drumstickers_",min_rt_str,".csv"));
ss_ds = readmatrix(strcat(data_dir,"data\",min_rt_str,"\","stick_snake_drumstickers_",min_rt_str,".csv"));

% combine 
all_data = [fh_data;ss_data];
all_id = [fh_id;ss_id];
all_val = [repmat("sensory",length(fh_id),1);repmat("aversive",length(ss_id),1)];

%% parameter recovery 

% see param_rec and pipeline_param_rec

%% sept 2026 

% 2 level 
prc_config = ehgf_binary_config();
config_2l = make_hgf_2l(prc_config);
config_2l = update_config(config_2l,"om_2","sa",1);

% model fit
obs_config = unitsq_sgm_config();
ehgf_fit = model_fit_all(u,all_data,config_2l,obs_config,all_id,all_val);
mat_prefix = strcat("ehgf_minrt",num2str(min_rt),"_");
mat_suffix = "_ds.mat";

if drumstickers
    mat_mid = "with";
else
    mat_mid = "no";
end
save(strcat(mat_prefix,mat_mid,mat_suffix),'ehgf_fit')

% check 
[implausible_mu2,corr_params,failed_fit] = fit_check(ehgf_fit,false);

% extract 
param_tbl = extract_hgf_params(ehgf_fit);
low_om2_ind = find(str2double(param_tbl.om2)<-8);

% exclude id's
ind_to_exc = []; 
if ~isempty(implausible_mu2)
    ind_to_exc = [ind_to_exc;implausible_mu2.index];
end
if ~isempty(corr_params)
    ind_to_exc = [ind_to_exc;corr_params.index];
end
if ~isempty(low_om2_ind)
    ind_to_exc = [ind_to_exc;low_om2_ind];
end
if ~isempty(failed_fit)
    ind_to_exc = [ind_to_exc;failed_fit];
end

% exclude 
param_tbl(ind_to_exc,:)=[];

% make file name 
csv_prefix = strcat("ehgf_params_minrt",num2str(min_rt),"_");
csv_suffix = "_ds.csv";

if drumstickers
    csv_mid = "with";
else
    csv_mid = "no";
end
writetable(param_tbl,strcat(data_dir,csv_prefix,csv_mid,csv_suffix))


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