function [calls_est, parts] = estimate_total_true_calls(cfg, prob)
nx = prob.Nx;
n_runs = max(1, round(cfg.n_runs));

% MCS reference is computed once outside the per-run loop.
if cfg.run_mcs_ref_once || cfg.svm_relerr_filter_enable || cfg.run_mcs_only
    mcs_calls = max(0, round(cfg.n_mcs_ref_once));
else
    mcs_calls = 0;
end

if cfg.run_mcs_only
    calls_est = mcs_calls;
    parts = struct("mcs_calls", mcs_calls, "is_calls", 0, "search_calls", 0);
    return;
end

is_mult = 1; % AFOSM(DI)-SVR always present
if cfg.run_classic_afosm
    is_mult = is_mult + 1;
end
if cfg.run_ga
    is_mult = is_mult + 1;
end
if cfg.run_is_eval
    is_calls = n_runs * max(0, round(cfg.n_is_eval)) * is_mult;
else
    is_calls = 0;
end

% Rough design-search estimate per run (conservative but finite).
n_init_retry_max = max(0, round(get_cfg_or(cfg, "svm_init_retry_max", 6)));
n_init = max(1, round(get_cfg_or(cfg, "Ntrain_initial", 16)));
max_iter_svm = max(1, round(get_cfg_or(cfg, "max_iter_svm", 20)));
root_keep = max(0, round(get_cfg_or(cfg, "svm_rootline_max_keep", 6)));
step7_add = double(logical(get_cfg_or(cfg, "svm_enable_step7_repair", true)));
hl_steps = max(0, round(get_cfg_or(cfg, "svm_hl_refine_steps", 1)));

svm_core_est = n_init * (1 + n_init_retry_max) + max_iter_svm * (1 + root_keep + step7_add);
svm_refine_est = max(0, round(get_cfg_or(cfg, "beta_search_n", 16)));
svm_hl_est = hl_steps * (2 * nx + 2);
svm_search_per_run = svm_core_est + svm_refine_est + svm_hl_est;

if cfg.run_classic_afosm
    max_iter_afosm = max(1, round(get_cfg_or(cfg, "max_iter_afosm", 60)));
    af_search_per_run = max_iter_afosm * (2 * nx + 1);
else
    af_search_per_run = 0;
end

if cfg.run_ga
    ga_search_per_run = max(100, round(get_cfg_or(cfg, "ga_population", 120) * ...
        max(1, round(get_cfg_or(cfg, "ga_generations", 180)))));
else
    ga_search_per_run = 0;
end

search_calls = n_runs * (svm_search_per_run + af_search_per_run + ga_search_per_run);
calls_est = mcs_calls + is_calls + search_calls;

parts = struct();
parts.mcs_calls = mcs_calls;
parts.is_calls = is_calls;
parts.search_calls = search_calls;
end


