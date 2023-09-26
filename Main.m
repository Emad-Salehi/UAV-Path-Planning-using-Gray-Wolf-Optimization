% Clean and Professional MATLAB Code

% Clear workspace and command window
clc;
clear;

% Record execution time
start_time = tic();

%% Constants and Inputs

% Define threat positions as [x, y, z = height of cylinder, R] in rows.
threats = [
    200, 200, 1000, 100;
    380, 500, 800, 150;
    550, 150, 1000, 125;
    250, 750, 700, 150;
    750, 450, 1000, 100;
    800, 250, 800, 150;
    500, 700, 600, 150;
    800, 800, 1000, 100
];

% Define start and target positions
start = [0, 0, 0];
target = [1000, 1000, 1000];

% Calculate theta based on start and target points
theta = atand((target(2) - start(2)) / (target(1) - start(1)));

% Parameter to control size of bounds
delta_d = 0;

% Number of wolves
N = 20;

% Number of point generations for each wolf
d = 10;

% Constant for Cost_Function
mhio = 0.4;

% Maximum optimization iterations
t_max = 100;

%% Initialization

% Transform points and threats to the new coordinate system
start_transform = Coordinate_Transformation(start, start, theta);
target_transform = Coordinate_Transformation(target, start, theta);
threats_transformed = threats;

for i = 1:size(threats, 1)
    threats_transformed(i, 1:3) = Coordinate_Transformation(threats(i, 1:3), start, theta);
end

% Calculate bounds for initialization and produce N random initial points
[P_min, P_max] = UL_Bounds(threats_transformed, delta_d);
wolves_positions = Initialization(N, d, target_transform, start_transform, P_min, P_max);

% Calculate fitness for each wolf
fitness = Inf;
X_alpha = zeros(d, 3);
X_alpha_index = 0;

for i = 1:N
    fitness_wolf = Cost_Function(wolves_positions(:, :, i), threats_transformed, mhio, d);
    
    if fitness_wolf < fitness
        fitness = fitness_wolf;
        X_alpha = wolves_positions(:, :, i);
        X_alpha_index = i;
    end
end

% Generate matrix for Xi(t)
X_t = zeros(d, 3, N, t_max);

for i = 1:N
    for t = 1:t_max
        if t == 1
            X_t(:, :, i, 1) = wolves_positions(:, :, i);
        else
            X_t(:, 1, i, t) = wolves_positions(:, 1, i);
            X_t(d, :, i, t) = target_transform;
        end
    end
end

% Initialize an array to store costs for the final graph
all_total_costs_SGWO = zeros(1, t_max);

all_total_costs_SGWO(1) = fitness;

%% Optimization

X_star_i_new = zeros(d, 3);
X_j_new = zeros(d, 3);
X_star_i_new(:, :) = wolves_positions(:, :, 1);
X_j_new(:, :) = wolves_positions(:, :, 1);

t = 1;

while t < t_max - 1
    a = 2 - (2 * t) / t_max;
    A_star = (2 * rand - 1) * a;
    C_star = 2 * rand;
    
    for i = 1:N
        D_star = abs(C_star * X_t(2:d-1, 2:3, X_alpha_index, t) - X_t(2:d-1, 2:3, i, t));
        X_t(2:d-1, 2:3, i, t+1) = X_t(2:d-1, 2:3, X_alpha_index, t) - A_star * D_star;
        
        j = randi([1 N]);
        X_star_i_new(2:d-1, 2:3) = X_t(2:d-1, 2:3, i, t) + (2 * rand(1) - 1) * (X_t(2:d-1, 2:3, X_alpha_index, t) - X_t(2:d-1, 2:3, j, t));
        X_j_new(2:d-1, 2:3) = X_t(2:d-1, 2:3, j, t) + (2 * rand(1) - 1) * (X_t(2:d-1, 2:3, X_alpha_index, t) - X_t(2:d-1, 2:3, i, t));
        
        if (Cost_Function(X_star_i_new, threats_transformed, mhio, d) < Cost_Function(X_t(:, :, i, t+1), threats_transformed, mhio, d))
            X_t(2:d-1, 2:3, i, t+1) = X_star_i_new(2:d-1, 2:3);
        end
        
        if (Cost_Function(X_j_new, threats_transformed, mhio, d) < Cost_Function(X_t(:, :, j, t), threats_transformed, mhio, d))
            X_t(2:d-1, 2:3, j, t) = X_j_new(2:d-1, 2:3);
        end
    end
    
    fitness = Inf;
    
    for i = 1:N
        fitness_wolf = Cost_Function(X_t(:, :, i, t), threats_transformed, mhio, d);
        
        if fitness_wolf < fitness
            fitness = fitness_wolf;
            X_alpha_index = i;
        end
    end
    
    all_total_costs_SGWO(t+1) = fitness;
    
    t = t + 1;
end

% Calculate SGWO runtime in minutes
SGWO_run_time = toc(start_time) / 60;

%% Print Results

Print(X_t, start, target, threats, theta, t_max - 1, X_alpha_index, d);
