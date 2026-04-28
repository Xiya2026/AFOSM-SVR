function [beta, u_samples, g_samples, n_eval, success] = solve_beta_newton(prob, alpha, beta0, cfg)
% solve_beta_newton: Helper function in the AFOSM-SVR modular workflow.
beta = max(beta0, cfg.beta_min);
n_eval = 0;
beta_log = zeros(0, 1);
g_log = zeros(0, 1);
success = false;

    function g = eval_beta_cached(b)
        bb = max(b, 0);
        if ~isempty(beta_log)
            [dmin, idx_min] = min(abs(beta_log - bb));
            if dmin <= 1e-12
                g = g_log(idx_min);
                return;
            end
        end
        g = eval_g_u(prob, bb * alpha);
        n_eval = n_eval + 1;
        beta_log(end + 1, 1) = bb; %#ok<AGROW>
        g_log(end + 1, 1) = g; %#ok<AGROW>
    end

bL = 0;
fL = eval_beta_cached(bL);
if abs(fL) <= cfg.root_accept_tol
    beta = cfg.beta_min;
    success = true;
else
    bU = max([beta, cfg.beta_min, 0.2]);
    fU = eval_beta_cached(bU);

    expand_count = 0;
    while (fL * fU > 0) && (bU < cfg.beta_search_expand_max) && (expand_count < cfg.beta_search_n)
        bU = min(cfg.beta_search_expand_max, max(1.6 * bU, bU + 0.2));
        fU = eval_beta_cached(bU);
        expand_count = expand_count + 1;
    end

    if fL * fU > 0
        [~, imin] = min(abs(g_log));
        beta = max(beta_log(imin), cfg.beta_min);
        success = false;
    else
        beta_prev_it = bL;
        f_prev_it = fL;
        beta = min(max(beta, bL + 1e-12), bU - 1e-12);
        f = eval_beta_cached(beta);

        for it = 1:cfg.newton_max_iter
            if abs(f) <= cfg.root_accept_tol
                success = true;
                break;
            end

            use_secant = abs(beta - beta_prev_it) > 1e-12 && abs(f - f_prev_it) > 1e-12;
            if use_secant
                df = (f - f_prev_it) / (beta - beta_prev_it);
            else
                df = NaN;
            end

            if (~isfinite(df)) || (abs(df) < 1e-12)
                beta_new = 0.5 * (bL + bU);
            else
                beta_new = beta - f / df;
                if (~isfinite(beta_new)) || (beta_new <= bL) || (beta_new >= bU)
                    beta_new = 0.5 * (bL + bU);
                end
            end

            f_new = eval_beta_cached(beta_new);
            if fL * f_new <= 0
                bU = beta_new;
                fU = f_new;
            else
                bL = beta_new;
                fL = f_new;
            end

            beta_prev_it = beta;
            f_prev_it = f;
            beta = beta_new;
            f = f_new;

            if abs(bU - bL) <= cfg.newton_tol_beta * max(1, abs(beta))
                beta = 0.5 * (bL + bU);
                f = eval_beta_cached(beta);
                success = abs(f) <= max(cfg.root_accept_tol, cfg.newton_tol_g);
                break;
            end
        end

        if ~success
            beta = 0.5 * (bL + bU);
            f = eval_beta_cached(beta);
            success = abs(f) <= max(cfg.root_accept_tol, cfg.newton_tol_g);
        end
    end
end

if isempty(beta_log)
    u_samples = zeros(0, numel(alpha));
    g_samples = zeros(0, 1);
else
    u_all = beta_log .* repmat(alpha, numel(beta_log), 1);
    [u_samples, ia] = unique(round(u_all, 10), "rows", "stable");
    g_samples = g_log(ia);
end
end



