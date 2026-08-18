% cd & path etc 
cd 'C:\Users\timot\Documents\GitHub\ghgf-toolbox'
addpath(genpath("C:\Users\timot\Documents\GitHub\ghgf-toolbox")) % should include funcs

% load iglesias
u = load(fullfile('demo', 'example_binary_input.txt'));

% classic hgf

bopars_o = fitModel([],...
                         u,...
                         'hgf_binary_config',...
                         'bayes_optimal_binary_config',...
                         'quasinewton_optim_config');
isequal(bopars_o,bopars) % doesnt seem to work but should be right

% should make a model checking function 
% prints correlations between params
% print se of params
1.96*sqrt(diag(bopars.optim.Sigma))

% ehgf 

% ehgf_config c.ommu = [NaN,  -3,   2];

e_bopars_o = fitModel([],...
                         u,...
                         'ehgf_binary_config',...
                         'bayes_optimal_binary_config',...
                         'quasinewton_optim_config');

1.96*sqrt(diag(e_bopars_o.optim.Sigma))


% uhgf 

u_bopars_o = fitModel([],...
                         u,...
                         'uhgf_binary_config',...
                         'bayes_optimal_binary_config',...
                         'quasinewton_optim_config');

1.96*sqrt(diag(u_bopars_o.optim.Sigma))

% use function
bopars = hgf_binary_bopars(u,'hgf_binary_config',true);
e_bopars = hgf_binary_bopars(u,'ehgf_binary_config',true);
u_bopars = hgf_binary_bopars(u,'uhgf_binary_config',true);

% try higher om3 

u_config = uhgf_binary_config();
u_config.ommu(3) = 3; 
u_config = align_priors(u_config);

u_bopars_om3 = hgf_binary_bopars(u,u_config,true);

% try ar1 
ar1_bopars = hgf_binary_bopars(u,'hgf_ar1_binary_config',true);
% some correlation between m_3 and om2 

e_ar1_bopars = hgf_binary_bopars(u,'ehgf_ar1_binary_config',true);
% doesn't look right

% try ar1 uhgf 
u_ar1_config = uhgf_ar1_binary_config();
hgf_binary_bopars(u,'uhgf_ar1_binary_config',true);
% fails

% needed to add num_prec stuff
% should probs have left this for the rosetta stone branch

% works fine now, bar the plot
% no uhgf_ar1_binary_plotTraj
u_ar1_bopars = hgf_binary_bopars(u,'uhgf_ar1_binary_config',false);
ehgf_ar1_binary_plotTraj(u_ar1_bopars)

% values from the demo didn't seem to work, trying original
% do this a different way now

%% update/init

% need to update with multiple parameters 
% ? take in a cell/table with incoming parameters

config = hgf_binary_config();
update_config(config,"sa0_3","sa",1);
init_config('hgf_binary_config',"sa0_3","sa",1);

% demonstrate mu0 sa0
update_config(config,"sa_0_3","sa",1);
update_config(config,"sa0_3","sa",1);

% disable printing
update_config(config,"sa_0_3","sa",1,"none");


%% 

% think its probably more intuitive to use the config throughout any model
% fitting 

%% could also make sim_unitsq function

% maybe just simModel_config

% sim_unitsq(u,prc_config,zeta,seed)

% check if priors has been done, if not return an erro
% (user should check if its normal or fields)

% get model from prc_config

sim = simModel(u,...
                     'hgf_binary',...
                     [NaN 0 1 NaN 1 1 NaN 0 0 1 1 NaN -2.5 -6],...
                     'unitsq_sgm',...
                     5,...
                     123456789);

e_sim = simModel(u,...
                     'ehgf_binary',...
                     [NaN 0 1 NaN 1 1 NaN 0 0 1 1.5 NaN -4 3],...
                     'unitsq_sgm',...
                     5,...
                     123456789); 

u_sim = simModel(u,...
                     'uhgf_binary',...
                     [NaN 0 1 NaN 1 1 NaN 0 0 1 1 NaN -2.5 -6],...
                     'unitsq_sgm',...
                     5,...
                     123456789);
