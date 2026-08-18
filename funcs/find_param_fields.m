function [param_names,param_trans] = find_param_fields(c)
%FIND_PARAM_FIELDS Extract parameter names and transforms from an hgf
%   prc config struct with paired *mu / *sa fields.

%% input check 

if ~prc_config_check(c)
    error("doesn't look like a hgf prc config")
end

%% main 

% get field names 
f_names = fieldnames(c);

% which end in mu / sa
mu_mask = endsWith(f_names, "mu");
sa_mask = endsWith(f_names, "sa");

mu_strip = regexprep(f_names(mu_mask), "mu$", "");
sa_strip = regexprep(f_names(sa_mask), "sa$", "");

% check the stripped values match
if ~all(strcmp(sa_strip,mu_strip))
    error("the mu and sa are mismatched")
end

% check the positions match 
if ~isequal(find(mu_mask), find(sa_mask) - 1)
    error("the mu and sa are mismatched")
end

% check for transformations, return the parameters if all good
[param_names,param_trans] = check_param_trans(mu_strip);

end

%% functions
function stripped = strip_start(param_names, start_str)

check_stripped_param_names(param_names);

names = string(param_names);
mask = startsWith(names, start_str);

stripped = names;
stripped(mask) = extractAfter(names(mask), start_str);

stripped = cellstr(stripped);
end

function [out_param_names,ptrans] = check_param_trans(in_param_names)
check_stripped_param_names(in_param_names);

names = string(in_param_names);
n = numel(names);

% possible transformations are log/logit
mask_logit = startsWith(names, "logit");
mask_log   = startsWith(names, "log") & ~mask_logit;

ptrans = cell(n,1);
ptrans(mask_logit) = {"logit"};
ptrans(mask_log)   = {"log"};

% strip
new_param_names = strip_start(names, "logit");
out_param_names = strip_start(new_param_names, "log");
end

function check_stripped_param_names(param_names)

%if ~iscell(param_names)
%    error("supply the cell array of stripped param names")
%end

names = string(param_names);
if any(endsWith(names, "mu")) || any(endsWith(names, "sa"))
    error("supply the cell array of stripped param names")
end
end