function out_config = init_config(str_config,varargin)

% load base config 
fh = str2func(str_config);
config = fh();

% parse varargin
if ~isesmpty(varargin)
    % param name

    % mu_or_sa

    % new_value

    % print options
end

% update_config