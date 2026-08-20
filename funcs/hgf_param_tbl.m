function param_tbl = hgf_param_tbl(param_names,mu_or_sas,new_values)
%HGF_PARAM_TBL Build a param_updates table for update_config's batch mode.
%   param_tbl = hgf_param_tbl(param_names,mu_or_sas,new_values)
%
%   param_names, mu_or_sas : string arrays (any orientation)
%   new_values              : numeric array (any orientation)
%
%   Returns a table with variables param_name, mu_or_sa, new_value
%   (one row per update), ready to pass into update_config(config,param_tbl).

% names and mu_or_sas need to be strings
if class(param_names)~= "string" || class(mu_or_sas)~= "string"
    error('The first two inputs should be string arrays')
end
% new_values needs to be numeric
if ~isnumeric(new_values)
    error('The third input should be numeric')
end

% force column vectors, so table() gives one row per update regardless
% of whether row or column vectors were passed in
param_names = param_names(:);
mu_or_sas   = mu_or_sas(:);
new_values  = new_values(:);

% mu_or_sas can only contain mu or sa
len_mos = length(mu_or_sas);
mus = strcmp(mu_or_sas,"mu");
sas = strcmp(mu_or_sas,"sa");
if(sum(mus+sas)~=len_mos)
    error('The second input must contain either mu or sa')
end
% they need all be the same length
if any([length(param_names),length(mu_or_sas),length(new_values)]~=length(param_names))
    error('The inputs have different lengths')
end

param_tbl = table(param_names,mu_or_sas,new_values,...
    'VariableNames',{'param_name','mu_or_sa','new_value'});

end