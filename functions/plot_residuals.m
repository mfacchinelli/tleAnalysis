function plot_residuals(residuals,time)

figure;
labels = {'da [m]','de [-]','di [deg]','d\Omega [deg]'};
for i = 1:4
    
    subplot(2,2,i)
    hold on;
    plot(time,residuals(:,i))
    xlabel('Time [days]');
    ylabel(labels{i});
    legend("Residuals")
    grid on;
    set(gca,'FontSize',13);
end


end

