function plot_ymxc(x,y,lw)

lm = fitlm(x,y);
c = lm.Coefficients.Estimate(1);
m = lm.Coefficients.Estimate(2);
line([min(x) max(x)], [m*min(x)+c m*max(x)+c], 'color', [150/255,150/255,150/255],"LineWidth",lw);
