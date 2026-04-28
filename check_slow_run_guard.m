function check_slow_run_guard(cfg, prob)
if ~logical(get_cfg_or(cfg, "slow_guard_enable", false))
    return;
end

[calls_est, parts] = estimate_total_true_calls(cfg, prob);
if ~isfinite(calls_est) || calls_est <= 0
    return;
end

est_hours = calls_est * max(cfg.true_lsf_eval_cost_sec, eps) / 3600;
max_calls = get_cfg_or(cfg, "slow_guard_max_est_calls", inf);
max_hours = get_cfg_or(cfg, "slow_guard_max_est_hours", inf);
exceed_calls = isfinite(max_calls) && calls_est > max_calls;
exceed_hours = isfinite(max_hours) && est_hours > max_hours;
if ~(exceed_calls || exceed_hours)
    return;
end

msg = sprintf([ ...
    'Slow-run guard triggered: estimated true-LSF calls=%.0f (MCS=%.0f, IS=%.0f, search~%.0f), ' ...
    'estimated wall time~%.2fh (%.2fs/call). Thresholds: max_calls=%.0f, max_hours=%.2f.\n' ...
    'Set cfg.slow_guard_force=true to bypass, or reduce n_runs / n_is_eval / n_mcs_ref_once.'], ...
    calls_est, parts.mcs_calls, parts.is_calls, parts.search_calls, ...
    est_hours, cfg.true_lsf_eval_cost_sec, max_calls, max_hours);

if logical(get_cfg_or(cfg, "slow_guard_force", false))
    fprintf("Slow-run guard bypassed by cfg.slow_guard_force=true. Estimated calls=%.0f, hours~%.2f.\n\n", ...
        calls_est, est_hours);
    return;
end

if logical(get_cfg_or(cfg, "slow_guard_abort", false))
    error("%s", msg);
else
    warning("%s", msg);
end
end


