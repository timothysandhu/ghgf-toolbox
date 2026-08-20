function out_config = init_config(str_config,varargin)
%% initialize model function 
% wrapper around update_config
% takes in the string for the original config 
% calls the config function
% run through update_config - which handles all the extra args

% make sure it's a string
if ~(strcmp(class(str_config),'string') || strcmp(class(str_config),'char'))
    error("please supply a string for the config")
end

% load base config
fh = str2func(str_config);
config = fh();

% parse varargin
if isempty(varargin)
    % error("just call the config function directly")
    disp("this is equivalent to calling the function directly")
    out_config = config;
end

% update_config
% delegate all argument parsing/validation to update_config
out_config = update_config(config,varargin{:});
