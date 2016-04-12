% Circle - Peter Lyons - 2016 
% function to generate integer within a specific radius

function [x, y] = circle()
    t = 2*pi*rand();
    u = rand() + rand();
    if u>1
        r = 2-u; 
    else
        r = u;
    end
    
    % returns x,y coordinates of a circle
    x = r*cos(t);
    y = r*sin(t);
end