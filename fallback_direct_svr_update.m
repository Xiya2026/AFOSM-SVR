function [u_new, beta_sol] = fallback_direct_svr_update(model, u_current, cfg)
nx = numel(u_current);
grad_hat = central_diff_svr(model, u_current, cfg.h_grad);
ng = norm(grad_hat);
if ng < 1e-12
    alpha = u_current / max(norm(u_current), 1e-8);
    if norm(alpha) < 1e-12
        alpha = [zeros(1, nx - 1), 1];
    end
else
    alpha = -grad_hat / ng;
end

g_hat_current = predict_svr_model(model, u_current);
ng_eff = max(ng, 1e-12);
beta_raw = (dot(grad_hat, u_current) - g_hat_current) / ng_eff;
if ~isfinite(beta_raw)
    beta_raw = norm(u_current);
end
beta_raw = min(max(beta_raw, -cfg.beta_search_expand_max), cfg.beta_search_expand_max);
u_new = -beta_raw * alpha;
beta_sol = norm(u_new);
end


