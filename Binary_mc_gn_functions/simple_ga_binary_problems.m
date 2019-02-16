%Simple GA for binary Problems
function [parent,f_parent] = simple_ga_binary_problems(n, evals)
    func=@ackley;
    n = 100;
    evals = 500;
    p=1/n; %mutation rate
    %func  = @counting_ones;
    parent = rand(n,1) > 0.5; %generate initial solutions
    f_parent = func(parent);   %evaluate initial solutions
    hist_f(1) = f_parent;      %history administration
    
    for i = 2:evals
        disp(i)
        bits = (rand(n,1)<p);
        offspring = mod(parent + bits, 2);
        f_offspring = func(offspring);
        
        if (f_offspring <= f_parent)
            parent = offspring;
            f_parent = f_offspring;
        end
        
        hist_f(i) = f_parent;
        plot(hist_f)
        drawnow()
    end
end