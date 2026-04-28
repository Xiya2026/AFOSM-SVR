function results = AFOSM_SVR_EX3_DI(cfg_in)
% AFOSM_SVR_EX3_DI
% Example 4 (FEM wing): AFOSM(DI)-SVR vs AFOSM(DI) vs GA, with optional IS/MCS refs.
%
% Random variables in document units:
%   x = [h1, h2, h3, h4, d1_percent, d2_percent, Fbar_kN]
%
% Limit-state:
%   g(x) = sigma_allow - sigma_vm_max(x), sigma_allow = 520 MPa.

clc;
ensure_local_function_priority();

base_cfg = default_config();
cfg = base_cfg;
if nargin >= 1 && isstruct(cfg_in)
    cfg = merge_cfg(cfg, cfg_in);
end
cfg = merge_cfg(base_cfg, cfg); % fill missing/empty fields with defaults
cfg = normalize_cfg(cfg, base_cfg);
mu_doc = reshape(cfg.rv_mu, 1, []);
sd_doc = reshape(cfg.rv_sd, 1, []);
if numel(mu_doc) ~= 7 || any(~isfinite(mu_doc))
    mu_doc = reshape(base_cfg.rv_mu, 1, []);
    cfg.rv_mu = mu_doc;
end
if numel(sd_doc) ~= 7 || any(~isfinite(sd_doc)) || any(sd_doc <= 0)
    sd_doc = reshape(base_cfg.rv_sd, 1, []);
    cfg.rv_sd = sd_doc;
end

if cfg.reproducible
    rng(cfg.master_seed, "twister");
else
    rng("shuffle");
    cfg.master_seed = randi([1, 2^31 - 1], 1, 1);
end

check_dependencies(cfg);
prob = build_wing_problem(cfg);
if ~isfield(prob, "Para") || isempty(prob.Para)
    error("Probability parameters are empty after normalization. Check cfg.rv_mu and cfg.rv_sd.");
end

fprintf("==== AFOSM(DI)-SVR: Example 4 (FEM wing) ====\n");
fprintf("stress_mode          : %s\n", cfg.stress_mode);
fprintf("stress_function      : %s\n", cfg.stress_function);
fprintf("n_runs               : %d\n", cfg.n_runs);
fprintf("master_seed          : %d\n", cfg.master_seed);
fprintf("allowable stress MPa : %.3f\n", cfg.allowable_stress_mpa);
fprintf("RV mu (doc units)    : [%s]\n", join_num(mu_doc));
fprintf("RV sd (doc units)    : [%s]\n", join_num(sd_doc));
fprintf("compare AFOSM        : %s\n", tf_char(cfg.run_classic_afosm));
fprintf("AFOSM function       : %s\n", cfg.afosm_function);
fprintf("AFOSM FORM algorithm : %s\n", string(get_cfg_or(cfg, "uqlab_afosm_algorithm", "iHLRF")));
fprintf("compare GA           : %s\n", tf_char(cfg.run_ga));
fprintf("IS evaluation        : %s (N=%d)\n", tf_char(cfg.run_is_eval), cfg.n_is_eval);
fprintf("MCS reference        : %s (N=%d)\n", tf_char(cfg.run_mcs_ref_once), cfg.n_mcs_ref_once);
if cfg.mcs_group_enable
    fprintf("MCS grouped          : ON (group=%d)\n", cfg.mcs_group_size);
else
    fprintf("MCS grouped          : OFF\n");
end
fprintf("MCS-only mode        : %s\n", tf_char(cfg.run_mcs_only));
fprintf("SVR rel.err filter   : %s (thr=%.2f%%, max_retries=%d)\n", ...
    tf_char(cfg.svm_relerr_filter_enable), cfg.svm_relerr_threshold, cfg.svm_relerr_filter_max_retries);
