function [L_Bound, U_Bound] = UL_Bounds(threats_tranform, delta_d)
% calculating U_Bound (P_max) and L_Bound (P_min)
U_bound = -Inf;
L_bound = Inf;

for i = 1:size(threats_tranform, 1)
    y_star = threats_tranform(i,2);
    if y_star - threats_tranform(i,4) < L_bound
        L_bound = y_star - threats_tranform(i,4);
    end
    
    if y_star + threats_tranform(i,4) > U_bound
        U_bound = y_star + threats_tranform(i,4);
    end
end    

P_min = min(L_bound, 0) - delta_d;
P_max = max(U_bound, 0) + delta_d;

L_Bound = P_min;
U_Bound = P_max;

end
