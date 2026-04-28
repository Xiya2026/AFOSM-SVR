function g = eval_g_x(prob, x)
% eval_g_x: Helper function in the AFOSM-SVR modular workflow.
if isvector(x)
    x = reshape(x, 1, []);
end
g = prob.Fung(x);
end



