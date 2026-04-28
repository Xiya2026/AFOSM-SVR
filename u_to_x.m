function x = u_to_x(prob, u)
if isvector(u)
    u = reshape(u, 1, []);
end
[n, nx] = size(u);
x = zeros(n, nx);
for i = 1:nx
    para = prob.Para{i};
    x(:, i) = para(1) + para(2) .* u(:, i);
end
end


