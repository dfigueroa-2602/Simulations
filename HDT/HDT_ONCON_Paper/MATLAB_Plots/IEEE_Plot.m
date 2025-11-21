function [] = IEEE_Plot(data, options)

%% Basic and common configuration

% Color palette configuration
try colororder(options.colorPalette);
catch colororder('default');
end

% Line-width configuration
try set(0, 'DefaultLineLineWidth', options.lineWidth);
catch set(0, 'DefaultLineLineWidth', 0.8);
end

% Font size configuration
try set(0, 'defaultAxesFontSize', options.fontSize);
catch set(0, 'defaultAxesFontSize', 8);
end

% Interpreter configuration
try set(groot,'defaulttextinterpreter', options.interpreter);
catch set(groot,'defaulttextinterpreter', 'latex');
end

% Assign figure number
try fig = figure(options.figureNumber);
catch fig = figure();
end

% Assign file name
try options.fileName;
catch options.fileName = 'Fig';
end

% Assign the output file extensions
try options.fileExtensions;
catch options.fileExtensions = {'-depsc','-dpdf'};
end

% Main figure size configuration
try set(gcf, 'Units', 'inches', 'Position', [[1 1], options.figWidth, options.figHeight]);
catch
    try options.figWidth;
    catch options.figWidth = 21/6;
    end
    try options.figHeight
    catch options.figHeight = 5;
    end
    set(gcf, 'Units', 'inches', 'Position', [[1 1], options.figWidth, options.figHeight]);
end

% Subplot height configuration
try options.subHeight;
catch options.subHeight = 0.7;
end

% X separation between subplots configuration
try options.sepX;
catch options.sepX = 0;
end

% Y separation between subplots configuration
try options.sepY;
catch options.sepY = 0;
end

%% Grid configuration

% Turn on/off the grid
try options.gridOn
catch options.gridOn = 1;
end

% Configure the line style of the grid
try options.gridLineStyle
catch options.gridLineStyle = ':';
end

% Grid color configuration
try options.gridColor;
catch options.gridColor = 'k';
end

% Transparency configuration of the grid
try options.gridAlpha;
catch options.gridAlpha = 0.5;
end



%% Script 1
% - It just plot all the subplots in a predefined order and size.
% - In the next iteration, they will be ordered and resized.
% - In the end of the loop, the boxes sizes are calculated
clf
for i=1:size(data,1)
    for j=1:size(data,2)
        axis = axes();
        set(axis,'position',get(axis,'position').*[0 0 0 0] + [0.2*j 0.25*i 0.5 options.subHeight/options.figHeight])
        axis_vect{i,j} = axis;
        for k=1:size(data(i,j).xdata,1)
            try
                h = data(i,j).plotType{k}(axis, data(i,j).xdata{k,1},data(i,j).ydata{k,:}, data(i,j).options{k,1});
            catch
                h = data(i,j).plotType{k}(axis, data(i,j).xdata{k,1},data(i,j).ydata{k,:});
            end

            if isfield(data(i,j),'colorOrder')
                if k <= size(data(1,1).colorOrder,1) && ~isempty(data(i,j).colorOrder)
                    if ~isempty(data(i,j).colorOrder{k,1})
                        colororder(axis,data(i,j).colorOrder{k,1});
                    end
                end
            end
            hold on
        end

        %% x-axis configuration
        % xlim
        % xticks
        % xtickslabel
        % xticksangle
        % xlabel

        % xlim
        try xlim(data(i,j).xlabel.xlim);
        end

        % xticks
        try xticks(data(i,j).xlabel.xticks)
        end

        % xtickslabel
        try
            if data(i,j).xlabel.xticklabelsremove
                set(axis,'xticklabel',{[]})
            else
                xticklabels(data(i,j).xlabel.xticklabels);
            end
        catch
            try xticklabels(data(i,j).xlabel.xticklabels);
            end
        end

        % xticksangle
        try xtickangle(data(i,j).xlabel.xtickangle);
        catch xtickangle(0);
        end

        % xlabel
        try
            if data(i,j).xlabel.xlabelremove
            else xlabel(data(i,j).xlabel.string);
            end
        catch
            try xlabel(data(i,j).xlabel.string);
            end
        end

        %% y-axis configuration
        % ylim
        % yticks
        % ytickslabel
        % yticksangle
        % ylabel

        % ylim
        try ylim(data(i,j).ylabel.ylim);
        end

        % yticks
        try yticks(data(i,j).ylabel.yticks);
        end

        % ytickslabel
        try
            if data(i,j).ylabel.yticklabelsremove
                set(axis,'yticklabel',{[]})
            else
                yticklabels(data(i,j).ylabel.yticklabels);
            end
        catch
            try yticklabels(data(i,j).ylabel.yticklabels);
            end
        end

        % yticksangle
        try ytickangle(data(i,j).ylabel.ytickangle);
        catch ytickangle(0);
        end

        % yticklabelsremove
        try
            if data(i,j).ylabel.YTickLabelMode
                set(axis,'YTickLabelMode','manual')
            else
                yticklabels(data(i,j).ylabel.YTickLabelMode);
            end
        catch
            try yticklabels(data(i,j).ylabel.YTickLabelMode);
            end
        end

        % ylabel
        try
            if data(i,j).ylabel.ylabelremove
            else ylabel(data(i,j).ylabel.string);
            end
        catch
            try ylabel(data(i,j).ylabel.string);
            end
        end

        %% Grid configuration

        % grid
        if options.gridOn
            grid on
            axis.GridLineStyle = options.gridLineStyle;
            axis.GridColor = options.gridColor;
            axis.GridAlpha = options.gridAlpha;
        end

        %% Legend configuration

        % Apply legend for each plot
        try
            % check if legend is not empty
            if ~isempty(data(i,j).legend)
                legends = legend(data(i,j).legend, 'Interpreter','latex');
                % Add location to legend
                try set(legends,'Location',data(i,j).legendLocation)
                end
                try
                    % Configure number of columns and length of legend
                    set(legends,'NumColumns',data(i,j).legendConfig(1));
                    legends.ItemTokenSize = data(i,j).legendConfig(2:3);
                end
            end
        catch
        end

        %% Boxes calculation
        pos = tightPosition(axis);
        pos_vect{i,j} = pos;
        poslab = tightPosition(axis,IncludeLabels=true);
        poslab_vect{i,j} = poslab;
    end
