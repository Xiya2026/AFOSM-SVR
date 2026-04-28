function cfg = normalize_cfg(cfg, base_cfg)
cfg.rv_mu = normalize_numeric_vector(cfg.rv_mu, base_cfg.rv_mu, 7, false);
cfg.rv_sd = normalize_numeric_vector(cfg.rv_sd, base_cfg.rv_sd, 7, true);

if ~ischar(cfg.stress_mode) && ~isstring(cfg.stress_mode)
    cfg.stress_mode = base_cfg.stress_mode;
end
if ~ischar(cfg.stress_function) && ~isstring(cfg.stress_function)
    cfg.stress_function = base_cfg.stress_function;
end
if ~isfield(cfg, 'run_mcs_only') || isempty(cfg.run_mcs_only)
    cfg.run_mcs_only = base_cfg.run_mcs_only;
end
if ~isfield(cfg, 'mcs_group_enable') || isempty(cfg.mcs_group_enable)
    cfg.mcs_group_enable = base_cfg.mcs_group_enable;
end
if ~isfield(cfg, 'mcs_group_size') || ~isscalar(cfg.mcs_group_size) || ~isfinite(cfg.mcs_group_size)
    cfg.mcs_group_size = base_cfg.mcs_group_size;
end
cfg.mcs_group_size = max(1, round(cfg.mcs_group_size));
if ~isfield(cfg, 'mcs_group_progress') || isempty(cfg.mcs_group_progress)
    cfg.mcs_group_progress = base_cfg.mcs_group_progress;
end
if ~isfield(cfg, 'afosm_function') || isempty(cfg.afosm_function) || ...
        (~ischar(cfg.afosm_function) && ~isstring(cfg.afosm_function))
    cfg.afosm_function = base_cfg.afosm_function;
end
if ~isfield(cfg, 'svm_refine_on_true_lsf') || isempty(cfg.svm_refine_on_true_lsf)
    cfg.svm_refine_on_true_lsf = base_cfg.svm_refine_on_true_lsf;
end
if ~isfield(cfg, 'svm_hl_refine_steps') || ~isscalar(cfg.svm_hl_refine_steps) || ~isfinite(cfg.svm_hl_refine_steps)
    cfg.svm_hl_refine_steps = base_cfg.svm_hl_refine_steps;
end
cfg.svm_hl_refine_steps = max(0, round(cfg.svm_hl_refine_steps));
if ~isfield(cfg, 'svm_relerr_filter_enable') || isempty(cfg.svm_relerr_filter_enable)
    cfg.svm_relerr_filter_enable = base_cfg.svm_relerr_filter_enable;
end
if ~isfield(cfg, 'svm_relerr_threshold') || ~isscalar(cfg.svm_relerr_threshold) || ~isfinite(cfg.svm_relerr_threshold)
    cfg.svm_relerr_threshold = base_cfg.svm_relerr_threshold;
end
cfg.svm_relerr_threshold = max(cfg.svm_relerr_threshold, 0);
if ~isfield(cfg, 'svm_relerr_filter_max_retries') || ~isscalar(cfg.svm_relerr_filter_max_retries) || ~isfinite(cfg.svm_relerr_filter_max_retries)
    cfg.svm_relerr_filter_max_retries = base_cfg.svm_relerr_filter_max_retries;
end
cfg.svm_relerr_filter_max_retries = max(0, round(cfg.svm_relerr_filter_max_retries));
if ~isfield(cfg, 'retry_seed_stride') || ~isscalar(cfg.retry_seed_stride) || ~isfinite(cfg.retry_seed_stride)
    cfg.retry_seed_stride = base_cfg.retry_seed_stride;
end
cfg.retry_seed_stride = max(1, round(cfg.retry_seed_stride));
if ~isfield(cfg, 'report_equivalent_time') || isempty(cfg.report_equivalent_time)
    cfg.report_equivalent_time = base_cfg.report_equivalent_time;
end
if ~isfield(cfg, 'true_lsf_eval_cost_sec') || ~isscalar(cfg.true_lsf_eval_cost_sec) || ~isfinite(cfg.true_lsf_eval_cost_sec) || cfg.true_lsf_eval_cost_sec <= 0
    cfg.true_lsf_eval_cost_sec = base_cfg.true_lsf_eval_cost_sec;
end
if ~isfield(cfg, 'is_mixture_origin_prob') || ~isscalar(cfg.is_mixture_origin_prob) || ~isfinite(cfg.is_mixture_origin_prob)
    cfg.is_mixture_origin_prob = base_cfg.is_mixture_origin_prob;
end
cfg.is_mixture_origin_prob = min(max(cfg.is_mixture_origin_prob, 0.01), 0.99);

if ~isfield(cfg, 'is_log_floor') || ~isscalar(cfg.is_log_floor) || ~isfinite(cfg.is_log_floor)
    cfg.is_log_floor = base_cfg.is_log_floor;
end
if ~isfield(cfg, 'is_log_ceil') || ~isscalar(cfg.is_log_ceil) || ~isfinite(cfg.is_log_ceil)
    cfg.is_log_ceil = base_cfg.is_log_ceil;
end
if cfg.is_log_floor >= cfg.is_log_ceil
    cfg.is_log_floor = base_cfg.is_log_floor;
    cfg.is_log_ceil = base_cfg.is_log_ceil;
end
end


