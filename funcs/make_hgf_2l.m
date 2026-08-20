function config = make_hgf_2l(config,varargin)
% remove the 3rd level from a binary HGF 
% as per
% https://github.com/translationalneuromodeling/tapas/issues/35


if nargin==2
    validate_print_opt(varargin{1})
elseif nargin>2
    error("only the config and the print option can be passed")
end


% check its a hgf prc config 
if ~prc_config_check(config)
    error("not a hgf config")
end

% get the param names 
p_names = string(find_param_fields(config));
n_params = length(p_names);

% remove _ from initial values 
p_names = erase(p_names,"_");

% determine levels
lev_vec = 3*ones(n_params,1);
lev_vec(p_names=="ka")=2;

% add _ level
p_names = strcat(p_names,"_",num2str(lev_vec));

% initialize the vectors
mos_vec = repmat("sa",n_params,1);
val_vec = zeros(n_params,1);

% change the kappa ones
ka2_ind = p_names=="ka_2";
mos_vec(ka2_ind)="mu";
val_vec(ka2_ind)=-Inf;

% prepare the tbl
tbl_2l = hgf_param_tbl(p_names,mos_vec,val_vec);

% update 
if nargin==2
    config = update_config(config,tbl_2l,"none");
else
    % print if required
    disp("Please note, this is a 2 level HGF model.")
    config = update_config(config,tbl_2l);
end