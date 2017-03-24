function plot_TLEvPROP(kepler_TLE,kepler_PROP)

figure;
labels = {'a [m]','e [-]','i [deg]','\Omega [deg]','\omega [deg]','\vartheta [deg]'};
for i = 1:6
    subplot(3,2,i)
    hold on;
    plot(kepler_TLE(:,1),kepler_TLE(:,i+1),'b')
    plot(kepler_PROP(:,1),kepler_PROP(:,i+1),'r')
    xlabel('Time []');
    ylabel(labels{i});
    xlim([kepler_TLE(1,1),kepler_TLE(end,1)]);
    ylim(ylimit);
    grid on;
    set(gca,'FontSize',13);
end
end



