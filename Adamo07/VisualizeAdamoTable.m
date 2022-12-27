classdef VisualizeAdamoTable < matlab.mixin.SetGet
    %{
    VisualizeAdamoTable - visualize 3-way RM-ANOVA from Adamo et al 2007
    %}
    
%% Properties
    %% Main 
    properties
        % displacement (10,30,60) X stat (mean,std) X paradigm (IR, CC, CR)
        YA = nan(3,2,3); 
        OA = nan(3,2,3); 
        tNum; 
    end
    %% Data
    properties 
        youngMU;
        youngSD;
        oldMU;
        oldSD;
    end
    %% Figure
    properties
        fig;
        ax; 
        outcome_str; 
        kBG = true;
    end
    %% Colors
    properties
        young_cc = [0.3718 0.7176 0.3612];
        old_cc   = [1 0.5482 1]; 
    end
    %% Boxcharts
    properties 
        bcProps = {'markerstyle', 'x', ...
                    'jitteroutliers', true}; 
        bcDataProps = {'marker', 'o', ...
                       'markersize', 6, ...
                       'linestyle', 'none'}; 
    end
    %% Statistics 
    properties 
        effectOfAge;
        btwAge; 
        effectOfCondition;
        btwConditions; 
        winConditions;
        effectOfDisplacement;
        btwDisplacements;
        winDisplacements; 

        btwDisplacementCondition;
        
    end
