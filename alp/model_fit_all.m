function [fitted] = model_fit_all(hgf_input,resp,prc_config,obs_config,id)
% fit hgf's to all participants 
% INPUTS
% input - hgf input (u)
% resp - matrix (n_ptp x n_trials) of responses - transformed preds/rt
% prc_config - perceptual model config - should have all the edits in
% obs_config - observation model config
% id - ID vector to keep track of it all

% get a string prc_config for bopars - nah bopars should have the right
% variance (as in the same as the model fit) I think..
% if strfind('tapas',prc_config.model)
%     str_prc_config = [prc_config.model '_config'];
% else
%     str_prc_config = ['tapas_' prc_config.model '_config'];
% end

% get the bopars for the input
bopars = tapas_fitModel_trs([],...
    hgf_input,...
    prc_config,... % or str_prc_config
    'tapas_bayes_optimal_binary_config',...
    'tapas_quasinewton_optim_config');

% set up the optim config
optim_config = tapas_quasinewton_optim_config();

% check the prc model and change the defaults based on bopars
if contains(prc_config.model,'hgf')
    prc_config.ommu = bopars.p_prc.om; % use bopars omega estimates
    if sum(prc_config.logkasa)>0 % if any of the kappas are free
        prc_config.logkamu = log(bopars.p_prc.ka);
    end
    optim_config.nRandInit = 5;
elseif contains(prc_config.model,'rw')
    prc_config.logitalmu = bopars.p_prc.ptrans(2);
    optim_config.nRandInit = 5;
elseif contains(prc_config.model,'k1')
    prc_config.logmumu = bopars.p_prc.ptrans(1);
    prc_config.logitvhat_1mu = bopars.p_prc.ptrans(3);
    prc_config.logh_1mu = bopars.p_prc.ptrans(4);
elseif contains(prc_config.model,'ph')
    prc_config.logital_0mu = bopars.p_prc.ptrans(2);
    prc_config.logSmu = bopars.p_prc.ptrans(3);    
end

% start the loop
fitted = cell(1,length(id)); % preallocate
for ptp = 1:size(resp,1)
    fitted{ptp} = tapas_fitModel_trs(resp(ptp,:)',... % make sure transposed predictions
        hgf_input,...
        prc_config,...
        obs_config,...
        optim_config); 
    fitted{ptp}.id = id(ptp);
    disp(strcat("ptp ",num2str(ptp)," done"))
end