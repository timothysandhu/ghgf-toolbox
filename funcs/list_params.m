function [all_param_names,all_param_nums,all_param_trans] = list_params(varargin)

if nargin==1
    % check it's a struct
    if class(varargin{1})=="struct" && prc_config_check(varargin{1})
        [param_fields,p_trans] = find_param_fields(varargin{1});
    else
        error("if only one argument, must be a hgf config struct")
    end
elseif nargin==2
    param_fields = varargin{1};
    p_trans = varargin{2};
else
    error("wrong number of arguments")
end

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