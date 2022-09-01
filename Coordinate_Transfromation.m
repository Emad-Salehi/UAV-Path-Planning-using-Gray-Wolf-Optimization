%% Coordinates are presented as [x,y,z]

function X_star = Coordinate_Transfromation(X, Xs, theta)
    A = [cosd(theta) sind(theta) 0; -sind(theta) cosd(theta) 0; 0 0 1];
    
    X_star = transpose(A*transpose(X - Xs));
end