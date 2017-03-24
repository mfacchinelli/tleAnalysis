%  MATLAB Function < plotAll >
%
%  Purpose:     plot observed vs. propagated Keplerian elements and
%               residuals over time
%  Input:
%   - keplerTLE:    observed Keplerian elements
%   - keplerProp:   propagated Keplerian elements
%   - residuals:    difference between TLE and Prop
%   - options:      structure array containing:
%                       1) offset:  TLEs to skip
% Output:
%   - N/A

function plotAll(keplerTLE,keplerProp,residuals,options)

%...Extract options
k = options.offset;

%...Plot TLE vs. propagation
figure;
labels = {'a [m]','e [-]','i [rad]','\Omega [rad]','\omega [rad]','\vartheta [rad]'};
for i = 1:6
    subplot(3,2,i)
    hold on
    plot(keplerTLE(2:k:end,1),keplerTLE(2:k:end,i+1))
    plot(keplerProp(:,1),keplerProp(:,i+1))
    hold off
    xlabel('Time [day]')
    ylabel(labels{i})
    legend('Observed','Propagated')
    grid on
    set(gca,'FontSize',13)
end

%...Plot residuals
figure;
labels = {'\Delta a [m]','\Delta e [-]','\Delta i [rad]','\Delta \Omega [rad]'};
for i = 1:4
    subplot(2,2,i)
    hold on;
    plot(keplerProp(:,1),residuals(:,i))
    xlabel('Time [day]');
    ylabel(labels{i});
    grid on;
    set(gca,'FontSize',13);
end