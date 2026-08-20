function validate_hgf_param_tbl(param_tbl)
%VALIDATE_PARAM_TBL param_tbl must be a table with the columns produced by
% hgf_param_tbl.m: param_name, mu_or_sa, new_value.
if ~istable(param_tbl)
    error("second argument should be a table built with hgf_param_tbl")
end
required = ["param_name","mu_or_sa","new_value"];
missing = setdiff(required,string(param_tbl.Properties.VariableNames));
if ~isempty(missing)
    error("param table is missing column(s): %s",strjoin(missing,", "))
end
end