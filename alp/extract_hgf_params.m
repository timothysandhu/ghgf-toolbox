function model_tbl = extract_hgf_params(hgf_data)

%% get id and valence
hgf_id = cellfun(@(x) x.id,hgf_data);
hgf_val = cellfun(@(x) x.valence,hgf_data);

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

%% make a table 
model_arr_names = {'id','valence',param_names{1},param_names{2}};
model_arr = [hgf_id' hgf_val' param_array];
model_tbl = array2table(model_arr,"VariableNames",model_arr_names);