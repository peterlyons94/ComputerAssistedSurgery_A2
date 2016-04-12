% Transformer - Peter Lyons - 2016
% Takes in a set of Fiducial Points and returns a Homogeneous Transform
% Matrix

function [HTM] = ROBOTS(Fp)
    % shift points up a/2 and down -a/2, gives us a cage
    a = 100;
    Fp_up = Fp;
    Fp_up(3,:) = a/2;
    Fp_down = Fp;
    Fp_down(3, :) = -a/2;
    Fp(3, :) = 0;
    
    % Set of equations for fiducial rods as defined for the origin - still
    % need to shift to the CT FOV
    Fp3(1,:) = [-a, -a/2, 0];
    Fp3(2,:) = [-a, 0, 0];
    Fp3(3,:) = [-a, a/2, 0];
    Fp3(4,:) = [-a/2, 1.5 * a, 0];
    Fp3(5,:) = [0, 1.5 * a, 0];
    Fp3(6,:) = [a/2, 1.5 * a, 0];
    Fp3(7,:) = [a, a/2, 0];
    Fp3(8,:) = [a, 0, 0];
    Fp3(9,:) = [a, -a/2, 0];
    
    Fp3 = Fp3.'; % set to columnwise
    
    % get normal vectors for points 2, 5, 8
    d1 = norm(Fp(:,3) - Fp(:,2));
    d2 = norm(Fp(:,6) - Fp(:,5));
    d3 = norm(Fp(:,7) - Fp(:,8));
   
    % adjust points 2, 5, 8
    Fp3(2,2) = Fp3(2,3) - d1;
    Fp3(1,5) = Fp3(1,6) - d2;
    Fp3(2,8) = Fp3(2,7) - d3;
    
    % create new fiducial cage
    Fp3_up = Fp3;
    Fp3_up(3, :) = a/2;
    Fp3_down = Fp3;
    Fp3_down(3, :) = -a/2;

    % define vectors for intersection
    Start1 = [Fp3_up(:,2), Fp3_up(:,3)].';
    End1 = [Fp3_down(:,2), Fp3_down(:,1)].';
    
    Start2 = [Fp3_up(:,5), Fp3_up(:,6)].';
    End2 = [Fp3_down(:,5), Fp3_down(:,4)].';
    
    Start3 = [Fp3_up(:,8), Fp3_up(:,9)].';
    End3 = [Fp3_down(:,8), Fp3_down(:,7)].';
    
    % find intersetction points
    P1 = lineIntersect3D(Start1, End1).';
    P2 = lineIntersect3D(Start2, End2).';
    P3 = lineIntersect3D(Start3, End3).';
    
    % construct planes
    plane1 = [P1, P2, P3];
    plane2 = [Fp(:,2), Fp(:,5), Fp(:,8)];   
   
    %{
    %scatter3(plane2(:,1), plane2(:,2), plane2(:,3), 'filled', 'blue');
    %points=[[P1(1), P2(1), P3(1)];[P1(2), P2(2), P3(2)];[P1(3), P2(3), P3(3)]];
    %fill3(points(1,:),points(2,:),points(3,:),'r');
   
    %line([Fp_up(1, 3), Fp_down(1,1)], [Fp_up(2, 3), Fp_down(2,1)], [Fp_up(3, 3), Fp_down(3,1)]);
    %line([Fp_up(1, 2), Fp_down(1,2)], [Fp_up(2, 2), Fp_down(2,2)], [Fp_up(3, 2), Fp_down(3,2)]);
   
    line([Fp3_up(1, 9), Fp3_down(1,7)], [Fp3_up(2, 9), Fp3_down(2,7)], [Fp3_up(3, 9), Fp3_down(3,7)], 'LineWidth', 1.5);
    line([Fp3_up(1, 3), Fp3_down(1,1)], [Fp3_up(2, 3), Fp3_down(2,1)], [Fp3_up(3, 3), Fp3_down(3,1)], 'LineWidth', 1.5);
    line([Fp3_up(1, 6), Fp3_down(1,4)], [Fp3_up(2, 6), Fp3_down(2,4)], [Fp3_up(3, 6), Fp3_down(3,4)], 'LineWidth', 1.5);
    line([Fp3_up(1, 6), Fp3_down(1,6)], [Fp3_up(2, 6), Fp3_down(2,6)], [Fp3_up(3, 6), Fp3_down(3,6)], 'LineWidth', 2);
    line([Fp3_up(1, 4), Fp3_down(1,4)], [Fp3_up(2, 4), Fp3_down(2,4)], [Fp3_up(3, 4), Fp3_down(3,4)], 'LineWidth', 2);
    line([Fp3_up(1, 9), Fp3_down(1,9)], [Fp3_up(2, 9), Fp3_down(2,9)], [Fp3_up(3, 9), Fp3_down(3,9)], 'LineWidth', 2);
    line([Fp3_up(1, 7), Fp3_down(1,7)], [Fp3_up(2, 7), Fp3_down(2,7)], [Fp3_up(3, 7), Fp3_down(3,7)], 'LineWidth', 2);
    line([Fp3_up(1, 3), Fp3_down(1,3)], [Fp3_up(2, 3), Fp3_down(2,3)], [Fp3_up(3, 3), Fp3_down(3,3)], 'LineWidth', 2);
    line([Fp3_up(1, 1), Fp3_down(1,1)], [Fp3_up(2, 1), Fp3_down(2,1)], [Fp3_up(3, 1), Fp3_down(3,1)], 'LineWidth', 2);
    %}
    
    % Using absolute orientation, Horn's Method, compute the homogeneous
    % transform matrix between the two planes, where plane one consists of
    % the the intersection points, and plane two is the 3 ct coordinates
    % for the z-motif fiducials where z = 0
    OMG = absor(plane1, plane2);
    
    % return the homogeneous transform matrix
    HTM = OMG.M;
end