function [simul,fitted]=pipeline_param_rec(u,prc_config,obs_config,n_sim,tol)
% parameter recovery function
% might need some work for free kappa models (not bothered atm) or rt
% models?

%% function starts here

% to appease some checks
obs_config.model = strcat(obs_config.model,"_hgf");
obs_config.n_levels = 3;

% not doing this for rt model yet, not needed
% if ~strcmp(obs_config.model,"unitsq_sgm")
%     error("this function doesn't do this resp model without specific params being changed yet, sorry")
% end

% bopars
bopars = hgf_binary_bopars(u,prc_config,false);

% bo updated config
bo_config = update_config(prc_config,"om_2","mu",bopars.p_prc.om(2));

% would need changing if k was free
% if sum(prc_config.logkasa)>0 % if any of the kappas are free
%     prc_config.logkamu = log(bopars.p_prc.ka);
% end
% new function based on _namep to assign bopars variables to the right bit
% of the config structure
% align_priors just moves the separate values into priormus, not vice versa

% max attempts = double n sim
n_sim_t = tol * n_sim;

% prc model
[prc_sim_array,prc_free_params] = sample_prior(bo_config,n_sim_t,123);
prc_params = repmat(bopars.p_prc.p,n_sim_t,1);
prc_params(:,prc_free_params) = prc_sim_array;

% obs model
[obs_sim_array,obs_free_params] = sample_prior(obs_config,n_sim_t,123);
obs_params = repmat(bopars.p_prc.p,n_sim_t,1); % will probably only one column, but keep for consistency
obs_params(:,obs_free_params) = obs_sim_array;

% check how this looks compared to trunc_zeta
histogram(log(obs_sim_array))
histogram(obs_sim_array)

% optim
optim_config = quasinewton_optim_config();
optim_config.nRandInit = 5;
optim_config.seedRandInit = 123;

%% do the loop

obs_config.model = 'unitsq_sgm';

simul = cell(1,n_sim);
fitted = cell(1,n_sim);
failed_mask = nan(n_sim_t,1);
n_att = 0;
n_succ = 0;

while (n_succ < n_sim) && (n_att < n_sim_t)
    n_att = n_att + 1;

    try
        % simulate
        simul_tmp = simModel(u,...
            bo_config.model,...
            prc_params(n_att,:),...
            obs_config.model,...
            obs_params(n_att,:),...
            123);

        % fit
        fitted_tmp = fitModel(simul_tmp.y,...
            u,...
            bo_config,...
            obs_config,...
            optim_config);

        % if the fit doesn't look good
        if isinf(fitted_tmp.optim.negLl)
            failed_mask(n_att)=1;
            continue
        end

        % otherwise, success
        n_succ = n_succ + 1;
        simul{n_succ} = simul_tmp;
        fitted{n_succ} = fitted_tmp;

    catch
        failed_mask(n_att)=1;
        continue
    end
end