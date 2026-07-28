function [param_names,param_trans] = find_param_fields(c)
%find_param_fields

%% input check 

if ~prc_config_check(c)
    error("doesn't look like a hgf prc config")
end

%% main 

% get field names 
f_names = fieldnames(c);

% which end in mu
[mu_mask,mu_strip] = match_end_stripped(f_names,"mu");

% which end in sa
[sa_mask,sa_strip] = match_end_stripped(f_names,"sa");

% check the stripped values match
if ~all(strcmp(sa_strip,mu_strip))
    error("the mu and sa are mismatched")
end

% check the positions match 
if find(mu_mask) ~= (find(sa_mask)-1)
    error("the mu and sa are mismatched")
end

% check for transformations

% return the parameters if all good
[param_names,param_trans] = check_param_trans(mu_strip);

end
%% functions 

function [mask,stripped] = match_end_stripped(f_names,end_str)
if class(f_names) ~= "cell"
    error("supply the cell array of field names")
end

% length of str 
end_len = strlength(end_str);

% mask
mask = endsWith(string(f_names), end_str);

% matches 
matches = f_names(mask);

% strip the end
strip_end = @(x) x(1:end-(end_len));
stripped = cellfun(strip_end,matches,'UniformOutput',false);

end

function [stripped] = strip_start(param_names,start_str)
% check stripped param names 
check_stripped_param_names(param_names);

% n_params 
n_params = length(param_names);

% length of str 
start_len = strlength(start_str);

% mask
mask = startsWith(string(param_names), start_str);

% strip the start
stripped = param_names;
strip_start = @(x) x(1+start_len:end);

for i = 1:n_params
    if mask(i)
        stripped{i} = strip_start(stripped{i});
    end
end

end

function [out_param_names,ptrans] = check_param_trans(in_param_names)
% check stripped param names 
check_stripped_param_names(in_param_names);

% initialize output 
ptrans = cell(length(in_param_names),1);

% possible transformations are log/logit 
mask_logit = startsWith(string(in_param_names), "logit");
mask_log   = startsWith(string(in_param_names), "log") & ~mask_logit;

% label 
ptrans(mask_logit) = {"logit"};
ptrans(mask_log) = {"log"};

% strip 
new_param_names = strip_start(in_param_names,"logit");
out_param_names = strip_start(new_param_names,"log");

end

function check_stripped_param_names(param_names)
% should be cell array
if class(param_names) ~= "cell"
    error("supply the cell array of stripped param names")
end

% check stripping 
if any(cellfun(@(x) endsWith(x,"mu"),param_names))||any(cellfun(@(x) endsWith(x,"sa"),param_names))
    error("supply the cell array of stripped param names")
end
end
