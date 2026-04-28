function results = AFOSM_SVR_EX2_DI(cfg_in)
% AFOSM_SVR_EX2_DI
% AFOSM-SVR workflow for Example 2 (burst margin of a rotating annular disk).
%
% The script keeps the same three-method comparison:
% 1) AFOSM-SVR hybrid iterations
% 2) Classic AFOSM baseline
% 3) GA (or fallback) design-point benchmark
% It now also supports SVR backend comparison: UQLab-SVR vs Matlab fitrsvm-SVR.
% It is dimension-agnostic and supports this 6D non-Gaussian example.

clc;
close all;

cfg = default_config();
if nargin >= 1 && isstruct(cfg_in)
    cfg = merge_cfg(cfg, cfg_in);
end
svr_backends = resolve_svr_backends(cfg);
if ~get_cfg_or(cfg, "reproducible", true)
    rng("shuffle");
    cfg.master_seed = randi([1, 2^31 - 1], 1, 1);
end
check_required_functions(cfg, svr_backends);
prob = build_problem(cfg);

root_dir = fileparts(mfilename("fullpath"));
if isempty(root_dir)
    root_dir = pwd;
end
out_dir = fullfile(root_dir, cfg.output_folder);
if ~exist(out_dir, "dir")
    mkdir(out_dir);
end

set(0, "DefaultAxesFontName", "Times New Roman");
set(0, "DefaultTextFontName", "Times New Roman");
set(0, "DefaultAxesFontSize", 11);
set(0, "DefaultLineLineWidth", 1.6);
labels = method_labels();

fprintf("==== AFOSM-SVR run: Rotating Disk Example 2 ====\n");
fprintf("Dimension: %d\n", prob.Nx);
if isfield(prob, "CaseName")
    fprintf("Case name: %s\n", prob.CaseName);
end
fprintf("Output folder: %s\n\n", out_dir);
fprintf("SVR backends: %s\n", strjoin(upper(string(svr_backends)), ", "));
fprintf("Primary backend: %s\n\n", upper(svr_backends{1}));
if get_cfg_or(cfg, "reproducible", true)
    fprintf("Seed mode: reproducible, master_seed = %d\n\n", cfg.master_seed);
else
    fprintf("Seed mode: shuffled, master_seed = %d\n\n", cfg.master_seed);
end

% Reference Pf for error statistics
[pf_ref, cov_ref] = reference_mcs(prob, cfg.n_mcs_ref, cfg.master_seed + 8000, cfg.mcs_chunk);
if pf_ref <= 0
    beta_ref = Inf;
elseif pf_ref >= 1
    beta_ref = -Inf;
else
    beta_ref = -norminv(pf_ref);
end
fprintf("Reference MCS: Pf = %.6e, beta = %.4f, CoV = %.4f (N = %.2e)\n\n", ...
    pf_ref, beta_ref, cov_ref, cfg.n_mcs_ref);
if isfield(prob, "PfRefPaper") && isfinite(prob.PfRefPaper) && prob.PfRefPaper > 0
    err_vs_paper = abs(pf_ref - prob.PfRefPaper) / prob.PfRefPaper * 100;
    fprintf("Paper Table 4 direct MCS target: Pf = %.6e (relative diff = %.2f%%)\n\n", ...
        prob.PfRefPaper, err_vs_paper);
end
if isfield(prob, "BetaRef") && isfinite(prob.BetaRef)
    fprintf("Provided reference beta from source: %.4f\n\n", prob.BetaRef);
    if abs(beta_ref - prob.BetaRef) > 0.15
        fprintf("Warning: MCS beta (%.4f) differs from provided beta (%.4f). ", beta_ref, prob.BetaRef);
        fprintf("Please re-check the limit-state formula signs/coefficients in the source.\n\n");
    end
end

svm_runs = cell(cfg.n_runs, 1);
svm_runs_by_backend = cell(numel(svr_backends), 1);
for ib = 1:numel(svr_backends)
    svm_runs_by_backend{ib} = cell(cfg.n_runs, 1);
end
afosm_runs = cell(cfg.n_runs, 1);
ga_runs = cell(cfg.n_runs, 1);

