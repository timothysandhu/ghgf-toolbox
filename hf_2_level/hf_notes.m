%% HF three level 

% from OSF code

% from hgf_parameter_recovery 

% Build parameter vectors from fitted values
% prc_pvec order (tapas_hgf_binary): [mu_0(1:3), sa_0(1:3), rho(1:3), ka(1:2), om(1:3)]
% Level 3 is frozen: mu_0_3=0, sa_0_3=0.001, omega_3=-20, kappas both fixed at 1
% true_mu_0 = [NaN, params_table.mu_0_2(f), 0];
% true_sa_0 = [NaN, params_table.sa_0_2(f), 0.001];
% true_rho  = [NaN, 0, 0];
% true_ka   = [1, 1];
% true_om   = [NaN, params_table.omega_2(f), -20];

% tapas_hgf_binary_config_startpoints2.m

cd 'C:\Users\timot\Documents\GitHub\ghgf-toolbox'
addpath(genpath("C:\Users\timot\Documents\GitHub\ghgf-toolbox")) % should include funcs

% u (example)
u = load(fullfile('demo', 'example_binary_input.txt'));

% classic 2l
bin_config = hgf_binary_config();
bin_2l_config = make_hgf_2l(bin_config);

% confirm HF edits
ch_config = bin_config;
p_names = ["om_3","om_3","om_2","om_2","mu0_3","mu0_3","sa0_3","sa0_3","mu0_2","mu0_2","sa0_2","sa0_2"];
mos_vec = ["mu"  , "sa",   "mu",  "sa",   "mu",   "sa",   "mu",   "sa",   "mu",   "sa",   "mu",   "sa"];
val_vec = [  - 20,     0,-    5,     4,      0,      0,log(0.001),   0,      0,      1, log(0.1),    1];
hf_edits = hgf_param_tbl(p_names,mos_vec,val_vec);
ch_config = update_config(ch_config,hf_edits);
% same as hf_config 

% set the second level stuff as HF did 
hf_edits_2l = hf_edits(contains(hf_edits.param_name,"_2"),:);
new_config = update_config(bin_2l_config,hf_edits_2l);

true_2l_bopars = hgf_binary_bopars(u,bin_2l_config,true);
subplot(3,1,1)
ylim([-0.25 2.25])
subplot(3,1,2)
ylim([-4 4])

hf_bopars = hgf_binary_bopars(u,ch_config,true);
subplot(3,1,1)
ylim([-0.25 2.25])
subplot(3,1,2)
ylim([-4 4])

new_bopars = hgf_binary_bopars(u,new_config,true);
subplot(3,1,1)
ylim([-0.25 2.25])
subplot(3,1,2)
ylim([-4 4])

figure()
plot(hf_bopars.traj.mu(:,3))
% mu3 changes