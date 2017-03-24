function plot_TLEvPROP(kepler_TLE,kepler_PROP)

figure;
labels = {'a [m]','e [-]','i [deg]','\Omega [deg]','\omega [deg]','\vartheta [deg]'};
for i = 1:6
    subplot(3,2,i)
    plot(kepler_TLE(2:end,1),kepler_TLE(2:end,i+1),'b')
    hold on;
    plot(kepler_PROP(:,1),kepler_PROP(:,i+1),'r')
    xlabel('Time [days]');
    ylabel(labels{i});
    legend("Actual TLE","Propagated")
    grid on;
    set(gca,'FontSize',13);
end
end



