function aopt = binary_monte_carlo_optimization(f, nVar, iter)
% function aopt = binary_monter_carlo_optimization
%Performs a binary Monter Carlo search. Given objective f, bitstring
%length n, and number of iterations, this algorithm will try
%to find the bitstring that maximizes f.
nVar = 3;
iter= 2;
histf = zeros(1,iters);
aopt = rand(nVar,1) > 0.5;
fopt = f(aopt);
histf(1) = fopt;
disp(aopt)
for i = 2:iters
    a = rand(nVar,1) > 0.5;
    fa = f(a)
    if (f(a) >= f(aopt))
        aopt = a;
        fopt = fa;
    end
    histf(i) = fopt;
    plot(histf)
    drawnow()
end
end