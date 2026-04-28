function [u0, n_calls] = afosm_initial_guess(prob, cfg)
nx = prob.Nx;
n_seed = max(30, 4 * cfg.n_init);
u_seed = -cfg.u_init_bound + 2 * cfg.u_init_bound * lhsdesign(n_seed, nx);
g_seed = eval_g_u(prob, u_seed);
n_calls = n_seed;
[~, idx] = min(abs(g_seed));
u0 = u_seed(idx, :);
end


