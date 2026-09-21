function param_rec_plot(sim,fit,corr,param_name)

% parse param name
if strcmp(param_name,"zeta")
    title_prefix = '$\zeta$';
elseif strcmp(param_name,"om_2")
    %title_prefix = '\omega_2';
    title_prefix ='$\omega_{\fontsize{8}{8}2}$';
elseif strcmp(param_name,"om_3")
    title_prefix ='$\omega_{\fontsize{8}{8}3}$';
else
    error("don't know this parameter")
end

hold on

plot(sim,fit,'o',"LineWidth",4)
plot_ymxc(sim,fit,4)
title(strcat(title_prefix,' corr=',num2str(round(corr(2,1),3))), 'Interpreter', 'latex')
xlabel('simulated', 'Interpreter', 'latex')
ylabel('fitted', 'Interpreter', 'latex')
h = gca;
box on
h.TickLabelInterpreter = 'latex';
h.LineWidth = 4;
h.XAxis.TickLength = [0 0]; 
h.YAxis.TickLength = [0 0]; 
h.FontName = 'MyriadPro';
h.FontSize = 14;
lowest = min(min(sim),min(fit));
biggest = max(max(sim),max(fit));
xlim([lowest biggest])
ylim([lowest biggest])
hold off