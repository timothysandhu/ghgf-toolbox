function [outcome] = prc_config_check(config)
% could develop this over time, but for now

% check it's a hgf model 
model_check = isfield(config,"model") && contains(config.model,"hgf");

% check there's a number of levels 
lev_check = isfield(config,"n_levels") && config.n_levels > 0;

% combine
outcome = model_check && lev_check;

end