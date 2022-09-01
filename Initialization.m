function positions = Initialization(N, d, target, start, P_min, P_max)
    dist_st = target(1)-start(1);
    delta_x = dist_st/d;
    
    % each row of positions (:,:,i) represent a wolf's set of points. since
    % we have d points and each point is a 3D then we have a d*3 matrix for
    % each wolf.
    positions = zeros(d, 3, N);
    
    % for each wolf, we fill the first and the last (1 and d) points with the start and 
    % target points. 
    for i = 1:N
        positions(1, :, i) = start;
        positions(d, :, i) = target;
    end
    
    for i = 2:d-1
        for j = 1:N 
            positions(i, :, j) = [delta_x*i (P_max-P_min)*rand + P_min (target(3)-start(3))*rand+start(3)];
        end
    end
end