clear options plotdata
% clc
% 
% close all

% Load Files

vec_1 = load("vec_1.mat");

time = vec_1.data(1,:);
ifsabc = vec_1.data(2:4,:);
vcsabc = vec_1.data(5:7,:);
ifpabc = vec_1.data(8:10,:);
iyabc = vec_1.data(11:13,:);
vcpabc = vec_1.data(14:16,:);
vgabc = vec_1.data(17:19,:);
iLabc = vec_1.data(20:22,:);

% time = time;
xlim = [0.005 0.24];
xticks = 0:0.02:0.24;
xtickslabel = xticks*1000;

% ifsabc
y_ifsabc = 8;
yticks_ifcabc = y_ifsabc*[-1 -0.5 0 0.5 1];
y_ifsabc = y_ifsabc*1.2*[-1 1];

% ifpabc
y_ifpabc = 10;
yticks_ifpabc = y_ifpabc*[-1 -0.5 0 0.5 1];
y_ifpabc = y_ifpabc*1.2*[-1 1];

% iyabc
y_iyabc = 30;
yticks_iyabc = y_iyabc*[-1 -0.5 0 0.5 1];
y_iyabc = y_iyabc*1.2*[-1 1];

% iLabc
y_iLabc = 30;
yticks_iLabc = y_iLabc*[-1 -0.5 0 0.5 1];
y_iLabc = y_iLabc*1.2*[-1 1];

% Vcsabc
y_vcsabc = 150;
yticks_vcsabc = y_vcsabc*[-1 -0.5 0 0.5 1];
y_vcsabc = y_vcsabc*1.2*[-1 1];

% Vcpabc
y_vcpabc = 300;
yticks_vcpabc = y_vcpabc*[-1 -0.5 0 0.5 1];
y_vcpabc = y_vcpabc*1.2*[-1 1];

% Vg
y_vg = 10e3;
yticks_vg = y_vg*[-1 -0.5 0 0.5 1];
y_vg = y_vg*1.2*[-1 1];


%%%%%%%%%%%%%%%%%%%%
%%%%%% Common %%%%%%
%%%%%%%%%%%%%%%%%%%%
options.fontSize = 8;
options.interpreter = 'latex';

options.sepX = 0.01;
options.sepY = 0;

options.figureNumber = 1;

options.figWidth = 43/6;
options.figHeight = 4.6;
options.subHeight = 0.5;
options.lineWidth = 1;
options.fileName = 'C:\Users\Dave\Documents\git\Papers\Paper_HDT\Images\Simulation_Results';
options.fileExtensions = {'-dpdf'};

options.gridOn = 1;
options.gridLineStyle = ':';
options.gridColor = 'k';
options.gridAlpha = 0.5;

options.colorPalette = ['#002060'; '#00b050'; '#ff0000'; '#ffc000'];


%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% Plot 1
%%%%%%%%%%%%%%%%%%%%
i = 1;
j = 1;
plotdata(i,j).width = 1;

plotdata(i,j).plotType = {@plot};%; @plot; @plot};
plotdata(i,j).xdata = {time};%; time; [1 2]*20e-3};
plotdata(i,j).ydata = {iLabc};% plot1_c; [0.5 1]};

% plotdata(i,j).options{4,1}.LineStyle = 'none';
% plotdata(i,j).options{4,1}.Marker = '*';
% plotdata(i,j).options{4,1}.Color = 'g';
% plotdata(i,j).options{4,1}.lineWidth = 10;

plotdata(i,j).xlabel.xlim = xlim;
plotdata(i,j).xlabel.xticklabelsremove = 0;
plotdata(i,j).xlabel.xticks = xticks;

plotdata(i,j).ylabel.ylim = y_iLabc;
plotdata(i,j).ylabel.yticks = yticks_iLabc;

plotdata(i,j).xlabel.xticklabels = xtickslabel;
plotdata(i,j).xlabel.string = {'Time [ms]';'\textbf{(f)}'};
plotdata(i,j).ylabel.string = {'Current';'$i_{L,abc}$ [A]'};


%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% Plot 2
%%%%%%%%%%%%%%%%%%%%
i = 2;
j = 1;
plotdata(i,j).width = 1;

plotdata(i,j).plotType = {@plot};%; @plot; @plot};
plotdata(i,j).xdata = {time};%; time; [1 2]*20e-3};
plotdata(i,j).ydata = {ifpabc};% plot1_c; [0.5 1]};

% plotdata(i,j).options{4,1}.LineStyle = 'none';
% plotdata(i,j).options{4,1}.Marker = '*';
% plotdata(i,j).options{4,1}.Color = 'g';
% plotdata(i,j).options{4,1}.lineWidth = 10;

plotdata(i,j).xlabel.xlim = xlim;
plotdata(i,j).xlabel.xticklabelsremove = 1;
plotdata(i,j).xlabel.xticks = xticks;

plotdata(i,j).ylabel.ylim = y_ifpabc;
plotdata(i,j).ylabel.yticks = yticks_ifpabc;

plotdata(i,j).xlabel.string = {'\textbf{(e)}'};
plotdata(i,j).ylabel.string = {'Current';'$i_{fp,abc}$ [A]'};


%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% Plot 3
%%%%%%%%%%%%%%%%%%%%
i = 3;
j = 1;
plotdata(i,j).width = 1;

