function print_config_info(out_config,varargin)

% if supplied 
if ~isempty(varargin)
    param_fields = varargin{1};
    p_trans = varargin{2};
else
    [param_fields,p_trans] = find_param_fields(out_config);
end

% find the param names, numbers and trans 
[all_param_names,all_param_nums,all_param_trans] = list_params(param_fields,p_trans);

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