function plot_2d_function(func,x,y)
    [X, Y] = meshgrid(x, y);
    
    nx = length(x);
    ny = length(y);
    Z = zeros(nx, ny);
    f = str2func(func);
    for i = 1:nx
        for j = 1:ny
            Z(i, j) = f([X(i, j), Y(i, j)]);
        end
    end
    surfc(X, Y, Z);
end








