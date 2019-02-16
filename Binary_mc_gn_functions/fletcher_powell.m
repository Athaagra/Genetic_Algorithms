function F = fletcher_powell(A, B, alpha, x)
% A, B: n-by-n matrix, real; alpha, x: column vector, real
n = length(A(:,1));
for (i=1:n)
    p(i) = sum(A(:,i) .* sin(alpha) + B(:,i) .* cos(alpha));
    q(i) = sum(A(:,i) .* sin(x) + B(:,i) .* cos(x));
end
    F = sum((p - q) .^ 2);
end