%% Methods 
    %% Main 
    methods
        function obj = VisualizeAdamoTable(YA, OA, outcome_str, tNum)
            %% Assign properties
            obj.YA = YA; 
            obj.OA = OA; 
            obj.outcome_str = outcome_str;
            obj.tNum = tNum; 
            obj = obj.parseData(); 
        end
        
        function obj = parseData(obj) 
            obj.youngMU = squeeze(obj.YA(:,1,:)); 
            obj.oldMU = squeeze(obj.OA(:,1,:)); 
            obj.youngSD = squeeze(obj.YA(:,2,:));
            obj.oldSD = squeeze(obj.OA(:,2,:)); 
        end
        
        function [fig,ax] = effectsOfAge(obj)
            fig = figure('visible', 'on');
            ax = gca(); 
            obj.boxchartWJitter(ax, 1, obj.youngMU(:), obj.young_cc);
            obj.boxchartWJitter(ax, 2, obj.oldMU(:), obj.old_cc);
            xticks([1 2]); xticklabels({'Younger Adults', 'Older Adults'});
            sigstar({[1 2]}, obj.btwAge); 
            ylabel(obj.outcome_str); 
            if obj.effectOfAge
                title('Effect of Age^*');
            else
                title('Effect of Age');
            end
            grid on;
            if obj.kBG
                darkBackground()
            end
            auto_save(sprintf('t%d_effectOfAge', obj.tNum))
        end
        
        function [fig,ax] = effectsOfConditions(obj)
            fig = figure('visible', 'on');
            ax = gca(); 
            %% Parse data 
            xBoxes = [0.8, 1.2; 1.8, 2.2; 2.8, 3.2];
            for i = 1:3
                bY = obj.boxchartWJitter(ax, xBoxes(i,1), obj.youngMU(:,i), obj.young_cc);
                set(bY, 'boxwidth', 0.3)
                bO = obj.boxchartWJitter(ax, xBoxes(i,2), obj.oldMU(:,i), obj.old_cc);
                set(bO, 'boxwidth', 0.3)
            end
            sigstar(...
                {[1 2], [2 3], [1 3], [xBoxes(1,:)], [xBoxes(2,:)], [xBoxes(3,:)]}, ...
                [obj.btwConditions obj.winConditions]);
            axis tight padded
            xticks(1:3); xticklabels({'IR', 'CC', 'CR'});
            y=plot(nan,nan,'color', obj.young_cc,'linewidth', 7);
            o=plot(nan,nan,'color', obj.old_cc,'linewidth', 7);
            if obj.effectOfCondition(1)
                lgnd{1} = 'Younger Adults^*';
            else
                lgnd{1} = 'Younger Adults';
            end
            if obj.effectOfCondition(2)
                lgnd{2} = 'Older Adults^*';
            else
                lgnd{2} = 'Older Adults';
            end
            legend([y o], lgnd, 'location', 'northwest');
            if obj.effectOfCondition(3)
                title('Effects of Condition^*');
            else
                title('Effects of Condition');
            end
            grid on;
            ylabel(obj.outcome_str)
            if obj.kBG
                darkBackground()
            end
            auto_save(sprintf('t%d_effectOfCondtion', obj.tNum))
        end
        
        function [fig,ax] = effectsOfDisplacement(obj)
            fig = figure('visible', 'on');
            ax = gca(); 
            %% Parse data 
            xBoxes = [0.8, 1.2; 1.8, 2.2; 2.8, 3.2];
            for i = 1:3
                bY = obj.boxchartWJitter(ax, xBoxes(i,1), obj.youngMU(i,:), obj.young_cc);
                set(bY, 'boxwidth', 0.3)
                bO = obj.boxchartWJitter(ax, xBoxes(i,2), obj.oldMU(i,:), obj.old_cc);
                set(bO, 'boxwidth', 0.3)
            end
            sigstar(...
                {[1 2], [2 3], [1 3], [xBoxes(1,:)], [xBoxes(2,:)], [xBoxes(3,:)]}, ...
                [obj.btwDisplacements obj.winDisplacements]);
            axis tight padded
            xticks(1:3); xticklabels({'10\circ', '30\circ', '60\circ'});
            y=plot(nan,nan,'color', obj.young_cc,'linewidth', 7);
            o=plot(nan,nan,'color', obj.old_cc,'linewidth', 7);
            if obj.effectOfDisplacement(1)
                lgnd{1} = 'Younger Adults^*';
            else
                lgnd{1} = 'Younger Adults';
            end
            if obj.effectOfDisplacement(2)
                lgnd{2} = 'Older Adults^*';
            else
                lgnd{2} = 'Older Adults';
            end
            legend([y o], lgnd, 'location', 'northwest');
            if obj.effectOfDisplacement(3)
                title('Effects of Displacement^*');
            else
                title('Effects of Displacement');
            end
            grid on;
            ylabel(obj.outcome_str)
            if obj.kBG
                darkBackground()
            end
            auto_save(sprintf('t%d_effectOfDisplacement', obj.tNum))
        end
        
        function [fig, ax] = basePlot(obj, xSig, Sigs)
            fig = figure('visible', 'on');
            ax = gca(); 
            
            % combine 
            combinedMU = reshape([obj.youngMU;obj.oldMU], size(obj.youngMU,1), []); 
            combinedSD = reshape([obj.youngSD;obj.oldSD], size(obj.youngSD,1), []); 
            b = bar(ax, combinedMU);
            hold on; box off; 
            % fix colors 
            for i = 1:length(b)
                if rem(i,2) == 0 % even 
                    set(b(i), 'facecolor', obj.old_cc); 
                else % odd 
                    set(b(i), 'facecolor', obj.young_cc); 
                end
            end
            % add labels
            xend = reshape([b.XEndPoints], 3, []);
            % error bars 
            errorbar(xend, combinedMU, combinedSD, 'k', 'linestyle','none');
            for i = 1:length(xSig)
                sigConnect{i} = [xend(xSig{i}(1,1),xSig{i}(1,2)), ...
                                 xend(xSig{i}(2,1),xSig{i}(2,2))];
            end
            sigstar(sigConnect, Sigs);
            preTicks = [mean(xend(:,1:2), 2), mean(xend(:,3:4), 2), mean(xend(:,5:6), 2)]'; 
            xticks(preTicks(:))
            xticklabels(...
                {'10\circ', '30\circ', '60\circ',...
                '10\circ', '30\circ', '60\circ', ...
                '10\circ', '30\circ', '60\circ'}); 
            xlabel('IR                            CC                            CR'); 
            y=plot(nan,nan,'color', obj.young_cc,'linewidth', 7);
            o=plot(nan,nan,'color', obj.old_cc,'linewidth', 7);
            legend([y o], {'Younger Adults', 'Older Adults'}, 'location', 'best');
            grid on;
            ylabel(obj.outcome_str)
            if obj.kBG
                darkBackground()
            end
            auto_save(sprintf('t%d_Full', obj.tNum))
        end
    end
    %% Boxcharts
    methods 
        function varargout = boxchartWJitter(obj, ax, x, y, cc)
            b = boxchart(ax, zeros(size(y))+x, y, obj.bcProps{:}, ...
                'boxfacecolor', cc, ...
                'markercolor', cc);
            hold on 
            jitter = normrnd(0,0.1,size(y))+x;
            jOutlier = isoutlier(y,'quartiles'); 
            p = plot(ax, jitter(~jOutlier), y(~jOutlier), 'color', cc, obj.bcDataProps{:}); 
            switch nargout 
                case 0
                    varargout={};
                case 1 
                    varargout{1}=b;
                case 2 
                    varargout{1}=b;
                    varargout{2}=p;
            end
        end
    end
    %% Set methods
    methods 
        function set.effectOfAge(obj,val)
            if ~islogical(val)
                error('Needs to be logical')
            end
            obj.effectOfAge=val;
        end
        function set.effectOfCondition(obj,val)
            if length(val) ~= 3 || ~islogical(val)
                error('Needs to be logical')
            end
            obj.effectOfCondition = val;
        end
        function set.effectOfDisplacement(obj,val)
            if length(val) ~= 3 || ~islogical(val)
                error('Needs to be logical')
            end
            obj.effectOfDisplacement = val;
        end
        function set.btwDisplacements(obj,val)
            if length(val) ~= 3
                error('Must be length 3 p-values')
            end
            obj.btwDisplacements = val;
        end
        function set.btwConditions(obj,val)
            if length(val) ~= 3
                error('Must be length 3 p-values')
            end
            obj.btwConditions = val;
        end
    end
end

