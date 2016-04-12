% Generate fiducial marker points in CT coordinates
% Assumptions:
% FOV is 250mm  
% L of Fiducial rod, 100mm

function [Fo] = Simulator(M)
    % scaling factor for 100mm equivalent of fiducial rod
    a = 100; 

    % Set of equations for fiducial rods as defined for the origin - still
    % need to shift to the CT FOV
    Fp(1,:) = [-a, -a/2, 0];
    Fp(2,:) = [-a, 0, 0];
    Fp(3,:) = [-a, a/2, 0];
    Fp(4,:) = [-a/2, 1.5 * a, 0];
    Fp(5,:) = [0, 1.5 * a, 0];
    Fp(6,:) = [a/2, 1.5 * a, 0];
    Fp(7,:) = [a, a/2, 0];
    Fp(8,:) = [a, 0, 0];
    Fp(9,:) = [a, -a/2, 0];

    Fp = Fp.'; % set to column wise
    Fp(4, :) = 1; % pad a 1
    
    % create a second fiducial point vector and shift the two of them to
    % opposite ends of the z-direction
    Fp2 = Fp;
    Fp3 = Fp;
    Fp4 = Fp;
    Fp2(3,:) = -a/2 + Fp(3,:);
    Fp(3,:) = a/2 + Fp(3,:);
    
    % apply the transformation matrix to the points
    for i = 1:length(Fp)
        Fp(:,i) = M * Fp(:,i);
        Fp2(:,i) = M * Fp2(:,i);
        Fp3(:,i) = M * Fp3(:,i);
    end
     
    % find the intersection of the z-motif line and the plane, return the
    % new points to F3
    
    % define the plane, and a point along the plane
    n = [0 0 1];
    V0 = [25, 25, 0];
    
    % transform points 1,3,4,6,7,9
    for i = 1:9
        F1 = [Fp(1, i), Fp(2,i), Fp(3,i)];
        F2 = [Fp2(1,i), Fp2(2,i), Fp2(3,i)];
        o = plane_line_intersect(n, V0, F2, F1);
        Fp3(1:3 ,i) = o.';
    end
    
    % point 8
    F1 = [Fp(1,9), Fp(2,9), Fp(3,9)];
    F2 = [Fp2(1,7), Fp2(2,7), Fp2(3,7)];
    o = plane_line_intersect(n, V0, F2, F1);
    Fp3(1:3 ,8) = o.';
   
    % point 5 
    F5 = [Fp(1, 6), Fp(2,6), Fp(3,6)];
    F6 = [Fp2(1,4), Fp2(2,4), Fp2(3,4)];
    o = plane_line_intersect(n, V0, F6, F5);
    Fp3(1:3 ,5) = o.';
    
    % point 2
    F3 = [Fp(1, 3), Fp(2,3), Fp(3,3)];
    F4 = [Fp2(1,1), Fp2(2,1), Fp2(3,1)];
    o = plane_line_intersect(n, V0, F3, F4);
    Fp3(1:3, 2) = o.';
    
    %{
    % plot transformed fiducial points
    scatter3(Fp3(1,:), Fp3(2,:), Fp3(3,:), 'filled', 'black');
    hold on;
    
    
    % drawing lines for visualization purposes   
    % diagonals
    line([Fp(1, 9), Fp2(1,7)], [Fp(2, 9), Fp2(2,7)], [Fp(3, 9), Fp2(3,7)], 'LineWidth', 1.5);
    line([Fp(1, 3), Fp2(1,1)], [Fp(2, 3), Fp2(2,1)], [Fp(3, 3), Fp2(3,1)], 'LineWidth', 1.5);
    line([Fp(1, 6), Fp2(1,4)], [Fp(2, 6), Fp2(2,4)], [Fp(3, 6), Fp2(3,4)], 'LineWidth', 1.5);
    
    % straight lines
    line([Fp(1, 6), Fp2(1,6)], [Fp(2, 6), Fp2(2,6)], [Fp(3, 6), Fp2(3,6)], 'LineWidth', 2);
    line([Fp(1, 4), Fp2(1,4)], [Fp(2, 4), Fp2(2,4)], [Fp(3, 4), Fp2(3,4)], 'LineWidth', 2);
    line([Fp(1, 9), Fp2(1,9)], [Fp(2, 9), Fp2(2,9)], [Fp(3, 9), Fp2(3,9)], 'LineWidth', 2);
    line([Fp(1, 7), Fp2(1,7)], [Fp(2, 7), Fp2(2,7)], [Fp(3, 7), Fp2(3,7)], 'LineWidth', 2);
    line([Fp(1, 3), Fp2(1,3)], [Fp(2, 3), Fp2(2,3)], [Fp(3, 3), Fp2(3,3)], 'LineWidth', 2);
    line([Fp(1, 1), Fp2(1,1)], [Fp(2, 1), Fp2(2,1)], [Fp(3, 1), Fp2(3,1)], 'LineWidth', 2);
    
    title('Transformed Fiducial Cage Coordinates');
    xlabel('x (mm)');
    ylabel('y (mm)');
    zlabel('z (mm)');
    view(3);
    %points=[[0,250,250,0];[0,0,250,250];[0,0,0,0]];
    %fill3(points(1,:),points(2,:),points(3,:),'g');
    alpha(.3);
    %}
    
    % output - fiducial points in CT x,y coordinates 
    Fo = Fp3; 
end