function out = afosm_classic_di(prob, cfg)
nx = prob.Nx;
max_iter_afosm = get_cfg_or(cfg, "max_iter_afosm", cfg.max_iter);
conv_tol_afosm = get_cfg_or(cfg, "conv_tol_afosm", cfg.conv_tol);

u = zeros(1, nx);
n_true_calls = 0;
beta_prev = Inf;
beta_hist = [];
u_hist = [];

for k = 1:max_iter_afosm
    gk = eval_g_u(prob, u);
    n_true_calls = n_true_calls + 1;

    grad = zeros(1, nx);
    for i = 1:nx
        h_i = max(cfg.h_grad, 1e-6 * max(1, abs(u(i))));
        up = u;
        um = u;
        up(i) = up(i) + h_i;
        um(i) = um(i) - h_i;
        gp = eval_g_u(prob, up);
        gm = eval_g_u(prob, um);
        n_true_calls = n_true_calls + 2;
        grad(i) = (gp - gm) / (2 * h_i);
    end

    ng = norm(grad);
    if ng < 1e-14
        break;
    end
    alpha = -grad / ng;
    beta_raw = (dot(grad, u) - gk) / max(ng, 1e-12);
    if ~isfinite(beta_raw)
        beta_raw = norm(u);
    end
    beta_raw = min(max(beta_raw, -cfg.beta_search_expand_max), cfg.beta_search_expand_max);
    u_new = -beta_raw * alpha;
    if any(~isfinite(u_new))
        u_new = u;
    end
    if norm(u_new) < cfg.beta_min
        u_new = cfg.beta_min * alpha;
    end

    beta_now = max(norm(u_new), cfg.beta_min);
    beta_hist(k, 1) = beta_now; %#ok<AGROW>
    u_hist(k, :) = u_new; %#ok<AGROW>

    err_beta = abs(beta_now - beta_prev) / max(abs(beta_now), 1e-8);
    err_u = norm(u_new - u, Inf);
    u = u_new;
    if k > 1 && (err_beta <= conv_tol_afosm || err_u <= conv_tol_afosm)
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
out.afosm_backend = "internal_di";
out.afosm_error = "";
end


