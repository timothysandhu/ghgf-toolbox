function [bopars] = hgf_binary_bopars(u,config,plot)
% to save repetition 
% inputs 
% u: column vector
% config: either a string/structure
% plot: logical, plot or not

% check fit model is the right one 
if ~contains(which("fitModel"),"ghgf-toolbox")
    error("wrong fitmodel on path")
end

% u check 
if size(u,2) ~= 1
    error("u must be a column vector")
end

% config check 
switch(class(config))
    case 'char'
        plot_func = [config(1:end-7) '_plotTraj'];
    case 'struct'
        if ~prc_config_check(config)
            error("doesn't look like a hgf prc config")
        end
        plot_func = [config.model '_plotTraj'];
    otherwise
        error("config must be either a string or a hgf prc config")
end

% plot 
if class(plot) ~= "logical"
    error("plot must be logical")
end

% do the bopars 
bopars = fitModel([],...
    u,...
    config,...
    'bayes_optimal_binary_config',...
    'quasinewton_optim_config');

% plot optionally
if plot
eval([plot_func '(bopars)'])
end

end