mu_fixed = doc_to_fixed_wing_units(mu_doc, cfg);
fprintf("Equivalent Fixed_Wing mu [h1 h2 h3 h4 d1_mm d2_mm F_N] : [%s]\n\n", join_num(mu_fixed));
if strcmpi(char(cfg.stress_mode), 'demo')
    fprintf("NOTE: demo mode uses cheap stress callback; wall-clock time is not representative of true FEM cost.\n");
    fprintf("      Use 'EqFEMTime' (derived from true-LSF call count) for method-efficiency comparison.\n\n");
end

check_slow_run_guard(cfg, prob);

% -------- MCS reference (computed before runs if needed) --------
pf_mcs_ref = NaN;
cov_mcs_ref = NaN;
beta_mcs_ref = NaN;
time_mcs_ref = NaN;
need_mcs_ref = cfg.run_mcs_ref_once || cfg.svm_relerr_filter_enable || cfg.run_mcs_only;
if need_mcs_ref
    fprintf("Computing one-shot reference MCS (N = %d)...\n", cfg.n_mcs_ref_once);
    t_mcs = tic;
    if cfg.mcs_group_enable && cfg.mcs_group_size > 0 && cfg.n_mcs_ref_once > cfg.mcs_group_size
        [pf_mcs_ref, cov_mcs_ref] = main_mcs_grouped(prob, cfg.n_mcs_ref_once, cfg.mcs_group_size, cfg);
    else
        [pf_mcs_ref, cov_mcs_ref] = Main_MCS(prob, cfg.n_mcs_ref_once);
    end
    time_mcs_ref = toc(t_mcs);
    if isfinite(pf_mcs_ref) && pf_mcs_ref > 0 && pf_mcs_ref < 1
        beta_mcs_ref = -norminv(pf_mcs_ref);
    end
    fprintf("  MCS ref: Pf=%.6e, beta=%.4f, CoV=%.4f, time=%.2fs\n\n", ...
        pf_mcs_ref, beta_mcs_ref, cov_mcs_ref, time_mcs_ref);
end

if cfg.run_mcs_only
    fprintf("MCS-only mode enabled. Skipping AFOSM(DI)-SVR/AFOSM(DI)/GA runs.\n\n");
    results = struct();
    results.cfg = cfg;
    results.problem = prob;
    results.svm_runs = struct([]);
    results.afosm_runs = struct([]);
    results.ga_runs = struct([]);
    results.summary = struct();
    results.reference_mcs = struct("pf", pf_mcs_ref, "beta", beta_mcs_ref, ...
        "cov", cov_mcs_ref, "time_sec", time_mcs_ref, "n_samples", cfg.n_mcs_ref_once);

    if cfg.save_results
        root_dir = fileparts(mfilename("fullpath"));
        if isempty(root_dir)
            root_dir = pwd;
        end
        out_dir = fullfile(root_dir, cfg.output_folder);
        if ~exist(out_dir, "dir")
            mkdir(out_dir);
        end
        save_file = fullfile(out_dir, cfg.result_mat_name);
        save(save_file, "results", "-v7.3");
        fprintf("Saved results: %s\n", save_file);
    end
    return;
end

n_runs = max(1, round(cfg.n_runs));
svm_runs = repmat(empty_run_template(prob.Nx), n_runs, 1);
if cfg.run_classic_afosm
    afosm_runs = repmat(empty_run_template(prob.Nx), n_runs, 1);
else
    afosm_runs = struct([]);
end
if cfg.run_ga
    ga_runs = repmat(empty_run_template(prob.Nx), n_runs, 1);
else
    ga_runs = struct([]);
end

