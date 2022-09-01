% X is d*3 matrix representing d points coordinates for a wolf

function cost = Cost_Function(X,  threats, mhio, d)
    J_fuel = 0;
    for i = 1:d-1
        J_fuel = J_fuel + pdist2(X(i, :), X(i+1, :));
    end
    
    J_threats = 0;
    for i = 1:d-1
        inner_sum = 0;
 
        % L_k which is the kth line composed of 2 points (ith and (i+1)th
        % point). if the L_k line or part of it falls into any circles, 
        % then we calculate W_threats for it.
        
        % We must examine intersection of jth threat circle and kth line in
        % 2D, since the threats are cylindrial
        L_k = [X(i, 1:2); X(i+1, 1:2)];       
        for j = 1:size(threats, 1)
            if Falls_Into_Circle(L_k, threats(j, :))
                threat_center = threats(j, 1:2);
                x0 = X(i, 1:2); x1 = X(i+1, 1:2); x05 = (x0 + x1)/2;
                x025 = (x0 + x05)/2; x075 = (x05 + x1)/2;
                d0 = pdist2(x0, threat_center); d025 = pdist2(x025, threat_center);
                d05 = pdist2(x05, threat_center); d075 = pdist2(x075, threat_center);
                d1 = pdist2(x1, threat_center);
                
                threat_radius = threats(j, 4);
                
                inner_sum = inner_sum + (threat_radius/10)*(1/d0 + 1/d025 + 1/d05 + 1/d075 + 1/d1);
            end
        end
        
        lk = pdist2(X(i, :), X(i+1, :));
        J_threats = J_threats + inner_sum*(lk/5);
    end
 
    cost = mhio*J_fuel + (1-mhio)*J_threats;
end