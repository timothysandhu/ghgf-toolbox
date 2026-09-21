function [implausible_mu2,corr_params,failed_fit] = fit_check(hgf_data,plot)
% check hgf fit
% INPUT
% hgf_data: cell array of fitted hgf
% plot_bin: binary for whether or not we want to plot

%% input check

%% get id and valence
hgf_id = cellfun(@(x) x.id,hgf_data);
hgf_val = cellfun(@(x) x.valence,hgf_data);

%% check for weird jumps in the trajectories (don't think first level matters)

% plot
if plot
    imagesc(cellstruct2array(hgf_data,"x.traj.mu(:,2)",2))
end

% difference
diff_mu2_traj = cellstruct2array(hgf_data,"abs(diff(x.traj.mu(:,2)))",2);

% find people with big jumps
max_mu2 = max(diff_mu2_traj,[],2);
max_max_mu2 = mean(max(diff_mu2_traj,[],2))+3*std(max(diff_mu2_traj,[],2));
jump_mu2 = max_mu2 > max_max_mu2;

% find people with big final values
final_traj = cellstruct2array(hgf_data,"x.traj.mu(end,:)'",2); % check final value of x2
big_fin_traj = mean(final_traj) + 3*std(final_traj);
low_fin_traj = mean(final_traj) - 3*std(final_traj);
big_final_mu2 = final_traj(:,2)>big_fin_traj(2);
low_final_mu2 = final_traj(:,2)<low_fin_traj(2);
final_mu2 = [big_final_mu2;low_final_mu2];

% implausible trajectories
implausible_mu2_inds = unique([find(jump_mu2);find(final_mu2)]);

%% correlation between parameters

% get names for table
prc_names = hgf_config_names(hgf_data{1},"prc");
obs_names = hgf_config_names(hgf_data{1},"obs");
param_names = [prc_names; obs_names];
n_free_params = length(param_names);

% get the names
for i = 1:n_free_params
    for j = 1:n_free_params
        corr_names{n_free_params*(i-1)+j} = strcat(param_names{i},'_',param_names{j});
        corr_check(n_free_params*(i-1)+j) = i < j; % < for reshape
    end
end

% get the table
corr_arr = cellstruct2array(hgf_data,"reshape(x.optim.Corr,[],1)",2);

% abs
abs_corr_arr = abs(corr_arr(:,corr_check));
corr_param_inds = find(abs_corr_arr>.95);

%% make sure no negll is inf

failed_fit_inds = find(isinf(cellfun(@(x) x.optim.negLl,hgf_data)));

%% output

% assign inds to usable features
implausible_mu2 = assign_inds_tbl(hgf_id,hgf_val,implausible_mu2_inds); % implausible
corr_params = assign_inds_tbl(hgf_id,hgf_val,corr_param_inds);
failed_fit = assign_inds_tbl(hgf_id,hgf_val,failed_fit_inds);

end

%% helper
function out_tbl = assign_inds_tbl(ids,vals,inds)
if ~isempty(inds)
    out_tbl = table();
    out_tbl.index = inds;
    out_tbl.id = ids(inds)';
    out_tbl.val = vals(inds)';
else
    out_tbl = [];
end
end