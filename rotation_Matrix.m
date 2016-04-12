function [M] = rotation_Matrix(x,y,z)
    M = [cosd(y)*cosd(z), -cosd(y)*sind(z), sind(y);...
         sind(x)*sind(y)*cosd(z)+cosd(x)*sind(z), -sind(x)*sind(y)*sind(z)+cosd(x)*cosd(z), -sind(x)*cosd(y);...
         -cosd(x)*sind(y)*cosd(z)+sind(x)*sind(z), cosd(x)*sind(y)*sind(z)+sind(x)*cosd(z),  cosd(x)*cosd(y)...
        ];
end