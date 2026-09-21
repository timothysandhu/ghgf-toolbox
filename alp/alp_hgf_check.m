function model_tbl = alp_hgf_check(hgf_data,task_name)

%% check drumstickers removed, if not remove them
hgf_id = cellfun(@(x) x.id,hgf_data);

ds = readmatrix(strcat(task_name,"_drumstick.csv"));
ds_check = ismember(hgf_id,ds);

%if sum(ds_check)>0
%    hgf_data(ds_check)=[];
%    hgf_id(ds_check)=[];
%end

%% check for weird jumps in the trajectories (don't think first level matters)

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

%% parameter values

% get names for table
prc_names = hgf_config_names(hgf_data{1},"prc");
obs_names = hgf_config_names(hgf_data{1},"obs");
param_names = [prc_names; obs_names];
n_free_params = length(param_names);

% find which columns to keep
prior_sas = [hgf_data{1}.c_prc.priorsas hgf_data{1}.c_obs.priorsas];
param_free = prior_sas;
param_free(isnan(param_free)) = 0;
param_free = find(param_free);

% param vals 
param_array = cellstruct2array(hgf_data,"x.optim.final'",2);
param_array = param_array(:,param_free);

% check low values
param_table = array2table(param_array,"VariableNames",param_names);
low_om2 = param_table.om2<-8;

%% correlation between parameters

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
corr_params = abs_corr_arr>.95;

%% make sure no negll is inf

failed_fit = isinf(cellfun(@(x) x.optim.negLl,hgf_data));

%% make a table 

all_model_check_arr = [hgf_id' param_array corr_params low_om2 failed_fit' ds_check' jump_mu2 big_final_mu2 low_final_mu2];
all_model_check_names = {'id',param_names{1},param_names{2},cell2mat(strcat('high_corr_',corr_names(corr_check))),'low_om2','failed_fit','drumsticker','jump_tend','big_final_tend','low_final_tend'};
model_tbl = array2table(all_model_check_arr,"VariableNames",all_model_check_names);
writetable(model_tbl,strcat(task_name,"_hgf_out.csv"))
%writetable(model_tbl,strcat(task_name,"_hgf_hivar_out.csv"))