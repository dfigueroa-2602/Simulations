%%
%save('MAT_swarms','swarms')
%load('MAT_swarms.mat')
%

% REMEMBER THAT:
% The swarm is stored in swarms{i} for each iteration
% swarms{i} has dimensions: [n_particles × 2 × dim]
%   (:,1,:) = position
%   (:,2,:) = velocity
iterations = 1:iter;

w1_all = zeros(n_part, iter);
w1b    = zeros(1, iter);

% [ifs_ab,vcs_ab,ifp_ab,iy_ab,vcp_ab,d_vs_ab,d_vp_ab,r_e1_vcs_ab,r_e2_vcs_ab
% r_e1_ifp_ab,r_e2_ifp_ab]

idx = 3;

for i = iterations
    % extract all particle positions for the first weight
    w1_all(:, i) = swarms{i}(:, 1, idx);  
    % index of global best at this iteration
    [~, gbest] = min(swarm(:, 4, idx));  
    w1b(i) = swarms{i}(gbest, 1, idx);
end

idx = 8;

for i = iterations
    % extract all particle positions for the first weight
    w2_all(:, i) = swarms{i}(:, 1, idx);  
    % index of global best at this iteration
    [~, gbest] = min(swarm(:, 4, idx));  
    w2b(i) = swarms{i}(gbest, 1, idx);
end

% Distance to global best at each iteration (n_part x iter)
dist = abs(w1_all - w1b);
d_hi = prctile(dist(:), 95);
sim  = 1 - min(dist / max(d_hi, eps), 1);
x = repelem(iterations, n_part).';     % (n_part*iter) x 1
y = reshape(w1_all, [], 1);
c = reshape(sim,    [], 1);            % color = closeness (0..1)
s = 50 + 44 * c;

set(0, 'DefaultLineLineWidth', 0.8);
set(0, 'defaultAxesFontSize', 8);
set(groot,'defaulttextinterpreter', 'latex');

figure(2); clf
tiles = tiledlayout('horizontal');
tiles.TileSpacing = 'compact'; tiles.Padding = 'compact';
ax1 = nexttile;
scatter(x, y, s, c,'.');
hold on
plot(iterations,repmat(xmax,iter),'black');
plot(iterations,repmat(-xmax,iter),'black')
plot(iterations, w1b, 'r', 'LineWidth', 2)
% xlabel('Iteration [-]')
xlabel({'Iteration [-]';'(a)'})
ylabel('Sixth weight value')
grid on
ax1.GridLineStyle = ':';
ax1.GridColor = 'k';
ax1.GridAlpha = 0.5;

dist = abs(w2_all - w2b);
d_hi = prctile(dist(:), 95);
sim  = 1 - min(dist / max(d_hi, eps), 1);
y = reshape(w2_all, [], 1);
c = reshape(sim,    [], 1);
s = 50 + 44 * c;

ax2 = nexttile;

scatter(x, y, s, c,'.');
hold on
plot(iterations,repmat(xmax,iter),'black')
plot(iterations,repmat(-xmax,iter),'black')
plot(iterations, w2b, 'r', 'LineWidth', 2)
xlabel({'Iteration [-]';'(b)'})
ylabel('Eigth weight value')
grid on
ax2.GridLineStyle = ':';
ax2.GridColor = 'k';
ax2.GridAlpha = 0.5;
set(gcf, 'Units', 'inches', 'Position', [[1 1], 21/2, 2]);

exportgraphics(gcf,'C:\Users\Dave\Documents\git\Papers\Paper_HDT\Images\w6_w8_iterations.pdf','ContentType','vector')

figure(3); clf;
fig = axes();
plot(b_fitness,LineWidth=1.5);
xlabel('Iteration [-]');
ylabel('Fitness value [-]')
grid on;
fig.GridLineStyle = ':';
fig.GridColor = 'k';
fig.GridAlpha = 0.5;
set(gcf, 'Units', 'inches', 'Position', [[1 1], 21/6, 1.2]);
exportgraphics(gcf,'C:\Users\Dave\Documents\git\Papers\Paper_HDT\Images\Fitness_iterations.pdf','ContentType','vector')