plotdata(i,j).plotType = {@plot};%; @plot; @plot};
plotdata(i,j).xdata = {time};%; time; [1 2]*20e-3};
plotdata(i,j).ydata = {iyabc};% plot1_c; [0.5 1]};

% plotdata(i,j).options{4,1}.LineStyle = 'none';
% plotdata(i,j).options{4,1}.Marker = '*';
% plotdata(i,j).options{4,1}.Color = 'g';
% plotdata(i,j).options{4,1}.lineWidth = 10;


plotdata(i,j).xlabel.xlim = xlim;
plotdata(i,j).xlabel.xticklabelsremove = 1;
plotdata(i,j).xlabel.xticks = xticks;

plotdata(i,j).ylabel.ylim = y_iyabc;
plotdata(i,j).ylabel.yticks = yticks_iyabc;

plotdata(i,j).xlabel.string = {'\textbf{(d)}'};
plotdata(i,j).ylabel.string = {'Current';'$i_{Y,abc}$ [A]'};

%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% Plot 4
%%%%%%%%%%%%%%%%%%%%
i = 4;
j = 1;
plotdata(i,j).width = 1;

plotdata(i,j).plotType = {@plot};%; @plot; @plot};
plotdata(i,j).xdata = {time};%; time; [1 2]*20e-3};
plotdata(i,j).ydata = {vcpabc};% plot1_c; [0.5 1]};

% plotdata(i,j).options{4,1}.LineStyle = 'none';
% plotdata(i,j).options{4,1}.Marker = '*';
% plotdata(i,j).options{4,1}.Color = 'g';
% plotdata(i,j).options{4,1}.lineWidth = 10;


plotdata(i,j).xlabel.xlim = xlim;
plotdata(i,j).xlabel.xticklabelsremove = 1;
plotdata(i,j).xlabel.xticks = xticks;

plotdata(i,j).ylabel.ylim = y_vcpabc;
plotdata(i,j).ylabel.yticks = yticks_vcpabc;

plotdata(i,j).xlabel.string = {'\textbf{(c)}'};
plotdata(i,j).ylabel.string = {'Voltage';'$v_{cp,abc}$ [V]'};


%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% Plot 5
%%%%%%%%%%%%%%%%%%%%
i = 5;
j = 1;
plotdata(i,j).width = 1;

plotdata(i,j).plotType = {@plot};%; @plot; @plot};
plotdata(i,j).xdata = {time};%; time; [1 2]*20e-3};
plotdata(i,j).ydata = {vcsabc};% plot1_c; [0.5 1]};


plotdata(i,j).xlabel.xlim = xlim;
plotdata(i,j).xlabel.xticklabelsremove = 1;
plotdata(i,j).xlabel.xticks = xticks;

plotdata(i,j).ylabel.ylim = y_vcsabc;
plotdata(i,j).ylabel.yticks = yticks_vcsabc;

plotdata(i,j).xlabel.string = {'\textbf{(b)}'};
plotdata(i,j).ylabel.string = {'Voltage';'$v_{cs,abc}$ [V]'};

%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% Plot 6
%%%%%%%%%%%%%%%%%%%%
i = 6;
j = 1;
plotdata(i,j).width = 1;

plotdata(i,j).plotType = {@plot};%
plotdata(i,j).xdata = {time};%; time; [1 2]*20e-3};
plotdata(i,j).ydata = {vgabc};% plot1_c; [0.5 1]};


plotdata(i,j).xlabel.xlim = xlim;
plotdata(i,j).xlabel.xticklabelsremove = 1;
plotdata(i,j).xlabel.xticks = xticks;

plotdata(i,j).ylabel.ylim = y_vg;
plotdata(i,j).ylabel.yticks = yticks_vg;
plotdata(i,j).ylabel.YTickLabelMode = yticks_vg/1000;

plotdata(i,j).xlabel.string = {'\textbf{(a)}'};
plotdata(i,j).ylabel.string = {'Voltage';'$v_g$ [kV]'};


% Function call
clf
IEEE_Plot(plotdata,options)

%%
% save as pdf
for k = 1:length(options.fileExtensions)
    if strcmp(options.fileExtensions{k},'-dpdf')
        exportgraphics(gcf,strcat(options.fileName,".pdf"));
    else
        print(gcf, options.fileName, options.fileExtensions{k});
    end
end

%% embed everything
% Build the Ghostscript command
gsPath = '/usr/local/bin/gs';
% gsCmd = sprintf('"%s" -o "%s" -dNoOutputFonts -sDEVICE=pdfwrite "%s"', gsPath, strcat(options.fileName,".pdf"),strcat(options.fileName,".pdf"));
gsCmd = sprintf('"%s" -o "%s" -dNoOutputFonts -sDEVICE=pdfwrite "%s"', gsPath, strcat(cd,'/_',options.fileName,".pdf"),strcat(cd,'/',options.fileName,".pdf"));
% gsCmd = sprintf('"%s" -o /Users/alvaro/Documents/Repositories/Paper_IECON2025/Latex/Figures/file-with-outlines.pdf -dNoOutputFonts -sDEVICE=pdfwrite /Users/alvaro/Documents/Repositories/Paper_IECON2025/Latex/Figures/test.pdf', gsPath);
% Run the command
status = system(gsCmd);
delete(strcat(options.fileName,".pdf"));
movefile(strcat('_',options.fileName,".pdf"), strcat(options.fileName,".pdf"));