function print_summary(summary, cfg, pf_mcs_ref, cov_mcs_ref, pf_relerr_ref, pf_relerr_label)
fprintf("========== Summary Over Runs ==========\n");
if cfg.report_equivalent_time
    fprintf("EqFEMTime assumption: one true-LSF call costs %.3fs.\n", cfg.true_lsf_eval_cost_sec);
end
if cfg.run_is_eval
    pf_tag = 'Pf_IS';
    cov_tag = 'CoV_IS';
else
    pf_tag = 'Pf_beta';
    cov_tag = 'CoV_beta';
end

fprintf_method("AFOSM(DI)-SVR", summary.svm, pf_tag, cov_tag, cfg);
if cfg.run_classic_afosm
    fprintf_method("AFOSM(DI)", summary.afosm, pf_tag, cov_tag, cfg);
end
if cfg.run_ga
    fprintf_method("GA", summary.ga, pf_tag, cov_tag, cfg);
end

if isfinite(pf_relerr_ref)
    fprintf("Pf relative-error mean reference: %s (Pf_ref=%.6e)\n", char(string(pf_relerr_label)), pf_relerr_ref);
else
    fprintf("Pf relative-error mean reference: N/A (no valid Pf reference)\n");
end

if isfinite(pf_mcs_ref)
    beta_mcs = -norminv(min(max(pf_mcs_ref, realmin), 1 - realmin));
    fprintf("MCS reference: Pf=%.6e, beta=%.4f, CoV=%.4f\n", pf_mcs_ref, beta_mcs, cov_mcs_ref);
elseif isfield(cfg, "pf_ref_external") && isfield(cfg, "beta_ref_external") && ...
        isnumeric(cfg.pf_ref_external) && isscalar(cfg.pf_ref_external) && isfinite(cfg.pf_ref_external) && ...
        isnumeric(cfg.beta_ref_external) && isscalar(cfg.beta_ref_external) && isfinite(cfg.beta_ref_external)
    fprintf("External reference: Pf=%.6e, beta=%.4f (%s)\n", ...
        cfg.pf_ref_external, cfg.beta_ref_external, char(string(get_cfg_or(cfg, "pf_ref_label", "external"))));
end
print_advantage(summary, cfg, pf_relerr_ref);
print_quality_notes(summary, cfg);
fprintf("Ncall_search includes true LSF calls in design-point search only.\n");
fprintf("=======================================\n\n");
end


