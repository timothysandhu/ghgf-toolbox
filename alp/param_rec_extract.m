function [sim,fit,corr] = param_rec_extract(simul,fitted,param_name)
% take a parameter name, cleave an extraction function, apply to simulated
% and fitted

% parse param name
if strcmp(param_name,"zeta")
    ext_fun = @(x) x.p_obs.ze;
elseif strcmp(param_name,"om_2")
    ext_fun = @(x) x.p_prc.om(2);
elseif strcmp(param_name,"om_3")
    ext_fun = @(x) x.p_prc.om(3);
else
    error("don't know this parameter")
end

% simulated
sim = cellfun(ext_fun,simul);

% fitted 
fit = cellfun(ext_fun,fitted);

% look at the correlation
corr = corrcoef(sim,fit);
