function g = eval_g_u(prob, u)
if isvector(u)
    u = reshape(u, 1, []);
end
x = u_to_x(prob, u);
g = prob.Fung(x);
end