accepted_runs = 0;
attempt_id = 0;
while accepted_runs < cfg.n_runs
    attempt_id = attempt_id + 1;
    if attempt_id > cfg.max_attempts
        error("Exceeded max attempts (%d) while enforcing %s error threshold %.2f%%.", ...
            cfg.max_attempts, labels.afosm_beta_equation, cfg.accept_rel_err_pct);
    end

    rng(cfg.master_seed + attempt_id, "twister");
    fprintf("Attempt %02d (accepted %02d/%02d)\n", attempt_id, accepted_runs, cfg.n_runs);

    svm_attempt = cell(numel(svr_backends), 1);
    err_svm_all = nan(numel(svr_backends), 1);
    for ib = 1:numel(svr_backends)
        svm_i_b = afosm_svr_hybrid(prob, cfg, pf_ref, attempt_id, svr_backends{ib});
        [pf_svm_is, cov_svm_is] = estimate_pf_is_true( ...
            prob, svm_i_b.u_final, cfg.n_is_eval, ...
            cfg.master_seed + 100000 + attempt_id + (ib - 1) * 1000);
        svm_i_b.pf_is = pf_svm_is;
        svm_i_b.cov_is = cov_svm_is;
        svm_i_b.pf_est = pf_svm_is;
        err_svm_all(ib) = abs(svm_i_b.pf_is - pf_ref) / max(pf_ref, eps) * 100;
        svm_attempt{ib} = svm_i_b;
    end
    svm_i = svm_attempt{1};
    afosm_i = afosm_classic(prob, cfg);
    ga_i = ga_design_point(prob, cfg);

    [pf_af_is, cov_af_is] = estimate_pf_is_true(prob, afosm_i.u_final, cfg.n_is_eval, cfg.master_seed + 200000 + attempt_id);
    [pf_ga_is, cov_ga_is] = estimate_pf_is_true(prob, ga_i.u_final, cfg.n_is_eval, cfg.master_seed + 300000 + attempt_id);
    afosm_i.pf_is = pf_af_is; afosm_i.cov_is = cov_af_is;
    ga_i.pf_is = pf_ga_is; ga_i.cov_is = cov_ga_is;
    afosm_i.pf_est = pf_af_is;
    ga_i.pf_est = pf_ga_is;

    err_svm = err_svm_all(1);
    err_afosm = abs(afosm_i.pf_is - pf_ref) / max(pf_ref, eps) * 100;
    err_ga = abs(ga_i.pf_is - pf_ref) / max(pf_ref, eps) * 100;

    cov_cap = get_cfg_or(cfg, "accept_cov_svm_max", Inf);
    bad_err = (~isfinite(err_svm)) || (err_svm > cfg.accept_rel_err_pct);
    bad_cov = (~isfinite(svm_i.cov_is)) || (svm_i.cov_is > cov_cap);
    if bad_err || bad_cov
        if bad_err && bad_cov
            fprintf("  Rejected attempt: %s err = %.3f%% (thr %.3f%%), CoV_IS = %.4f (cap %.4f). Re-running all methods.\n\n", ...
                labels.afosm_beta_equation, err_svm, cfg.accept_rel_err_pct, svm_i.cov_is, cov_cap);
        elseif bad_err
            fprintf("  Rejected attempt: %s err = %.3f%% > %.3f%% threshold. Re-running all methods.\n\n", ...
                labels.afosm_beta_equation, err_svm, cfg.accept_rel_err_pct);
        else
            fprintf("  Rejected attempt: %s CoV_IS = %.4f > %.4f cap. Re-running all methods.\n\n", ...
                labels.afosm_beta_equation, svm_i.cov_is, cov_cap);
        end
        continue;
    end

    accepted_runs = accepted_runs + 1;
    svm_runs{accepted_runs} = svm_i;
    for ib = 1:numel(svr_backends)
        svm_runs_by_backend{ib}{accepted_runs} = svm_attempt{ib};
    end
    afosm_runs{accepted_runs} = afosm_i;
    ga_runs{accepted_runs} = ga_i;

    fprintf("  Accepted run %02d/%02d\n", accepted_runs, cfg.n_runs);
    fprintf("  %s[%s]: u*=%s, beta=%.4f, Pf_IS=%.6e, CoV_IS=%.4f, Ncall=%d", ...
        labels.afosm_beta_equation, char(upper(string(svm_i.svr_backend))), format_u_row(svm_i.u_final), ...
        svm_i.beta_final, svm_i.pf_is, svm_i.cov_is, svm_i.n_true_calls);
    if isfield(svm_i, "call_breakdown")
        cb = svm_i.call_breakdown;
        fprintf(" (init=%d, root=%d, cand=%d, add=%d)", cb.n_init, cb.n_root, cb.n_cand, cb.n_add);
    end
    fprintf(", err=%.3f%%\n", err_svm);
    if isfield(svm_i, "stop_reason")
        fprintf("           stop: %s (iter=%d, err_beta=%.3e, err_u=%.3e, tol=%.3e)\n", ...
            char(string(svm_i.stop_reason)), round(svm_i.stop_iter), svm_i.stop_err_beta, svm_i.stop_err_u, svm_i.stop_tol);
    end
    for ib = 2:numel(svr_backends)
        svm_cmp = svm_attempt{ib};
        fprintf("  %s[%s]: u*=%s, beta=%.4f, Pf_IS=%.6e, CoV_IS=%.4f, Ncall=%d", ...
            labels.afosm_beta_equation, char(upper(string(svm_cmp.svr_backend))), format_u_row(svm_cmp.u_final), ...
            svm_cmp.beta_final, svm_cmp.pf_is, svm_cmp.cov_is, svm_cmp.n_true_calls);
        if isfield(svm_cmp, "call_breakdown")
            cb = svm_cmp.call_breakdown;
            fprintf(" (init=%d, root=%d, cand=%d, add=%d)", cb.n_init, cb.n_root, cb.n_cand, cb.n_add);
        end
        fprintf(", err=%.3f%%\n", err_svm_all(ib));
        if isfield(svm_cmp, "stop_reason")
            fprintf("           stop: %s (iter=%d, err_beta=%.3e, err_u=%.3e, tol=%.3e)\n", ...
                char(string(svm_cmp.stop_reason)), round(svm_cmp.stop_iter), svm_cmp.stop_err_beta, svm_cmp.stop_err_u, svm_cmp.stop_tol);
        end
    end
    af_backend = get_afosm_backend_label(afosm_i);
    fprintf("  %s[%s]: u*=%s, beta=%.4f, Pf_IS=%.6e, CoV_IS=%.4f, Ncall=%d, err=%.3f%%\n", ...
        labels.afosm_direct_iteration, upper(af_backend), format_u_row(afosm_i.u_final), afosm_i.beta, afosm_i.pf_is, afosm_i.cov_is, afosm_i.n_true_calls, err_afosm);
    if isfield(afosm_i, "afosm_error") && strlength(string(afosm_i.afosm_error)) > 0
        fprintf("           AFOSM fallback reason: %s\n", char(string(afosm_i.afosm_error)));
    end
    fprintf("  GA       : u*=%s, beta=%.4f, Pf_IS=%.6e, CoV_IS=%.4f, Ncall=%d, err=%.3f%%\n\n", ...
        format_u_row(ga_i.u_final), ga_i.beta, ga_i.pf_is, ga_i.cov_is, ga_i.n_true_calls, err_ga);
