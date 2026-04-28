function out = afosm_classic(prob, cfg)
% afosm_classic: Core helper for AFOSM-SVR Example workflow.
afosm_backend = lower(string(get_cfg_or(cfg, "afosm_backend", "classic")));
if get_cfg_or(cfg, "require_uqlab_afosm", false) && ~strcmp(afosm_backend, "uqlab")
    error("AFOSM must use UQLab (require_uqlab_afosm=true), but afosm_backend='%s'.", afosm_backend);
end
if strcmp(afosm_backend, "uqlab")
    out = afosm_classic_uqlab(prob, cfg);
    return;
end

out = afosm_classic_di(prob, cfg);
return;

nx = prob.Nx;
max_iter_afosm = get_cfg_or(cfg, "max_iter_afosm", cfg.max_iter);
conv_tol_afosm = get_cfg_or(cfg, "conv_tol_afosm", cfg.conv_tol);

mu = get_mu_vector(prob, nx);
sigma = get_sigma_vector(prob, nx);
x = mu;
beta_prev = Inf;
n_true_calls = 0;

beta_hist = [];
u_hist = [];

for k = 1:max_iter_afosm
    gk = eval_g_x(prob, x);
    n_true_calls = n_true_calls + 1;

    grad = zeros(1, nx);
    for i = 1:nx
        h_i = max(cfg.h_grad, 1e-6 * max(1, abs(x(i))));
        xp = x;
        xm = x;
        xp(i) = xp(i) + h_i;
        xm(i) = xm(i) - h_i;
        gp = eval_g_x(prob, xp);
        gm = eval_g_x(prob, xm);
        n_true_calls = n_true_calls + 2;
        grad(i) = (gp - gm) / (2 * h_i);
    end

    denom = sqrt(sum((grad .* sigma).^2));
    if denom < 1e-14
        break;
    end

    % Classical AFOSM/HLRF direction cosine:
    % lambda_i = -(dg/dx_i)*sigma_i / sqrt(sum((dg/dx_j)^2*sigma_j^2))
    lambda = -(grad .* sigma) / denom;

    beta_start = max(norm((x - mu) ./ max(sigma, 1e-12)), cfg.beta_min);
    [beta_tmp, n_beta_calls, ok_root] = solve_beta_classic(prob, mu, sigma, lambda, beta_start, cfg);
    n_true_calls = n_true_calls + n_beta_calls;

    if (~ok_root) || (~isfinite(beta_tmp)) || (beta_tmp < cfg.beta_min)
        beta_tmp = max( ...
            sum(grad .* (mu - x)) / max(denom, 1e-12), ...
            cfg.beta_min);
    end

    x_new = mu + sigma .* lambda * beta_tmp;
    u_new = (x_new - mu) ./ max(sigma, 1e-12);

    beta_now = norm(u_new);
    beta_hist(k, 1) = beta_now; %#ok<AGROW>
    u_hist(k, :) = u_new; %#ok<AGROW>

    err_beta = abs(beta_now - beta_prev) / max(abs(beta_now), 1e-8);
    x = x_new;
    if k > 1 && (err_beta <= conv_tol_afosm)
        break;
    end

    beta_prev = beta_now;
end

out = struct();
out.u_final = (x - mu) ./ max(sigma, 1e-12);
out.beta = norm(out.u_final);
out.pf = normcdf(-out.beta);
out.n_true_calls = n_true_calls;
out.n_true_calls_search = n_true_calls;
out.beta_hist = beta_hist;
out.u_hist = u_hist;
out.afosm_backend = "internal_classic_be";
out.afosm_error = "";
end


