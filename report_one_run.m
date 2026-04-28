function report_one_run(run_svm, run_af, run_ga, cfg)
fprintf("  AFOSM(DI)-SVR: beta=%.4f, Pf_beta=%.6e, Ncall=%d, time=%.2fs", ...
    run_svm.beta, run_svm.pf_beta, run_svm.ncall_search, run_svm.time_sec);
if isfield(run_svm, "call_breakdown") && isstruct(run_svm.call_breakdown)
    cb = run_svm.call_breakdown;
    c_core = get_struct_or(cb, "core", NaN);
    c_ref = get_struct_or(cb, "refine", NaN);
    c_hl = get_struct_or(cb, "hl", NaN);
    if isfinite(c_core) || isfinite(c_ref) || isfinite(c_hl)
        if ~isfinite(c_core), c_core = 0; end
        if ~isfinite(c_ref), c_ref = 0; end
        if ~isfinite(c_hl), c_hl = 0; end
        fprintf(" (core=%d, refine=%d, hl=%d)", round(c_core), round(c_ref), round(c_hl));
    end
end
if cfg.run_is_eval && isfinite(run_svm.pf_is)
    fprintf(", Pf_IS=%.6e, CoV_IS=%.4f", run_svm.pf_is, run_svm.cov_is);
end
fprintf("\n");

if cfg.run_classic_afosm
    fprintf("  AFOSM(DI): beta=%.4f, Pf_beta=%.6e, Ncall=%d, time=%.2fs", ...
        run_af.beta, run_af.pf_beta, run_af.ncall_search, run_af.time_sec);
    if cfg.run_is_eval && isfinite(run_af.pf_is)
        fprintf(", Pf_IS=%.6e, CoV_IS=%.4f", run_af.pf_is, run_af.cov_is);
    end
    fprintf("\n");
end

if cfg.run_ga
    fprintf("  GA       : beta=%.4f, Pf_beta=%.6e, Ncall=%d, time=%.2fs", ...
        run_ga.beta, run_ga.pf_beta, run_ga.ncall_search, run_ga.time_sec);
    if cfg.run_is_eval && isfinite(run_ga.pf_is)
        fprintf(", Pf_IS=%.6e, CoV_IS=%.4f", run_ga.pf_is, run_ga.cov_is);
    end
    fprintf("\n");
end
fprintf("\n");
end


