function [beta, n_eval, success] = solve_beta_classic(prob, mu, sigma, lambda, beta0, cfg)
beta = max(beta0, cfg.beta_min);
n_eval = 0;
success = false;

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
        xq = mu + sigma .* lambda * bb;
        g = eval_g_x(prob, xq);
        n_eval = n_eval + 1;
        beta_log(end + 1, 1) = bb; %#ok<AGROW>
        g_log(end + 1, 1) = g; %#ok<AGROW>
    end

bL = 0;
fL = eval_beta_cached(bL);
if abs(fL) <= cfg.root_accept_tol
    beta = cfg.beta_min;
    success = true;
    return;
end

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
    return;
end

froot = @(b) eval_beta_cached(b);
try
    beta = fzero(froot, [bL, bU]);
catch
    beta = 0.5 * (bL + bU);
end
if ~isfinite(beta)
    beta = 0.5 * (bL + bU);
end
beta = max(beta, cfg.beta_min);
success = abs(eval_beta_cached(beta)) <= max(cfg.root_accept_tol, cfg.newton_tol_g);
end


