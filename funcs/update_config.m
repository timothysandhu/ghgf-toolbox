function out_config = update_config(config,param_name,mu_or_sa,new_value,varargin)
%update_config Update a HGF config structure

% initially just prc?
% test on binary, ar1

% LOOK AT ALIGN PRIORS

%% input checks
% note param_name checked below, more involved

% config check
if ~prc_config_check(config)
    error("doesn't look like a hgf prc config")
end

% mu_or_sa check
if ~(strcmp(mu_or_sa,"mu")||strcmp(mu_or_sa,"sa"))
    error("third arg should be either mu (mean) or sa (variance)")
end

% new_value check
if ~isnumeric(new_value)
    error("final argument should be the new value")
end

% parse vargin
if ~isempty(varargin)
    print_opt = varargin{1};
    if print_opt ~= "none"
        error("you can only disable printing with none")
    end
end

%% param_name checks

% param_name - split to param level
p_parts = split(lower(param_name),"_");

% make sure mu0 and sa0 caught 
if all(strcmp(p_parts(1:2),["mu";"0"])) || all(strcmp(p_parts(1:2),["sa";"0"]))
    error('for initial means and variances at x level, use mu0_x or sa0_x')
end

% check number of parts
if numel(p_parts) ~= 2
    error('param name should split by _ into two parts');
end

% assign
[p_name,p_level] = deal(p_parts(1),str2num(p_parts(2)));

% smooth parameter names
if p_name == "kappa"
    p_name = "ka";
elseif p_name == "omega"
    p_name = "om";
elseif p_name == "mu0"
    p_name = "mu_0";
elseif p_name == "sa0"
    p_name = "sa_0";
end

% all possible params in the prc
[param_fields,p_trans]=find_param_fields(config);

% check param_name against the names
found_p = strcmp(param_fields,p_name);
if ~(contains(param_fields,p_name))
    error("don't recognise the parameter name")
end

% check level
if p_level > 0
    if p_name ~= "ka"
        if p_level > config.n_levels
            error("specified level is too big")
        end
    else % kappa is n_levels - 1
        if p_level > (config.n_levels - 1)
            error("specified level is too big")
        end
    end
end


%% find which value we're changing

% find the location of the param
target_field = strcat(p_trans{found_p},param_fields{found_p},mu_or_sa);

% update it
config.(target_field)(p_level) = new_value;

% perform align_priors
out_config = align_priors(config);

%% list free params

if exist('print_opt','var')
    if print_opt == "none"
        return
    end
else
    print_config_info(out_config,param_fields,p_trans)
end