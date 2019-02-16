function [best, f_best] = real_valued_monte_carlo_ga(func, n, lb, ub, evals)
    p=1/n; 
    func  = @ackley;
    parent = rand(n,1) .* (ub - lb) + lb;
    f_parent = func(parent);
    hist_f(1) = f_parent;
    for i = 2:evals
        bits = (rand(n,1) .* (ub - lb) + lb)<p;
        offspring = mod(parent + bits, 2);
        f_offspring = func(offspring);
        
        if (f_offspring >= f_parent)
            parent = offspring;
            f_parent = f_offspring;
        end
        
        hist_f(i) = f_parent;
        plot(hist_f)
        drawnow()
    end
end