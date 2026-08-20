function [simul,fitted]=pipeline_param_rec(u,prc_config,obs_config,n_sim)
% parameter recovery function 
% might need some work for free kappa models (not bothered atm) or rt
% models?

%% function starts here
prc_model = prc_config.model;
obs_model = obs_config.model;

% bump up the
n_sim_t = n_sim + (.1*n_sim);

bopars = fitModel([],...
    u,...
    prc_config,... % can replace this with an actual configuration, align_priors is performed
    'tapas_bayes_optimal_binary_config',...
    'tapas_quasinewton_optim_config');

prc_config.ommu = bopars.p_prc.om;
% would need changing if k was free
% if sum(prc_config.logkasa)>0 % if any of the kappas are free
%     prc_config.logkamu = log(bopars.p_prc.ka);
% end 
% new function based on _namep to assign bopars variables to the right bit
% of the config structure
% align_priors just moves the separate values into priormus, not vice versa

% not doing this for rt model yet, not needed
if ~strcmp(obs_model,"unitsq_sgm")
    error("this function doesn't do this resp model without specific params being changed yet, sorry")
end

% make the edited configs have the right priormus/sas
al_prc_config = tapas_align_priors(prc_config);
al_obs_config = tapas_align_priors(obs_config);

if strfind(al_prc_config.model,"tapas_")
    van_prc_config = eval(strcat(prc_model,"_config()"));
    sim_prc_model = prc_model;
else
    van_prc_config = eval(strcat("tapas_",prc_model,"_config()"));
    sim_prc_model = strcat('tapas_',prc_model);
end

if strfind(al_obs_config.model,"tapas_")
    van_obs_config = eval(strcat(obs_model,"_config()"));
    sim_obs_model = obs_model;
else
    van_obs_config = eval(strcat("tapas_",obs_model,"_config()"));
    sim_obs_model = strcat('tapas_',obs_model);
end

% prc model
[prc_sim_array,prc_free_params] = param_rec_simpars(prc_model,al_prc_config,van_prc_config,n_sim_t);
prc_params = repmat(bopars.p_prc.p,n_sim_t,1);
prc_params(:,prc_free_params) = prc_sim_array;

% obs model
[obs_sim_array,obs_free_params] = param_rec_simpars(obs_model,al_obs_config,van_obs_config,n_sim_t);
obs_params = repmat(al_obs_config.priormus,n_sim_t,1); % will probably only one column, but keep for consistency
obs_params(:,obs_free_params) = obs_sim_array;

% optim 
optim_config = tapas_quasinewton_optim_config();
optim_config.nRandInit = 5;

%% do the loop 

simul = cell(1,n_sim_t);
fitted = cell(1,n_sim_t);
for i = 1:n_sim_t
    try
        % simulate
        simul{i} = simModel(u,...
            sim_prc_model,...
            prc_params(i,:),...
            sim_obs_model,...
            obs_params(i,:));

        % fit
        fitted{i} = fitModel(simul{i}.y,... % _trs just removes some printing
            u,...
            al_prc_config,...
            al_obs_config,...
            optim_config);
    catch
        % keep both blank
        fitted{i} = {};
        simul{i}= {};
    end
end

%% check for bad fits 

% remove blank fits 
blanks = cellfun(@isempty,fitted);
fitted(blanks)=[];
simul(blanks)=[];

% for the really high zetas, looks like they fail to fit
to_exc = find(isinf(cellfun(@(x) x.optim.negLl,fitted)));
fitted(to_exc)=[];
simul(to_exc)=[];

% remove so only n_sim left
fitted(n_sim+1:end)=[];
simul(n_sim+1:end)=[];

%% spare code 

% check to see if parameters are different whilst looking with nans
% if isequaln(van_prc_config.priormus,prc_config.priormus) % if the nans are in the same place
%     % prc mu
%     mu_nan_loc = find(isnan(prc_config.priormus));
%     prc_mu_diff_loc = find(van_prc_config.priormus~=al_prc_config.priormus);
%     prc_mu_diff_loc(ismember(prc_mu_diff_loc,mu_nan_loc))=[];
%     % prc sa
%     sa_nan_loc = find(isnan(prc_config.priorsas));
%     prc_sa_diff_loc = find(van_prc_config.priorsas~=al_prc_config.priorsas);
%     prc_sa_diff_loc(ismember(prc_sa_diff_loc,sa_nan_loc))=[];
% else
%     error("nan's in inputted prc_config aren't default")
% end

end