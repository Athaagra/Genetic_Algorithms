function f = autorrelation(a)
% autocorrelation(a); a: column vector, {-1, +1}
    n = length(a);
    
    for (k=1:n-1)
        E(k) =  (sum(a(1:n-k) .* a(1+k:n))).^2;
    end
    
    f = n^2./ (2 * sum(E));
end