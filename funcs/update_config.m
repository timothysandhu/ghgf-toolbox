function out_config = update_config(config,param_name,mu_or_sa,new_value,varargin)
%update_config Update a HGF config structure

% initially just prc?
% test on binary, ar1

% LOOK AT ALIGN PRIORS

%% input checks
% note param_name checked below, more involved

% config check
if ~prc_config_check(config)
    error("doesn't look like a hgf prc config")
end

% mu_or_sa check
if ~(strcmp(mu_or_sa,"mu")||strcmp(mu_or_sa,"sa"))
    error("third arg should be either mu (mean) or sa (variance)")
end

% new_value check
if ~isnumeric(new_value)
    error("final argument should be the new value")
end

% parse vargin
if ~isempty(varargin)
    print_opt = varargin{1};
    if print_opt ~= "none"
        error("you can only disable printing with none")
    end
end

%% param_name checks

% param_name - split to param level
p_parts = split(lower(param_name),"_");

% check number of parts
if numel(p_parts) ~= 2
    error('param name should split by _ into two parts');
end

% assign
[p_name,p_level] = deal(p_parts(1),str2num(p_parts(2)));

% smooth parameter names
if p_name == "kappa"
    p_name = "ka";
elseif p_name == "omega"
    p_name = "om";
elseif p_name == "mu0"
    p_name = "mu_0";
elseif p_name == "sa0"
    p_name = "sa_0";
end

% all possible params in the prc
[param_fields,p_trans]=find_param_fields(config);

% check param_name against the names
found_p = strcmp(param_fields,p_name);
if ~(contains(param_fields,p_name))
    error("don't recognise the parameter name")
end

% check level
if p_level > 0
    if p_name ~= "ka"
        if p_level > config.n_levels
            error("specified level is too big")
        end
    else % kappa is n_levels - 1
        if p_level > (config.n_levels - 1)
            error("specified level is too big")
        end
    end
end


%% find which value we're changing

% find the location of the param
target_field = strcat(p_trans{found_p},param_fields{found_p},mu_or_sa);

% update it
config.(target_field)(p_level) = new_value;

% perform align_priors
out_config = align_priors(config);

%% list free params

if exist('print_opt','var')
    if print_opt == "none"
        return
    end
else

    % find the expected number of params
    n_param_fields = length(param_fields);
    if any(contains(param_fields,"ka"))
        expected_n_params = 3*(n_param_fields-1) + 2;
    else
        expected_n_params = 3*(n_param_fields);
    end

    % find the parameter names
    all_param_names = strings(1,expected_n_params);
    all_param_trans = strings(1,expected_n_params);
    all_param_nums = nan(1,expected_n_params);
    p_count = 0;
    for i = 1:n_param_fields
        if param_fields{i} ~= "ka"
            up_inds = p_count+1:p_count+3;
            all_param_names(up_inds) = param_fields{i};
            if ~isempty(p_trans{i})
                all_param_trans(up_inds) = p_trans{i};
            end
            all_param_nums(up_inds) = 1:3;
            p_count = p_count + 3;
        else
            up_inds = p_count+1:p_count+2;
            all_param_names(up_inds) = param_fields{i};
            if ~isempty(p_trans{i})
                all_param_trans(up_inds) = p_trans{i};
            end
            all_param_nums(up_inds) = 1:2;
            p_count = p_count + 2;
        end
    end
    if p_count ~= expected_n_params
        error("issue with expected number of params")
    end

    % which params aren't free
    free_param_mask = (out_config.priorsas ~= 0 & ~isnan(out_config.priorsas));
    n_free_params = sum(free_param_mask);
    ind_free_params = find(free_param_mask);

    % make the string array
    free_params_str_array = make_free_param_text(ind_free_params,...
        all_param_names,...
        all_param_nums,...
        all_param_trans,...
        out_config.priormus,...
        out_config.priorsas);

    % print
    disp("Please note, sa is variance not standard deviation.")
    for i = 1:n_free_params
        disp(free_params_str_array(i))
    end
end
end

%% PRINT

% print transforms and free parameters every time
% log/logit/exp?


% add note that sa is variance

% add full print option

% from fitModel
% ftbrm = {'p', 'ptrans'};
% dispprc = rmfield(r.p_prc, ftbrm);
% dispobs = rmfield(r.p_obs, ftbrm);
%
% disp(' ')
% disp('Results:');
% disp(' ')
% disp('Parameter estimates for the perceptual model:');
% disp(dispprc)
% if ~isempty(fieldnames(dispobs))
%     disp(' ')
%     disp('Parameter estimates for the observation model:');
%     disp(dispobs)
% end

function [sentence_array] = make_free_param_text(param_inds,names,nums,trans,mu,sa)

n_params = length(param_inds);

sentence_array = strings(1,n_params);

for i=1:length(param_inds)
    p_ind = param_inds(i);
    i_name = names(p_ind);
    i_nums = nums(p_ind);
    i_trans = trans(p_ind);
    i_mu = mu(p_ind);
    i_sa = sa(p_ind);
    sentence_array(i) = strcat(i_name," at level ",num2str(i_nums)," is estimated with mean ",num2str(i_mu)," and variance ",num2str(i_sa));
    if i_trans ~= ""
        sentence_array(i) = strcat(sentence_array(i)," in ",i_trans," space.");
    else
        sentence_array(i) = strcat(sentence_array(i),".");
    end
end

end