for i = 1:n_runs
    accepted = false;
    attempt = 0;
    while ~accepted
        attempt = attempt + 1;
        run_seed = cfg.master_seed + i + (attempt - 1) * cfg.retry_seed_stride;
        rng(run_seed, "twister");
        if attempt == 1
            fprintf("Run %02d/%02d\n", i, n_runs);
        else
            fprintf("Run %02d/%02d (retry %d)\n", i, n_runs, attempt - 1);
        end

        % -------- AFOSM(DI)-SVR --------
        t0 = tic;
        [pf_svm, cov_svm, ncall_svm, u_svm, beta_svm] = afosm_svr_entry(prob, cfg);
        t_svm = toc(t0);
        ncall_svm_core = ncall_svm;
        ncall_svm_refine = 0;
        ncall_svm_hl = 0;

        run_svm = empty_run_template(prob.Nx);
        run_svm.pf_beta = pf_svm;
        run_svm.cov_beta = cov_svm;
        run_svm.beta = beta_svm;
        run_svm.u_final = reshape(u_svm, 1, []);
        run_svm.x_final = u_to_x(prob, run_svm.u_final);
        run_svm.ncall_search = ncall_svm;
        run_svm.time_sec = t_svm;
        run_svm.method = 'AFOSM(DI)-SVR';

        if cfg.svm_refine_on_true_lsf
            [u_ref, beta_ref, n_ref] = refine_design_on_true_lsf(prob, run_svm.u_final, cfg);
            ncall_svm_refine = n_ref;
            run_svm.u_final = u_ref;
            run_svm.x_final = u_to_x(prob, run_svm.u_final);
            run_svm.beta = beta_ref;
            run_svm.pf_beta = normcdf(-abs(beta_ref));
            run_svm.cov_beta = NaN;
            run_svm.ncall_search = run_svm.ncall_search + n_ref;
        end
        if cfg.svm_hl_refine_steps > 0
            [u_hl, beta_hl, n_hl] = hlrf_local_refine(prob, run_svm.u_final, cfg);
            ncall_svm_hl = n_hl;
            run_svm.u_final = u_hl;
            run_svm.x_final = u_to_x(prob, run_svm.u_final);
            run_svm.beta = beta_hl;
            run_svm.pf_beta = normcdf(-abs(beta_hl));
            run_svm.cov_beta = NaN;
            run_svm.ncall_search = run_svm.ncall_search + n_hl;
        end
        run_svm.call_breakdown = struct( ...
            "core", ncall_svm_core, ...
            "refine", ncall_svm_refine, ...
            "hl", ncall_svm_hl);

        % -------- AFOSM(DI) --------
        run_af = empty_run_template(prob.Nx);
        if cfg.run_classic_afosm
            t1 = tic;
            af_fun = str2func(char(cfg.afosm_function));
            [pf_af, cov_af, ncall_af, beta_af, u_af] = af_fun( ...
                prob, cfg.h_diff_afosm, cfg.epsilon_afosm, cfg.max_iter_afosm);
            t_af = toc(t1);

            run_af.pf_beta = pf_af;
            run_af.cov_beta = cov_af;
            run_af.beta = beta_af;
            run_af.u_final = reshape(u_af, 1, []);
            run_af.x_final = u_to_x(prob, run_af.u_final);
            run_af.ncall_search = ncall_af;
            run_af.time_sec = t_af;
            run_af.method = 'AFOSM(DI)';
        end

        % -------- GA --------
        run_ga = empty_run_template(prob.Nx);
        if cfg.run_ga
            t2 = tic;
            run_ga = ga_design_point(prob, cfg);
            run_ga.time_sec = toc(t2);
            run_ga.pf_beta = normcdf(-abs(run_ga.beta));
            run_ga.cov_beta = NaN;
            run_ga.method = 'GA';
        end

        % -------- IS evaluation on true LSF --------
        if cfg.run_is_eval
            seed_base = run_seed + 100000 * i;

            [run_svm.pf_is, run_svm.cov_is] = estimate_pf_is_true(prob, run_svm.u_final, cfg.n_is_eval, seed_base + 1, cfg);
            run_svm.ncall_is = cfg.n_is_eval;

            if cfg.run_classic_afosm
                [run_af.pf_is, run_af.cov_is] = estimate_pf_is_true(prob, run_af.u_final, cfg.n_is_eval, seed_base + 2, cfg);
                run_af.ncall_is = cfg.n_is_eval;
            end
            if cfg.run_ga
                [run_ga.pf_is, run_ga.cov_is] = estimate_pf_is_true(prob, run_ga.u_final, cfg.n_is_eval, seed_base + 3, cfg);
                run_ga.ncall_is = cfg.n_is_eval;
            end
        end

        report_one_run(run_svm, run_af, run_ga, cfg);

        accepted = true;
        if cfg.svm_relerr_filter_enable && isfinite(pf_mcs_ref)
            [pf_svm_cmp, ~] = choose_pf_cov_for_report(run_svm, cfg);
            rel_err_svm = relative_error_pct(pf_svm_cmp, pf_mcs_ref);
            if isfinite(rel_err_svm) && rel_err_svm > cfg.svm_relerr_threshold
                if attempt <= cfg.svm_relerr_filter_max_retries
                    accepted = false;
                    fprintf("  Reject this AFOSM(DI)-SVR run: rel.err=%.2f%% > %.2f%%. Recomputing this run...\n\n", ...
                        rel_err_svm, cfg.svm_relerr_threshold);
                else
                    fprintf("  Warning: AFOSM(DI)-SVR rel.err=%.2f%% still > %.2f%% after %d retries; accepting this run.\n\n", ...
                        rel_err_svm, cfg.svm_relerr_threshold, cfg.svm_relerr_filter_max_retries);
                end
            end
        end
    end

    svm_runs(i) = run_svm;
    if cfg.run_classic_afosm
        afosm_runs(i) = run_af;
    end
    if cfg.run_ga
        ga_runs(i) = run_ga;
    end
