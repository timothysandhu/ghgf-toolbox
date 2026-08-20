function out_config = update_config(config,varargin)
%UPDATE_CONFIG Update one or more parameters in a HGF prc config structure.
% initially just prc? test on binary, ar1
% to prevent erroneous calls to the inner funcs, put them within this one
%
% Single-parameter usage (updates exactly one field):
%   out_config = update_config(config,param_name,mu_or_sa,new_value)
%   out_config = update_config(config,param_name,mu_or_sa,new_value,print_opt)
%
% Batch usage (applies every row of a parameter table/struct array in turn):
%   out_config = update_config(config,param_updates)
%   out_config = update_config(config,param_updates,print_opt)
%
% param_updates must be either:
%   - a table with variables param_name, mu_or_sa, new_value
%     (one row per update), or
%   - a struct array with fields param_name, mu_or_sa, new_value
%     (one element per update)
%
% print_opt:
%   pass "none" as the last argument to suppress the printed free-parameter
%   summary. No other value is accepted (matches the single-update rule).
%
% Examples:
%   update_config(config,"om_2","mu",-3)
%   update_config(config,"om_2","mu",-3,"none")
%
%   upd = table(["om_2";"ka_1"],["mu";"mu"],[-3;0.5], ...
%           'VariableNames',{'param_name','mu_or_sa','new_value'});
%   update_config(config,upd)
%   update_config(config,upd,"none")

switch nargin
    case 2
        out_config = update_config_multi(config,varargin{1},"");
    case 3
        out_config = update_config_multi(config,varargin{1},varargin{2});
    case 4
        out_config = update_config_single(config,varargin{1},varargin{2},varargin{3},"");
    case 5
        out_config = update_config_single(config,varargin{1},varargin{2},varargin{3},varargin{4});
    otherwise
        error("update_config expects 2 to 5 input arguments (got %d)",nargin);
end

end

function out_config = update_config_single(config,param_name,mu_or_sa,new_value,print_opt)
%update_config Update a HGF config structure
%UPDATE_CONFIG_SINGLE Update a single (param_name,mu_or_sa) field to new_value.
% do not run this directly, run it through update_config wrapper

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

% print_opt check
validate_print_opt(print_opt);

%% param_name checks

% param_name - split to param level
p_parts = split(lower(param_name),"_");

% check numebr of parts, make sure mu0 and sa0 caught explicitly
if all(strcmp(p_parts(1:2),["mu";"0"])) || all(strcmp(p_parts(1:2),["sa";"0"]))
    error('for initial means and variances at x level, use mu0_x or sa0_x')
elseif numel(p_parts) ~= 2
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

if print_opt ~= "none"
    print_config_info(out_config,param_fields,p_trans)
end

end

function out_config = update_config_multi(config,param_tbl,print_opt)
%UPDATE_CONFIG_BATCH Apply a table/struct array of parameter updates in turn.
% Each row is applied via update_config_single (with its own printing
% suppressed); the free-parameter summary, if requested, is printed once
% at the end against the final config.
% do not run this directly, run it through update_config wrapper

validate_print_opt(print_opt);
validate_hgf_param_tbl(param_tbl);
 
out_config = config;
for i = 1:height(param_tbl)
    out_config = update_config_single(out_config,param_tbl.param_name(i), ...
        param_tbl.mu_or_sa(i),param_tbl.new_value(i),"none");
end
 
if print_opt ~= "none"
    [param_fields,p_trans] = find_param_fields(out_config);
    print_config_info(out_config,param_fields,p_trans)
end
 
end
