function [best, f_best] = binary_monte_carlo(func, n, evals)
    best = rand(n,1) > 0.5; % generate random solution
    f_best = func(best); % evaluate random solution
    hist_f(1) = f_best; % history administration
    for (i=1:evals) % loop
        a = rand(n,1) > 0.5; % generate random solution
        f_a = func(a); % evaluate random solution
    if (f_a >= f_best) % if a better than current best
        best = a; % update best
        f_best = f_a; % update f_best
    end
    hist_f(i) = f_best; % history administration
    plot(hist_f) % plot history
    drawnow() % make sure that the plot is drawn instantly
    end
end