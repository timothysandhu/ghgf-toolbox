function [sim_array,free_params] = param_rec_simpars(mod_name,al_config,van_config,n_sim)
% find free params 
free_params = find(al_config.priorsas>0);
n_par = length(free_params);

% check which priors on these free params are different
prc_mu_diff_loc = find(van_config.priormus(free_params)~=al_config.priormus(free_params)); % prc mu
prc_sa_diff_loc = find(van_config.priorsas(free_params)~=al_config.priorsas(free_params)); % prc sa

% generate the synthetic parameters
if isempty(prc_mu_diff_loc) && isempty(prc_sa_diff_loc) % no changes 
    % just do normal param rec loop
    % simulate from all free params 
    sim_array = nan(n_sim,n_par);
    for i = 1:n_par
        sim_array(:,i) = normrnd(van_config.priormus(free_params(i)),sqrt(van_config.priorsas(free_params(i))),n_sim,1);
    end
else
    % set up how many params
    max_par = unique([prc_mu_diff_loc prc_sa_diff_loc]);
    n_par = length(max_par);
    new_mu = ismember(max_par,prc_mu_diff_loc); % if _diff_loc is empty, ismember will return 0's - don't need to check if one is empty or not
    new_sa = ismember(max_par,prc_sa_diff_loc);
    sim_array = nan(n_sim,n_par);
    if ~strcmp(mod_name,'tapas_unitsq_sgm')
        for i = 1:n_par
            c_ind = free_params(max_par(i));
            if new_mu(i)==1 && new_sa(i)==1
                sim_array(:,i) = normrnd(al_config.priormus(c_ind),sqrt(al_config.priorsas(c_ind)),n_sim,1);
            elseif new_mu(i)==0 && new_sa(i)==1
                sim_array(:,i) = normrnd(van_config.priormus(c_ind),sqrt(al_config.priorsas(c_ind)),n_sim,1);
            elseif new_mu(i)==1 && new_sa(i)==0
                sim_array(:,i) = normrnd(al_config.priormus(c_ind),sqrt(van_config.priorsas(c_ind)),n_sim,1);
            else
                error("shouldn't be at this point if there are no changes - check your code")
            end
        end
    else % need to do truncated zeta
        for i = 1:n_par
            c_ind = free_params(max_par(i));
            if new_mu(i)==1 && new_sa(i)==1
                sim_array(:,i) = gen_trunc_zeta(al_config.priormus(c_ind),sqrt(al_config.priorsas(c_ind)),n_sim);
            elseif new_mu(i)==0 && new_sa(i)==1
                sim_array(:,i) = gen_trunc_zeta(van_config.priormus(c_ind),sqrt(al_config.priorsas(c_ind)),n_sim);
            elseif new_mu(i)==1 && new_sa(i)==0
                sim_array(:,i) = gen_trunc_zeta(al_config.priormus(c_ind),sqrt(van_config.priorsas(c_ind)),n_sim);
            else
                error("shouldn't be at this point if there are no changes - check your code")
            end
        end
    end
end