end

%% Script 2
% - Calculates the width of each subplot
%       - Based on:
%           - first placements
%           - Label, ticks positions, etc
%       - It will be used later to replace the subplots

max_width_used = 0;
for j=1:size(data,2)
    for i=1:size(data,1)
        temp_label_space(i) = (poslab_vect{i,j}*[0 0 1 0]' - pos_vect{i,j}*[0 0 1 0]');
        temp_label_left(i) = poslab_vect{i,j}*[1 0 0 0]';
        temp_label_right(i) = poslab_vect{i,j}*[1 0 1 0]';
    end
    label_left = min(temp_label_left);
    label_right = max(temp_label_right);
    label_space(j) = label_right - label_left - pos_vect{i,j}*[0 0 1 0]';
    max_width_used = max_width_used + label_space(j);
end
width_available = 1 - max_width_used - options.sepX*(size(data,2)-1);
width_per_plot = width_available/size(data,2);

%% Script 3
%   - Calculates the offset of each column (x offset)
%       - Some columns need more offset because the yticks and ylabels use
%         more space

offset_per_column = 10*ones(1,size(data,2));
acc_width = 0;
for j=1:size(data,2)
    for i=1:size(data,1)
        if poslab_vect{i,j}*[1 0 0 0]' < offset_per_column(1,j)
            offset_per_column(1,j) = poslab_vect{i,j}*[1 0 0 0]';
        end
    end
    if j > 1
        acc_width = acc_width  + options.sepX + label_space(j-1) + 0*(poslab_vect{i,j-1}*[0 0 1 0]' - pos_vect{i,j-1}*[0 0 1 0]');
        offset_per_column(1,j) = offset_per_column(1,j) - acc_width - (j-1)*width_per_plot;
    else
        offset_per_column(1,j) = offset_per_column(1,j);
    end
end
% Calculate width axis
width_axe_per_column = width_per_plot;

%% Script 4
%   - Calculates the offset of each row (y offset)
%       - Some rows need more offset because the xticks and xlabels use
%       - Some rows don't have xlabels for example, therefore the offset
%         should be changed.

acc_height_offset = 0;
for i=1:size(data,1)
    offset_ymin_temp = 10;
    offset_ymax_temp = 0;
    for j=1:size(data,2)
        if poslab_vect{i,j}*[0 1 0 0]' < offset_ymin_temp
            offset_ymin_temp = poslab_vect{i,j}*[0 1 0 0]';
        end
        if poslab_vect{i,j}*[0 0 0 1]' > offset_ymax_temp
            offset_ymax_temp = poslab_vect{i,j}*[0 0 0 1]';
            max_actual_height = (pos_vect{i,j}*[0 1 0 1]' - poslab_vect{i,j}*[0 1 0 0]') + 0*poslab_vect{i,j}*[0 0 0 1]';
        end
    end
    if i>1
        offset_per_row(i,1) = -acc_height_offset + offset_ymin_temp;
    else
        offset_per_row(i,1) = offset_ymin_temp;
    end
    acc_height_offset = acc_height_offset + max_actual_height + options.sepY;
end

%% Script 5
%   - The axis are adjust based on the previous data
%       - The x and y offset are added, and the width is updated.

for i=1:size(data,1)
    for j=1:size(data,2)
        axis = axis_vect{i,j};
        set(axis,'position',get(axis,'position').*[1 1 0 1] + [-offset_per_column(1,j) -offset_per_row(i,1) width_axe_per_column 0]);

        pos = tightPosition(axis);
        if pos*[1 0 0 0]' < 0
            pos(1) = 0;
        end
        if pos*[0 1 0 0]' < 0
            pos(2) = 0;
        end
        pos_vect{i,j} = pos;
        poslab = tightPosition(axis,IncludeLabels=true);
        if poslab*[1 0 0 0]' < 0
            poslab(1) = 0;
        end
        if poslab*[0 1 0 0]' < 0
            poslab(2) = 0;
        end
        poslab_vect{i,j} = poslab;
    end
end

%% Script 6
%   - Print the figure

set(gcf,'renderer','Painters')

for k = 1:length(options.fileExtensions)
    if strcmp(options.fileExtensions{k},'-dpdf')
        exportgraphics(gcf,strcat(options.fileName,".pdf"),'ContentType','vector');
    else
        print(gcf, options.fileName, options.fileExtensions{k});
    end
end


end

