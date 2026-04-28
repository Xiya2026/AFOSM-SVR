function g = eval_g_x(prob, x)
if isvector(x)
    x = reshape(x, 1, []);
end
g = prob.Fung(x);
end


