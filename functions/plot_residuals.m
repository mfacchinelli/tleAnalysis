function plot_residuals(residuals,time)

figure;
labels = {'da [m]','de [-]','di [deg]','d\Omega [deg]'};
for i = 1:4
    subplot(2,2,i)
    hold on;
    plot(time,residuals(:,i))
    xlabel('Time []');
    ylabel(labels{i});
    xlim([time(1,1),time(end,1)]);
    ylim(ylimit);
    grid on;
    set(gca,'FontSize',13);
end


end

