function all_names = hgf_config_names(r,model_type)
% ripped off tapas_fit_plotCorr
% inputs 
% r = hgf fitted object 
% model_type = string, either prc or obs

if ~(model_type == "prc" || model_type == "obs")
    error("unknown model type")
end

prior_sas = getfield(r,strcat("c_",model_type),"priorsas");
post_params_struct = getfield(r,strcat("p_",model_type));
post_params_vals = getfield(r,strcat("p_",model_type),"p");

free_ind = prior_sas;
free_ind(isnan(free_ind)) = 0;
free_ind = find(free_ind);

field_names = fieldnames(post_params_struct);
field_vals = struct2cell(post_params_struct);
all_names = [];
for k = 1:length(field_names)
    for l= 1:length(field_vals{k})
        if l == 1
            all_names = [all_names, field_names(k)];
        else
            all_names = [all_names, strcat(field_names(k),num2str(l))];
        end
    end
end
all_names = all_names(1:length(post_params_vals))';
all_names = all_names(free_ind);