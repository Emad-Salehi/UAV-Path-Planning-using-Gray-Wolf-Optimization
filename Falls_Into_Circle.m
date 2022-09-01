% finding whether the kth line falls into any threats' circles or not (with bool).
% intersection of line segment and circle must be concluded in 2D since
% threats are cylinders in 3D !

% L_k = [x1 y1 z1; x2 y2 z2]   //   threat = [x y z R]

function bool = Falls_Into_Circle(L_k, threat)
    bool = false;
    slope = (L_k(2,2)-L_k(1,2))/(L_k(2,1)-L_k(1,1));
    intercpt = L_k(1,2) - slope*L_k(1,1);
    centerx = threat(1); centery = threat(2); radius = threat(4);
    [xout, yout] = linecirc(slope, intercpt, centerx, centery, radius);
    
    if (((xout(1) < L_k(2,1)) && (xout(1) > L_k(1,1))) || ((xout(2) < L_k(2,1)) && (xout(2) > L_k(1,1))))
        bool = true;
    end    
    
end