% paths 
cd 'C:\Users\timot\Documents\GitHub\ghgf-toolbox'
addpath(genpath("C:\Users\timot\Documents\GitHub\ghgf-toolbox")) % should include funcs
addpath(genpath("C:\Users\timot\Documents\GitHub\core\matlab"))

% dirs
data_dir = 'C:\Users\timot\Documents\GitHub\gorillar\';
u_dir = 'C:\Users\timot\Documents\GitHub\assoc_learning\camraa\';

% get camraa input 
u = load(strcat(u_dir,'camraa_input.txt')); % camraa input

min_rts = [100, 150, 200];

% drumstickers are always included during fitting
drumstickers = true;

for i = 1:length(min_rts)

    min_rt = min_rts(i);
    min_rt_str = strcat("minrt", num2str(min_rt));

    fprintf("\n==============================\n");
    fprintf("Running min_rt = %d\n", min_rt);
    fprintf("==============================\n");

    %% prep task data

    % drumstickers included during fitting
    [fh_data, fh_id] = prep_data(data_dir, "face_house", min_rt, false);
    [ss_data, ss_id] = prep_data(data_dir, "stick_snake", min_rt, false);

    %% drumstickers

    fh_ds = readmatrix( ...
        strcat(data_dir, "data\", min_rt_str, "\", ...
        "face_house_drumstickers_", min_rt_str, ".csv"));

    ss_ds = readmatrix( ...
        strcat(data_dir, "data\", min_rt_str, "\", ...
        "stick_snake_drumstickers_", min_rt_str, ".csv"));

    %% combine

    all_data = [fh_data; ss_data];
    all_id = [fh_id; ss_id];
    all_val = [ ...
        repmat("sensory", length(fh_id), 1); ...
        repmat("aversive", length(ss_id), 1) ...
    ];

    %% parameter recovery / model configuration

    % 2 level
    prc_config = ehgf_binary_config();
    config_2l = make_hgf_2l(prc_config);
    config_2l = update_config(config_2l, "om_2", "sa", 1);

    %% model fit

    obs_config = unitsq_sgm_config();

    ehgf_fit = model_fit_all( ...
        u, ...
        all_data, ...
        config_2l, ...
        obs_config, ...
        all_id, ...
        all_val);

    %% save model fit

    mat_file = strcat( ...
        data_dir, "data\", ...
        min_rt_str, "\", ...
        "ehgf_minrt", num2str(min_rt), "_with_ds.mat");

    save(mat_file, "ehgf_fit");

    fprintf("Saved model fit: %s\n", mat_file);

    %% check fits

    [implausible_mu2, corr_params, failed_fit] = ...
        fit_check(ehgf_fit, false);

    %% extract parameters

    param_tbl = extract_hgf_params(ehgf_fit);

    low_om2_ind = find(str2double(param_tbl.om2) < -8);

    %% identify participants to exclude

    ind_to_exc = [];

    if ~isempty(implausible_mu2)
        ind_to_exc = [ind_to_exc; implausible_mu2.index];
    end

    if ~isempty(corr_params)
        ind_to_exc = [ind_to_exc; corr_params.index];
    end

    if ~isempty(low_om2_ind)
        ind_to_exc = [ind_to_exc; low_om2_ind];
    end

    if ~isempty(failed_fit)
        ind_to_exc = [ind_to_exc; failed_fit];
    end

    %% exclude problematic fits

    param_tbl(ind_to_exc, :) = [];

    %% save parameter table

    csv_file = strcat( ...
        data_dir, "data\", ...
        min_rt_str, "\", ...
        "ehgf_params_minrt", num2str(min_rt), "_with_ds.csv");

    writetable(param_tbl, csv_file);

    fprintf("Saved parameter table: %s\n", csv_file);
    fprintf("Excluded %d fits\n", length(ind_to_exc));

end