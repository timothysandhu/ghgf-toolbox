function [sim_array,free_param_inds] = sample_prior(config,n_sim,seed)

% find free params 
free_param_inds = find(config.priorsas>0);
n_par = length(free_param_inds);

% return if no free params 
if n_par==0
    return
end

% list the params 
[all_param_names,all_param_nums,all_param_trans] = list_params(config);
mu_names = strcat(all_param_trans,all_param_names,"mu");

% do the sim
sim_array = nan(n_sim,n_par);
rng(seed)

% means and variances 
[free_param_mus,free_param_sas] = deal(nan(n_par,1));
for i = 1:n_par
    t_fp = free_param_inds(i);
    t_name = mu_names(t_fp);
    t_ind = all_param_nums(t_fp);
    free_param_mus(i) = config.(t_name)(t_ind);
    free_param_sas(i) = config.priorsas(t_fp);
    % sim
    sim_array(:,i) = normrnd(free_param_mus(i),sqrt(free_param_sas(i)),n_sim,1);
    % transform if needed 
    t_trans = all_param_trans(t_fp);
    if t_trans == "log"
        sim_array(:,i) = exp(sim_array(:,i));
    end
end