function tf = should_enable_step7(cfg, k, beta_now, beta_prev, g_true_new, g_hat_new, S_g)
if ~isfield(cfg, "enable_step7") || ~cfg.enable_step7
    tf = false;
    return;
end

if k < get_cfg_or(cfg, "step7_min_iter", 2)
    tf = false;
    return;
end

rel_beta = Inf;
if isfinite(beta_prev)
    rel_beta = abs(beta_now - beta_prev) / max(abs(beta_now), 1e-8);
end
stall_tol = get_cfg_or(cfg, "step7_beta_stall", 0.02);
is_stalled = rel_beta <= stall_tol;

g_tol = get_cfg_or(cfg, "step7_g_tol_abs", 5e-3);
need_by_true = abs(g_true_new) > g_tol;
% Keep optional inputs for interface compatibility.
% Step-7 gate is now based only on true-LSF residual.
tf = is_stalled && need_by_true;
end


