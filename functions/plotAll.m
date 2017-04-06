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
% Output:
%   - N/A

function plotAll(selection,inputs,options)

switch selection
    case 'elements'
        %...Extract inputs
        kepler = inputs{1};
        
        %...File names
        for i = 1:size(options,2)
            file = options(i).file;
            file = regexprep(file,'[files/.txt]','');
            files{i} = file;
        end

        %...Plot Keplerian elements
        figure;
        labels = {'a [m]','e [-]','i [rad]','\Omega [rad]','\omega [rad]','\vartheta [rad]'};
        for i = 1:6
            subplot(3,2,i)
            hold on
            for j = 1:size(kepler,2)
                plot(kepler{j}(:,1),kepler{j}(:,i+1))
            end
            hold off
            xlabel('Time [day]')
            ylabel(labels{i})
            legend(files)
            grid on
            set(gca,'FontSize',13)
        end
        subplotTitle('Keplerian Elements')

        %...Plot histogram of observation frequency
        for i = 1:size(kepler,2)
            figure;
            histogram(diff(kepler{i}(:,1)))
            xlabel('\Delta t [day]')
            ylabel('Occurrences [-]')
            grid on
            set(gca,'FontSize',13)
            title(files{i})
        end
        
    case 'residuals'        
        %...Extract inputs
        keplerTLE = inputs{1};
        keplerProp = inputs{2};
        residuals = inputs{3};
        
        %...File name
        file = options.file;
        file = regexprep(file,'[files/.txt]','');

        %...Plot TLE vs. propagation
        figure;
        labels = {'a [m]','e [-]','i [rad]','\Omega [rad]','\omega [rad]','\vartheta [rad]'};
        for i = 1:6
            subplot(3,2,i)
            hold on
            plot(keplerTLE(2:end,1),keplerTLE(2:end,i+1))
            plot(keplerProp(:,1),keplerProp(:,i+1))
            hold off
            xlabel('Time [day]')
            ylabel(labels{i})
            xlim([keplerTLE(1,1),keplerTLE(end,1)])
            legend('Observed','Propagated')
            grid on
            set(gca,'FontSize',13)
        end
        subplotTitle(file)

        %...Plot residuals
        figure;
        labels = {'\Delta a [m]','\Delta e [-]','\Delta i [rad]','\Delta \Omega [rad]'};
        for i = 1:4
            subplot(2,2,i)
            plot(keplerProp(:,1),residuals(:,i))
            xlabel('Time [day]');
            ylabel(labels{i});
            grid on;
            set(gca,'FontSize',13);
        end
        subplotTitle(file)
        
    case 'thrust'
        %...Extract inputs
        keplerTLE = inputs{1};
        thrustPeriods = inputs{2};
        
        %...File name
        file = options.file;
        file = regexprep(file,'[files/.txt]','');
        
        %...Plot thrust periods
        figure;
        labels = {'a [m]','e [-]','i [deg]','\Omega [deg]','\omega [deg]','\vartheta [deg]'};
        for i = 1:size(keplerTLE,2)-2
            subplot(3,2,i)
            hold on
            plot(keplerTLE(:,1),keplerTLE(:,i+1))
            ax = gca;
            ylimit = ax.YLim;
            for j = 1:size(thrustPeriods,1)
                pos = [thrustPeriods(j,1),ylimit(1),diff(thrustPeriods(j,:)),ylimit(2)];
                rectangle('Position',pos,'FaceColor',[0.95,0.5,0.5,0.5])
            end
            hold off
            xlabel('Time [day]')
            ylabel(labels{i})
            xlim([keplerTLE(1,1),keplerTLE(end,1)])
            ylim(ylimit)
            grid on
            set(gca,'FontSize',13)
        end
        subplotTitle(file)
        
    otherwise
        error('Nonexsisting case selected.')
end