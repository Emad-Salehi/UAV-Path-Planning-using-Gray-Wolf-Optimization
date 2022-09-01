%clc
%clear all

% Take time of excution
s = tic();

%% Constants and Inputs

% Each threat are presented as [x,y,z=height of cylinder,R] in a row.
% Case 1
%threats = [300,150,1000,75; 250,600,800,100; 600,100,500,100; 500,750,1000,100; 850,550,500,75; 450,300,750,75; 750,350,1000,50; 700,800,1000,75];
% Case 2 
%threats = [250,50,600,150; 380,420,800,150; 550,100,1000,150; 250,750,1000,200; 700,500,1000,100; 850,250,600,200; 450,700,600,150; 750,800,800,150];
% Case 3
threats = [200,200,1000,100; 380,500,800,150; 550,150,1000,125; 250,750,700,150; 750,450,1000,100; 800,250,800,150; 500,700,600,150; 800,800,1000,100];

start = [0,0,0];
target = [1000,1000,1000];

% Calculating theta base on start and target points
theta = atand((target(2) - start(2))/(target(1) - start(1)));
% Parameter to control size of bounds
delta_d = 0;
% Number of wolfs
N = 50;
% Number of point generation for each wolf
d = 10;
% Constant for Cost_Function_Prototype
mhio = 0.4;
% Optimization itteration
t_max = 100;

%% Initialization

% Transofrm point and threats to the new coordination
start_transform = Coordinate_Transfromation(start, start, theta);
target_transform = Coordinate_Transfromation(target, start, theta);
threats_tranform = threats;
for i = 1:size(threats, 1)
    threats_tranform(i, 1:3) = Coordinate_Transfromation(threats(i, 1:3), start, theta);
end

% Calculating bounds for initialization and producing N random intial points
[P_min, P_max] = UL_Bounds(threats_tranform, delta_d);

wolfs_positions = Initialization(N, d, target_transform, start_transform, P_min, P_max);

% calculating fittness of each wolf
fitness = Inf;
for i=1:N
    % wolfs_positions(:, :, i) is a set of d points' coordinates for the ith wolf
    fitness_wolf = Cost_Function_Prototype(wolfs_positions(:, :, i),  threats_tranform, mhio, d);
    if fitness_wolf < fitness
        fitness = fitness_wolf;
        X_alpha = wolfs_positions(:, :, i);
        X_alpha_index = i;
    end
end

% Generating matrix for Xi(t). 
X_t = zeros(d, 3, N, t_max);

for i = 1:N
    for t = 1:t_max
        if t==1
            % We have Xi(1) for different all i. So we fill the X_t(:,:,i,1)
            % with the known positions.
            X_t(:,:,i,1) = wolfs_positions(:, :, i);
        else
            % Also since all the time for all wolfs, the x coordinate
            % should be the same, we fill it so !
            X_t(:,1,i,t) = wolfs_positions(:, 1, i);
            
            % Also the last row (d) for all X_t should be the target
            X_t(d,:,i,t) = target_transform;
        end
    end
end 

% Saving all costs for the final graph
all_total_costs_SGWO = zeros();
all_total_costs_SGWO(1) = fitness;

%%  Optimization 

X_star_i_new = zeros(d,3);
X_j_new = zeros(d,3);
X_star_i_new(:,:) = wolfs_positions(:, :, 1); 
X_j_new(:,:) = wolfs_positions(:, :, 1); 

t = 1;
while t < t_max - 1
    a = 2 - (2*t)/t_max;
    A_star = (2*rand - 1)*a;
    C_star = 2*rand;
    for i = 1:N
       % We should'nt update X(1,:,:,:) and X(d,:,:,:). Since they are start and target points ! 
       % Also we should just update y,z of points, since the x coordinate
       % is always constant for all points all time.
       D_star = abs(C_star*X_t(2:d-1,2:3,X_alpha_index,t) - X_t(2:d-1,2:3,i,t));
       X_t(2:d-1,2:3,i,t+1) = X_t(2:d-1,2:3,X_alpha_index,t) - A_star*D_star;
       
       % Random index generation for Xj 
       j = randi([1 N]);
       X_star_i_new(2:d-1,2:3) = X_t(2:d-1,2:3,i,t) + (2*rand(1)-1)*(X_t(2:d-1,2:3,X_alpha_index,t) - X_t(2:d-1,2:3,j,t));
       X_j_new(2:d-1,2:3) = X_t(2:d-1,2:3,j,t) + (2*rand(1)-1)*(X_t(2:d-1,2:3,X_alpha_index,t) - X_t(2:d-1,2:3,i,t));
       
       if (Cost_Function_Prototype(X_star_i_new,  threats_tranform, mhio, d) < Cost_Function_Prototype(X_t(:,:,i,t+1),  threats_tranform, mhio, d))
           X_t(2:d-1,2:3,i,t+1) = X_star_i_new(2:d-1,2:3);
       end
       
       if (Cost_Function_Prototype(X_j_new,  threats_tranform, mhio, d) < Cost_Function_Prototype(X_t(:,:,j,t),  threats_tranform, mhio, d))
           X_t(2:d-1,2:3,j,t) = X_j_new(2:d-1,2:3);
       end
    end
    
    % Determining the index of alpha wolf at the end of time t
    fitness = Inf;
    for i = 1:N
    % wolfs_positions(:, :, i) is a set of d points' coordinates for the ith wolf
    fitness_wolf = Cost_Function_Prototype(X_t(:, :, i, t),  threats_tranform, mhio, d);
        if fitness_wolf < fitness
            fitness = fitness_wolf;
            X_alpha_index = i;
        end
    end
    
    all_total_costs_SGWO(t+1) = fitness;
    
    t = t + 1;
end

SGWO_run_time = toc(s)/60

%% Printing the resuls

Print(X_t,  start, target, threats, theta, t_max -1, X_alpha_index, d)
