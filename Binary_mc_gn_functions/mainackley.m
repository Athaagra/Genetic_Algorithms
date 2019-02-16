ackley1 = @ackley; 
f = ackley1(20, 0.2, 2*pi);
c = @plot_2d_function;
c(f, -5 * ones(2,1), 5 * ones(2,1))