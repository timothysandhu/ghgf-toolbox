function out_config = init_config(str_config,varargin)
%% initialize model function 
% wrapper around update_config
% takes in the string for the original config 
% calls the config function
% run through update_config

% make sure it's a string
if ~(strcmp(class(str_config),'string') || strcmp(class(str_config),'char'))
    error("please supply a string for the config")
end

% load base config
fh = str2func(str_config);
config = fh();

% parse varargin
if isempty(varargin)
    error("just call the config function directly")
else
    if (length(varargin)==4) || (length(varargin)==3)
        % param name
        param_name = varargin{1};

        % mu_or_sa
        mu_or_sa = varargin{2};

        % new_value
        new_value = varargin{3};

        if (length(varargin)==4)
            % print options
            print_opt = varargin{4};
        end
    else
        error("need to give either 3 or 4 arguments")
    end
end

% update_config
if length(varargin)==4
    out_config = update_config(config,param_name,mu_or_sa,new_value,print_opt);
else
    out_config = update_config(config,param_name,mu_or_sa,new_value);
end
