function [best, f_best] = real_valued_monte_carlo(func, n, lb, ub, evals)
    best = rand(n,1) .* (ub - lb) + lb;
    f_best = func(best);
    hist_f(1) = f_best;
    for i = 2:evals
        x = rand(n,1) .* (ub - lb) + lb;
        f_x = func(x);
        if (f_x <= f_best)
            best = x;
            f_best = f_x;
        end
        hist_f(i) = f_best;
        plot(hist_f)
        drawnow()
    end
end

