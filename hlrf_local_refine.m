function [u_out, beta_out, n_true_calls] = hlrf_local_refine(prob, u_in, cfg)
n_true_calls = 0;
u = reshape(u_in, 1, []);
nx = prob.Nx;

for k = 1:cfg.svm_hl_refine_steps
    g0 = eval_g_u(prob, u);
    n_true_calls = n_true_calls + 1;

    grad = zeros(1, nx);
    for j = 1:nx
        up = u; up(j) = up(j) + cfg.h_diff_afosm;
        um = u; um(j) = um(j) - cfg.h_diff_afosm;
        gp = eval_g_u(prob, up);
        gm = eval_g_u(prob, um);
        grad(j) = (gp - gm) / (2 * cfg.h_diff_afosm);
        n_true_calls = n_true_calls + 2;
    end

    ng = norm(grad);
    if ng < 1e-12
        break;
    end
    beta_raw = (grad * u' - g0) / ng;
    alpha = -grad / ng;

    % Keep direction toward failure side.
    u_test = u + 0.05 * alpha;
    g_test = eval_g_u(prob, u_test);
    n_true_calls = n_true_calls + 1;
    if g_test > g0
        alpha = -alpha;
        beta_raw = -beta_raw;
    end

    beta_new = max(abs(beta_raw), cfg.beta_min);
    u_new = beta_new * alpha;
    if norm(u_new - u, inf) < cfg.epsilon_afosm
        u = u_new;
        break;
    end
    u = u_new;
end

u_out = u;
beta_out = norm(u);
end


