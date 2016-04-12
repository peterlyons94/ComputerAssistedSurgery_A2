% Analyzer - Peter Lyons - 2016 
% Generate 10 random ground truth transforms

function [] = Analyzer()
    
    % declare storage matricies
    the_matrix = zeros(4);
    pre_trans_matrix = zeros(4);
    rand_points = zeros(4, 30);
    rand_points2 = zeros(4,30);
    
    rand_points_before = zeros(3, 30);
    rand_points_after = zeros(3,30);
   
    % declare fiducial point storage
    FP_before = zeros(3, 9);
    FP_after = zeros(3, 9);
    
    % initial FLE error max
    FLE_max = 0;
    % generate random rotation matrix about z
    for i = 1:10 

        % increase FLE max from 0mm to 5mm
        if mod(i,2) == 0
           FLE_max = FLE_max + 1; 
        end
        
        % find the angle constraints
        x_max_rot = atand(50/150);
        x_rot = -x_max_rot + (x_max_rot * 2) * rand();
        
        % y angle constraint, depends on x
        y_max_rot = x_max_rot - abs(x_rot);
        y_rot = -y_max_rot + (y_max_rot * 2) * rand();
        
        % z is not dependant on x or y
        z_max_rot = 360;
        z_rot = -z_max_rot + (z_max_rot * 2) * rand();

        % generate random rotation matrix
        xyz_m = eye(4);
        xyz_r = rotation_Matrix(x_rot,y_rot,z_rot);
        xyz_m(1:3,1:3) = xyz_r;

        % Call Simulator function to get rotated vectors
        Fp = Simulator(xyz_m);
        Fp2 = Fp; % copy the Fiducial points for later use
        
        % Generate 30 random points within 5cm radius
        for j = 1:30
            [xr, yr] = circle();
            rand_points(1:2, j) = [xr*50,yr*50];
        end
        
        rand_points2 = rand_points; % copy for later use
        
        % prepare points for a transform matrix
        rand_points(3,:) = 0;
        rand_points(4,:) = 1;
        
        % find the maximum FOV translation in x and y direction
        x_max = 0;
        y_max = 0;
        x_min = 0;  
        y_min = 0;
        z_min = -100;
        z_max = 100;
      
        % Find the max random translations that can be applied
        for k = 1:length(Fp) 
            % max x
            if Fp(1,k) > x_max
              x_max = Fp(1,k);
            end
            % min x
            if Fp(1,k) < x_min
              x_min = Fp(1,k);
            end
            % max y
            if Fp(2,k) > y_max
              y_max = Fp(2,k);
            end
            % min y
            if Fp(2,k) < y_min
              y_min = Fp(2,k);
            end
            % max z
            if Fp(3,k) + 50 > 0
                if Fp(3,k) < z_max
                  z_max = Fp(3,k);
                end
            end
            % min z
            if Fp(3,k) - 50 < 0
                if Fp(3,k) > z_min
                  z_min = Fp(3,k);
                end
            end
        end

        % generates random integer between the max FOV window
        x_max = 250 - x_max;
        x_min = 0 - x_min;
        y_max = 250 - y_max;
        y_min = 0 - y_min;

        % calculate the translation value within the translation window
        trans_x = x_min + (abs(abs(x_max) - abs(x_min))) * rand();
        trans_y = y_min + (abs(abs(y_max) - abs(y_min))) * rand();

        % generate random z value within the plane
        trans_z = -abs(z_max) + (abs(abs(z_min) - abs(z_max))) * rand();

        % append to rotation matrix
        xyz_m(1,4) = trans_x;
        xyz_m(2,4) = trans_y;
        xyz_m(3,4) = trans_z;
        
        % add to large matrix
        pre_trans_matrix(:,:,i) = xyz_m;
        
        % call Simulator function and pass new transform matrix
        % contains shift to CT window, and xyz translations as well as FLE
        % error
        new_Fp = Simulator(xyz_m);
        
        % store fiducial points before error and translation
        FP_before(:,:,i) = new_Fp(1:3,:);
        
        % introduce FLE error, FLE Max increases every two iterations
        for l = 1:9
            x_error = -FLE_max + FLE_max * rand();
            y_error = -FLE_max + FLE_max * rand();
            new_Fp(1,l) = new_Fp(1,l) + x_error;
            new_Fp(2,l) = new_Fp(2,l) + y_error;
        end
        
        % get random points in correct frame
        rand_points(4,:) = 1; % padding
        for k = 1:30
           rand_points(:,k) = xyz_m * rand_points(:,k);
        end
        rand_points_before(:,:,i) = rand_points(1:3,:);
        
        % get the HTM from the points
        [HTM_out] = ROBOTS(new_Fp(1:2,:));
        
        % store HTM
        the_matrix(:,:,i) = HTM_out;
        
        % get transformed fiducial points
        new_Fp = Simulator(HTM_out);
        
        % store the transformed fiducial points in another matrix
        FP_after(:,:,i) = new_Fp(1:3,:);
        
        % apply the HTM generated from the Fiducial Points to the random points

        rand_points2(4,:) = 1;
        for k = 1:30
           rand_points2(:,k) = HTM_out * rand_points2(:,k);
        end
        % store in random point matrix
        rand_points_after(:,:,i) = rand_points2(1:3,:);   
    end
    
    % compute errors
    before = zeros(3, 39);
    after = zeros(3, 39);
    FLE = 0;
    
    FRE_avg = zeros(1,10);
    
    for p = 1:10    
        % increase FLE max from 0mm to 5mm
        if mod(p,2) == 0
           FLE = FLE + 1; 
        end
        
        % pass the 39 points into the FLE and TRE error functions
        before(:,1:9) = FP_before(:,:,p);
        before(:,10:39) = rand_points_before(:,:,p);
        
        after(:,1:9) = FP_after(:,:,p);
        after(:,10:39) = rand_points_after(:,:,p);
        
        % htm before/after
        htm_before = FP_before(:,:,p);
        htm_after = FP_after(:,:,p);
        
        % Calculate Fiducial Registration error
        FRE_avg(:,p) = rmse(norm(before), norm(after));
        TRE_avg(:,p) = rmse(norm(htm_before), norm(htm_after));
    end
    % calculates standard deviation of FRE
    FRE_std = std(FRE_avg)
    TRE_std = std(TRE_avg)
    
    % plot and analyze FRE and TRE as a function of FLEmax (ie, from 0mm to
    % 5mm
    x_ax = [0 1 1 2 2 3 3 4 4 5];
    
    plot(x_ax, FRE_avg, 'g', 'LineWidth', 2);
    hold on;
    plot(x_ax, TRE_avg, 'b', 'LineWidth', 2);
    title('TRE and FRE vs. Increasing FLE Max');
    xlabel('FLE max (mm)');
    ylabel('FRE avg & TRE_avg (mm)');
end