function cfg = default_config()
% default_config: Core helper for AFOSM-SVR Example workflow.
cfg = struct();

cfg.n_runs = 30;
cfg.master_seed = 20260317;
cfg.reproducible = false;

cfg.n_mcs_ref = 1e6;
cfg.mcs_chunk = 2e5;
cfg.n_is_eval = 4e4;
cfg.n_is_trace = 2e4;
cfg.accept_rel_err_pct = 6;
cfg.accept_cov_svm_max = 0.10;
cfg.max_attempts = 300;

cfg.n_init = 8;
cfg.u_init_bound = 6.0;
cfg.max_iter = 10;
cfg.max_iter_svm = 6;
cfg.max_iter_afosm = 35;
cfg.lambda = 0.35;
cfg.h_grad = 1e-5;
cfg.conv_tol = 1e-3;
cfg.conv_tol_svm = 5e-3;
cfg.conv_tol_afosm = 1e-6;
cfg.g_tol_afosm = 1e-5;
cfg.afosm_max_step_u = 4.0;
cfg.enable_step7 = true;
cfg.step7_min_iter = 2;
cfg.step7_g_tol_abs = 5e-3;
cfg.step7_beta_stall = 0.02;
cfg.duplicate_tol = 1e-6;
cfg.beta_probe = 1.0;
cfg.beta_min = 1e-3;
cfg.max_root_samples_keep = 8;

cfg.newton_max_iter = 4;
cfg.newton_tol_g = 1e-8;
cfg.newton_tol_beta = 1e-6;
cfg.newton_h = 1e-4;
cfg.root_accept_tol = 1e-6;
cfg.beta_search_max = 12;
cfg.beta_search_n = 12;
cfg.beta_search_expand_max = 20;

cfg.search_bound = 8;
cfg.ga_bound = 8;
cfg.ga_population = 120;
cfg.ga_generations = 180;

cfg.svm_box = 50;
cfg.svm_epsilon = 1e-3;
cfg.svm_kernel_scale = "auto";
cfg.unique_round_digits = 8;
cfg.svr_backend_primary = "uqlab";
cfg.enable_svr_backend_comparison = false;
cfg.svr_compare_backends = ["uqlab"];
cfg.uqlab_svr_loss = "l1-eps";
cfg.uqlab_svr_kernel_isotropic = 0;
cfg.uqlab_svr_optim_method = "BFGS";
cfg.uqlab_qpsolver = "auto";
cfg.afosm_backend = "uqlab";
cfg.uqlab_afosm_method = "FORM";
cfg.uqlab_afosm_algorithm = "iHLRF";
cfg.require_uqlab_svr_form = true;
cfg.require_uqlab_afosm = true;
cfg.uqlab_root_path = "";
cfg.uqlab_debug_paths = false;

cfg.output_folder = "paper_figures_example2_rotating_disk";
cfg.export_png = false;
cfg.export_pdf = false;
cfg.grid_n = 220;
cfg.plot_u1 = [-4, 6];
cfg.plot_u2 = [-1, 6];
cfg.fig2_zoom_half_width = [0.30, 0.24];
cfg.fig3_zoom_half_width = [0.35, 0.30];
cfg.enable_inset_zoom = false;

% To match Table 4 (Direct MCS ~= 1.04e-3), omega statistics are set to 21 +/- 1 krpm.
% The 24 +/- 0.5 value shown in some scans of Table 3 is inconsistent with Table 4.
cfg.omega_mean_krpm = 21;
cfg.omega_std_krpm = 1;
end


