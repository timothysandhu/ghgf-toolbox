function [fitted] = model_fit_all(hgf_input,resp,prc_config,obs_config,id,valence)
% fit hgf's to all participants 
% INPUTS
% input - hgf input (u)
% resp - matrix (n_ptp x n_trials) of responses - transformed preds/rt
% prc_config - perceptual model config - should have all the edits in
% obs_config - observation model config
% id - ID vector to keep track of it all
% valence - valence vector

% bopars
bopars_2l = hgf_binary_bopars(hgf_input,prc_config,false);

% bo updated config
bo_config = update_config(prc_config,"om_2","mu",bopars_2l.p_prc.om(2));

% set up the optim config
optim_config = quasinewton_optim_config();
optim_config.nRandInit = 5;
optim_config.seedRandInit = 123;

% start the loop
fitted = cell(1,length(id)); % preallocate
for ptp = 1:size(resp,1)
    fitted{ptp} = fitModel(resp(ptp,:)',... % make sure transposed predictions
        hgf_input,...
        bo_config,...
        obs_config,...
        optim_config); 
    fitted{ptp}.id = id(ptp);
    fitted{ptp}.valence = valence(ptp);
    disp(strcat("ptp: ",num2str(id(ptp))," valence: ",valence(ptp)," done"))
end