end

[pf_ref_relerr, pf_ref_relerr_label] = resolve_pf_ref_for_relerr(cfg, pf_mcs_ref);

summary = struct();
summary.svm = summarize_method(svm_runs, pf_ref_relerr, cfg);
if cfg.run_classic_afosm
    summary.afosm = summarize_method(afosm_runs, pf_ref_relerr, cfg);
else
    summary.afosm = struct();
end
if cfg.run_ga
    summary.ga = summarize_method(ga_runs, pf_ref_relerr, cfg);
else
    summary.ga = struct();
end

[ext_ref_mismatch, ext_ref_rel_diff_pct, ext_ref_anchor_pf, ext_ref_anchor_label] = ...
    detect_external_ref_mismatch(cfg, pf_mcs_ref, summary);
if ext_ref_mismatch && logical(get_cfg_or(cfg, "hide_relerr_on_external_mismatch", true))
    summary = clear_summary_relerr(summary);
    pf_ref_relerr = NaN;
    pf_ref_relerr_label = "N/A";
    fprintf("Warning: pf_ref_external appears inconsistent with current model (%s=%.6e, rel.diff=%.2f%%). rel.err(Pf) is hidden.\n", ...
        char(string(ext_ref_anchor_label)), ext_ref_anchor_pf, ext_ref_rel_diff_pct);
end

print_summary(summary, cfg, pf_mcs_ref, cov_mcs_ref, pf_ref_relerr, pf_ref_relerr_label);

results = struct();
results.cfg = cfg;
results.problem = prob;
results.svm_runs = svm_runs;
results.afosm_runs = afosm_runs;
results.ga_runs = ga_runs;
results.summary = summary;
results.reference_mcs = struct("pf", pf_mcs_ref, "beta", beta_mcs_ref, ...
    "cov", cov_mcs_ref, "time_sec", time_mcs_ref, "n_samples", cfg.n_mcs_ref_once);
results.reference_pf_relerr = struct("pf", pf_ref_relerr, "label", string(pf_ref_relerr_label));
results.reference_check = struct( ...
    "external_mismatch", ext_ref_mismatch, ...
    "external_rel_diff_pct", ext_ref_rel_diff_pct, ...
    "anchor_pf", ext_ref_anchor_pf, ...
    "anchor_label", string(ext_ref_anchor_label));

if cfg.save_results
    root_dir = fileparts(mfilename("fullpath"));
    if isempty(root_dir)
        root_dir = pwd;
    end
    out_dir = fullfile(root_dir, cfg.output_folder);
    if ~exist(out_dir, "dir")
        mkdir(out_dir);
    end
    save_file = fullfile(out_dir, cfg.result_mat_name);
    save(save_file, "results", "-v7.3");
    fprintf("Saved results: %s\n", save_file);
end

end



