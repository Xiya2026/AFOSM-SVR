function g = eval_g_u(prob, u)
% eval_g_u: Helper function in the AFOSM-SVR modular workflow.
if isvector(u)
    u = reshape(u, 1, []);
end
x = u_to_x(prob, u);
g = prob.Fung(x);
end



