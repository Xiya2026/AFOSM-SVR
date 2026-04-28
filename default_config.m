function cfg = default_config()
% default_config: Core helper for AFOSM-SVR Example workflow.
cfg = struct();

cfg.master_seed = 20260323;
cfg.reproducible = true;
cfg.n_runs = 10;

cfg.run_classic_afosm = true;
cfg.run_ga = true;

cfg.run_is_eval = true;
cfg.n_is_eval = 2e4;

cfg.run_mcs_ref_once = true;
cfg.n_mcs_ref_once = 2e6;
cfg.run_mcs_only = false;
cfg.pf_ref_external = NaN;     % optional external Pf reference for rel.err when MCS is off
cfg.pf_ref_label = "external";
cfg.external_ref_mismatch_check = true;
cfg.external_ref_mismatch_tol_pct = 50.0;
cfg.hide_relerr_on_external_mismatch = true;
cfg.mcs_group_enable = false;
cfg.mcs_group_size = 5000;
cfg.mcs_group_progress = true;

% Stress evaluator:
%   "demo"       : quick smooth surrogate
%   "fixed_wing" : call external Fixed_Wing-like FEM function
cfg.stress_mode = "demo";
cfg.stress_function = "fem_wing_stress_user_callback";
cfg.fixed_wing_function = "Fixed_Wing";

cfg.allowable_stress_mpa = 520;

% Random variables in document units:
% [h1(mm), h2(mm), h3(mm), h4(mm), d1(%c), d2(%c), Fbar(kN)]
cfg.rv_mu = [2.5, 15, 10, 5, 18, 67, 40];
cfg.rv_sd = [0.25, 1.5, 1, 0.5, 1, 1, 4];

cfg.geometry = struct();
cfg.geometry.root_chord_mm = 4000;
cfg.units = struct();
cfg.units.force_kN_to_N = 1000;

cfg.Ntrain_initial = 16;
cfg.h_diff_svm = 1e-4;
cfg.lambda = 0.35;
cfg.epsilon_svm = 1e-3;
cfg.max_iter_svm = 30;
cfg.svm_refine_on_true_lsf = true;
cfg.svm_hl_refine_steps = 1;
cfg.svm_relerr_filter_enable = true;
cfg.svm_relerr_threshold = 10.0;       % percent
cfg.svm_relerr_filter_max_retries = 1; % "recompute once" when rejected
cfg.retry_seed_stride = 1000;

cfg.h_diff_afosm = 1e-4;
cfg.epsilon_afosm = 1e-4;
cfg.max_iter_afosm = 60;
cfg.afosm_function = "Main_AFOSM_UQLab_DI";
cfg.require_uqlab_afosm = true;
cfg.uqlab_afosm_algorithm = "iHLRF";
cfg.require_uqlab_svr_form = true;
cfg.uqlab_svr_form_algorithm = "iHLRF";
cfg.uqlab_root_path = "";
cfg.uqlab_debug_paths = false;
cfg.uqlab_qpsolver = "auto";

cfg.ga_bound = 8;
cfg.ga_population = 120;
cfg.ga_generations = 180;
cfg.ga_multistart = 15;
cfg.beta_min = 1e-3;
cfg.beta_search_max = 12;
cfg.beta_search_n = 16;
cfg.beta_search_expand_max = 20;
cfg.root_accept_tol = 1e-6;
cfg.report_equivalent_time = true;
cfg.true_lsf_eval_cost_sec = 1.0;
cfg.is_mixture_origin_prob = 0.20;
cfg.is_log_floor = -745;
cfg.is_log_ceil = 700;

% Slow-run guard (for expensive FEM workflows).
cfg.slow_guard_enable = false;
cfg.slow_guard_abort = false;
cfg.slow_guard_force = false;
cfg.slow_guard_max_est_calls = 5e4;
cfg.slow_guard_max_est_hours = 8.0;

cfg.output_folder = "paper_figures_example4_wing";
cfg.save_results = true;
cfg.result_mat_name = "AFOSM_SVR_EX3_DI_results.mat";

% Demo stress surrogate controls (used only when stress_mode = "demo")
cfg.demo = struct();
cfg.demo.u_weights = [0.55, 0.35, 0.26, 0.18, 0.30, 0.28, 0.68];
cfg.demo.g0 = 3.30;
cfg.demo.nonlinear = 0.10;
cfg.demo.stress_scale = 35.0;
end