end

[trace_mean, trace_std, trace_matrix] = aggregate_rel_error_traces(svm_runs);

summary = summarize_results(svm_runs, afosm_runs, ga_runs, pf_ref, beta_ref);
svr_backend_summary = summarize_svr_backend_runs(svm_runs_by_backend, svr_backends, pf_ref);
print_summary(summary, svr_backends{1}, labels);
if numel(svr_backends) > 1
    print_svr_backend_summary(svr_backend_summary);
end
fprintf("Acceptance filter: %s err <= %.2f%%, attempts = %d, rejected = %d\n\n", ...
    labels.afosm_beta_equation, cfg.accept_rel_err_pct, attempt_id, attempt_id - cfg.n_runs);

rep_idx = pick_representative_run(svm_runs, pf_ref);
figs = make_all_figures(prob, cfg, svm_runs, afosm_runs, ga_runs, ...
    trace_mean, trace_std, trace_matrix, summary, rep_idx, out_dir, labels);

results = struct();
results.cfg = cfg;
results.problem = prob;
results.reference = struct("pf", pf_ref, "beta", beta_ref, "cov", cov_ref);
results.svm_runs = svm_runs;
results.svr_backends = svr_backends;
results.svr_backend_runs = svm_runs_by_backend;
results.svr_backend_summary = svr_backend_summary;
results.afosm_runs = afosm_runs;
results.ga_runs = ga_runs;
results.trace_mean = trace_mean;
results.trace_std = trace_std;
results.trace_matrix = trace_matrix;
results.summary = summary;
results.representative_run_index = rep_idx;
results.figure_files = figs;
results.acceptance = struct();
results.acceptance.accept_rel_err_pct = cfg.accept_rel_err_pct;
results.acceptance.n_attempts_total = attempt_id;
results.acceptance.n_rejected = attempt_id - cfg.n_runs;

save(fullfile(out_dir, "AFOSM_SVR_EX2_DI_results.mat"), "results", "-v7.3");
fprintf("Saved data to: %s\n", fullfile(out_dir, "AFOSM_SVR_EX2_DI_results.mat"));

end



