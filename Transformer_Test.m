% Transformer Test - Peter Lyons - 2016

%% //////////// Identity Matrix ///////////////
matrix = eye(4);
matrix(1:3, 1:3) = rotation_Matrix(0,0,0)

% pass matrix into Simulator function to generate points from rotation
% matrix
points = Simulator(matrix)

% pass X, Y coorinates into Transformer function
output = ROBOTS(points(1:2,:))


%% ///////////////// Simple 10 degree x,y,z rotation Matrix //////////////
matrix = eye(4);
matrix(1:3, 1:3) = rotation_Matrix(10,10,10)

% pass matrix into Simulator function to generate points from rotation
% matrix
points = Simulator(matrix)

% pass X, Y coorinates into Transformer function
output = ROBOTS(points(1:2,:))

%% /////////////// Simple Translation ///////////////////
matrix = eye(4);
matrix(1,4) = 10;
matrix(2,4) = 5;
matrix(3,4) = 15
% pass matrix into Simulator function to generate points from rotation
% matrix
points = Simulator(matrix)

% pass X, Y coorinates into Transformer function
output = ROBOTS(points(1:2,:))