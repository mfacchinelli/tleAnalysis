%  MATLAB Function < plotAll >
%
%  Purpose:     plot observed vs. propagated Keplerian elements and
%               residuals over time
%  Input:
%   - which:    string specifiying which plots to show
%   - inputs:   cell array of inputs for each specific case
%   - options:  structure array containing:
%               	1) file:    file name to be read, to extract TLE 
%                               information
%                   2) offset:  Tnumber of steps to take between observations
% Output:
%   - N/A

function plotAll(which,inputs,options)

switch which
    case 'elements'
        %...Extract options
        file = replace(options.file,'files/','');
        
        %...Extract inputs
        kepler = inputs{1};
        
        %...Plot Keplerian elements
        figure;
        labels = {'a [m]','e [-]','i [rad]','\Omega [rad]','\omega [rad]','\vartheta [rad]'};
        for i = 1:size(kepler,2)-2
            subplot(3,2,i)
            plot(kepler(:,1),kepler(:,i+1))
            xlabel('Time [day]')
            ylabel(labels{i})
            xlim([kepler(1,1),kepler(end,1)])
            grid on
            set(gca,'FontSize',13)
        end
        subplotTitle('Keplerian Elements')
        saveas(gca,['figures/',file(1:end-4)],'epsc')

        %...Plot histogram of observation frequency
        figure;
        histogram(diff(kepler(:,1)))
        xlabel('\Delta t [day]')
        ylabel('Occurrences [-]')
        grid on
        set(gca,'FontSize',13)
        
    case 'residuals'
        %...Extract options
        k = options.offset;
        
        %...Extract inputs
        keplerTLE = inputs{1};
        keplerProp = inputs{2};
        residuals = inputs{3};

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
            xlim([keplerTLE(1,1),keplerTLE(end,1)])
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
end