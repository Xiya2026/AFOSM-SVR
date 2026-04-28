function out = afosm_classic_u(prob, cfg)
% afosm_classic_u: Helper function in the AFOSM-SVR modular workflow.
nx = prob.Nx;
max_iter_afosm = get_cfg_or(cfg, "max_iter_afosm", cfg.max_iter);
conv_tol_afosm = get_cfg_or(cfg, "conv_tol_afosm", cfg.conv_tol);

u = zeros(1, nx);
beta_prev = Inf;
n_true_calls = 0;
beta_hist = [];
u_hist = [];

for k = 1:max_iter_afosm
    gk = eval_g_u(prob, u);
    n_true_calls = n_true_calls + 1;
    grad = zeros(1, nx);
    for i = 1:nx
        up = u;
        um = u;
        up(i) = up(i) + cfg.h_grad;
        um(i) = um(i) - cfg.h_grad;
        gp = eval_g_u(prob, up);
        gm = eval_g_u(prob, um);
        n_true_calls = n_true_calls + 2;
        grad(i) = (gp - gm) / (2 * cfg.h_grad);
    end
    ng = norm(grad);
    if ng < 1e-14
        break;
    end
    alpha = -grad / ng;
    beta_start = max(norm(u), cfg.beta_min);
    [beta_tmp, ~, ~, n_eval_beta, ok_root] = solve_beta_newton(prob, alpha, beta_start, cfg);
    n_true_calls = n_true_calls + n_eval_beta;
    if (~ok_root) || (~isfinite(beta_tmp)) || (beta_tmp < cfg.beta_min)
        beta_tmp = max((dot(grad, u) - gk) / ng, cfg.beta_min);
    end
    u_new = beta_tmp * alpha;
    beta_now = norm(u_new);
    beta_hist(k, 1) = beta_now; %#ok<AGROW>
    u_hist(k, :) = u_new; %#ok<AGROW>
    err_beta = abs(beta_now - beta_prev) / max(abs(beta_now), 1e-8);
    u = u_new;
    if k > 1 && (err_beta <= conv_tol_afosm)
        break;
    end
    beta_prev = beta_now;
end

out = struct();
out.u_final = u;
out.beta = norm(u);
out.pf = normcdf(-out.beta);
out.n_true_calls = n_true_calls;
out.n_true_calls_search = n_true_calls;
out.beta_hist = beta_hist;
out.u_hist = u_hist;
out.afosm_backend = "internal_u";
end



