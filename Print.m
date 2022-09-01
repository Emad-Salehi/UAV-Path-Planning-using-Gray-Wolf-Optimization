function Print(X_t,  start, target, threats, theta, t, alpha_ind, d)
    % Transform all points to the standard coordination to plot
    A_prime = inv([cosd(theta) sind(theta) 0; -sind(theta) cosd(theta) 0; 0 0 1]);
    transform_path = X_t(:,:,alpha_ind,t);
    standard_path = zeros(d,3);
    for i = 1:d
        % Coordinates of all d points in standard coordination
        standard_path(i, :) = A_prime*transpose(transform_path(i, :)) + transpose(start);
    end
    
    % By transposing, make it easier to extract x,y,z cordinates
    path_for_plot = transpose(standard_path(:,:));
    X = path_for_plot(1,2:d-1);
    Y = path_for_plot(2,2:d-1);
    Z = path_for_plot(3,2:d-1);
    figure()
    hold on
    
    % Plotting all waypoints beside start and target (since we want them to shown different)!
    plot3(X,Y,Z, '-o', 'Color', [0.4940 0.1840 0.5560], 'LineWidth', 2)
    xlabel('X')
    ylabel('Y')
    zlabel('Z')
    
    % Plot start and target points
    plot3(start(1), start(2), start(3), '-s', 'MarkerSize', 10, 'MarkerEdgeColor','red',...
    'MarkerFaceColor', [0.6350 0.0780 0.1840])
    plot3(target(1), target(2), target(3), '-s', 'MarkerSize', 10, 'MarkerEdgeColor','green',...
    'MarkerFaceColor', [0.4660 0.6740 0.1880])
    
    % Plot line between start and first waypoint
    X = [start(1) path_for_plot(1,2)];
    Y = [start(2) path_for_plot(2,2)];
    Z = [start(3) path_for_plot(3,2)];
    plot3(X,Y,Z, '-', 'Color', [0.4940 0.1840 0.5560], 'LineWidth', 2)
    % Plot line between target and last waypoint
    X = [target(1) path_for_plot(1,d-1)];
    Y = [target(2) path_for_plot(2,d-1)];
    Z = [target(3) path_for_plot(3,d-1)];
    plot3(X,Y,Z, '-', 'Color', [0.4940 0.1840 0.5560], 'LineWidth', 2)
    
    % Plot threat cylindrials
    for i = 1:size(threats,1)
        [X,Y,Z] = cylinder(threats(i,4));
        height = threats(i,3);
        % Body of cylinder
        surf(X + threats(i,1),Y + threats(i,2),Z*height, 'FaceColor', [0.4 0.2392 0.078], 'EdgeColor', 'none', 'FaceAlpha', 0.5)
        % Top of cylinder
        fill3(X + threats(i,1),Y + threats(i,2),threats(i,3)*ones(1,length(X)),[0.4 0.2392 0.078], 'EdgeColor', [0.4 0.2392 0.078], 'FaceAlpha', 0.3)
    end
    
    view(3)
    %grid on
    
end