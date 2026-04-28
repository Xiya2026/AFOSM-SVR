function out = afosm_classic_u(prob, cfg)
nx = prob.Nx;
max_iter_afosm = get_cfg_or(cfg, "max_iter_afosm", cfg.max_iter);
conv_tol_afosm = get_cfg_or(cfg, "conv_tol_afosm", cfg.conv_tol);
g_tol_afosm = get_cfg_or(cfg, "g_tol_afosm", 1e-5);
max_step_u = get_cfg_or(cfg, "afosm_max_step_u", 4.0);

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

    % HLRF update in U-space:
    % u_{k+1} = ((grad*u_k - g(u_k))/||grad||^2) * grad
    c = (dot(grad, u) - gk) / (ng^2);
    u_new = c * grad;
    if any(~isfinite(u_new))
        break;
    end

    step = u_new - u;
    step_norm = norm(step);
    if step_norm > max_step_u
        u_new = u + step * (max_step_u / max(step_norm, 1e-12));
    end

    % Simple safeguard: if residual worsens, shrink step.
    g_new = eval_g_u(prob, u_new);
    n_true_calls = n_true_calls + 1;
    if (~isfinite(g_new)) || (abs(g_new) > abs(gk))
        eta = 0.5;
        improved = false;
        while eta >= (1/32)
            u_try = u + eta * (u_new - u);
            g_try = eval_g_u(prob, u_try);
            n_true_calls = n_true_calls + 1;
            if isfinite(g_try) && (abs(g_try) <= abs(g_new))
                u_new = u_try;
                g_new = g_try;
                improved = true;
                break;
            end
            eta = 0.5 * eta;
        end
        if ~improved && ~isfinite(g_new)
            break;
        end
    end

    beta_now = norm(u_new);
    beta_hist(k, 1) = beta_now; %#ok<AGROW>
    u_hist(k, :) = u_new; %#ok<AGROW>
    err_beta = abs(beta_now - beta_prev) / max(abs(beta_now), 1e-8);
    err_u = norm(u_new - u) / max(norm(u_new), 1e-8);
    u = u_new;
    if k > 1 && (err_beta <= conv_tol_afosm) && (err_u <= conv_tol_afosm) && ...
            (abs(g_new) <= max(g_tol_afosm, cfg.root_accept_tol))
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
end


