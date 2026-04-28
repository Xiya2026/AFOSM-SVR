function [u_samples, g_samples] = collect_rootline_samples_svr(model, alpha, beta0, cfg)
% collect_rootline_samples_svr: Helper function in the AFOSM-SVR modular workflow.
u_samples = zeros(0, numel(alpha));
g_samples = zeros(0, 1);

alpha = reshape(alpha, 1, []);
na = norm(alpha);
if na < 1e-12
    return;
end
alpha = alpha / na;

beta_log = zeros(0, 1);
g_log = zeros(0, 1);
    function g = eval_beta_cached(b)
        bb = max(b, 0);
        if ~isempty(beta_log)
            [dmin, idx_min] = min(abs(beta_log - bb));
            if dmin <= 1e-12
                g = g_log(idx_min);
                return;
            end
        end
        uq = bb .* alpha;
        gh = predict_svr_model(model, uq);
        g = double(gh(1));
        if ~isfinite(g)
            g = NaN;
        end
        beta_log(end + 1, 1) = bb; %#ok<AGROW>
        g_log(end + 1, 1) = g; %#ok<AGROW>
    end

bL = 0;
fL = eval_beta_cached(bL);
bU = max([beta0, cfg.beta_min, 0.2]);
fU = eval_beta_cached(bU);

expand_count = 0;
while (expand_count < cfg.beta_search_n) && (bU < cfg.beta_search_expand_max)
    if isfinite(fL) && isfinite(fU) && (fL * fU <= 0)
        break;
    end
    bU = min(cfg.beta_search_expand_max, max(1.6 * bU, bU + 0.2));
    fU = eval_beta_cached(bU);
    expand_count = expand_count + 1;
end

if isfinite(fL) && isfinite(fU) && (fL * fU <= 0)
    beta_prev_it = bL;
    f_prev_it = fL;
    beta = min(max(beta0, bL + 1e-12), bU - 1e-12);
    f = eval_beta_cached(beta);
    if ~isfinite(f)
        beta = 0.5 * (bL + bU);
        f = eval_beta_cached(beta);
    end

    for it = 1:cfg.newton_max_iter
        if ~isfinite(f)
            beta_new = 0.5 * (bL + bU);
        else
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
        end

        f_new = eval_beta_cached(beta_new);
        if isfinite(f_new)
            if fL * f_new <= 0
                bU = beta_new;
                fU = f_new;
            else
                bL = beta_new;
                fL = f_new;
            end
        end

        beta_prev_it = beta;
        f_prev_it = f;
        beta = beta_new;
        f = f_new;

        if abs(bU - bL) <= cfg.newton_tol_beta * max(1, abs(beta))
            break;
        end
    end
end

if isempty(beta_log)
    return;
end

valid = isfinite(beta_log) & isfinite(g_log);
if ~any(valid)
    return;
end

u_all = beta_log(valid) .* repmat(alpha, sum(valid), 1);
[u_samples, ia] = unique(round(u_all, 10), "rows", "stable");
gv = g_log(valid);
g_samples = gv(ia);
end



