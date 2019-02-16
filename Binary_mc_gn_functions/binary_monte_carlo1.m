function [best, f_best] = binary_monte_carlo1(func, n, evals)
best = rand(100,1) > 0.5;
f_best = func(best);
hist_f(1) = f_best;

for(i = 1: 1000)
    a = rand(100,1) > 0.5;
    f_a = func(a);
    
    if(f_a >= f_best)
        best = a;
        f_best = f_a;
    end
    
    hist_f(i) = f_best;
    plot(hist_f)
    drawnow()
    end
end