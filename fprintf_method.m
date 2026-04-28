function fprintf_method(name, s, pf_tag, cov_tag, cfg)
fprintf("%-10s beta=%.4f +/- %.4f, %s=%.6e +/- %.2e, %s=%.4f +/- %.4f\n", ...
    name, s.beta_mean, s.beta_std, pf_tag, s.pf_mean, s.pf_std, cov_tag, s.cov_mean, s.cov_std);
fprintf("%-10s Ncall_search=%.1f +/- %.1f, Ncall_IS=%.1f +/- %.1f, time=%.2fs +/- %.2fs", ...
    "", s.calls_search_mean, s.calls_search_std, s.calls_is_mean, s.calls_is_std, s.time_mean, s.time_std);
if cfg.report_equivalent_time
    fprintf(", EqFEMTime=%.2fs +/- %.2fs", s.eq_search_time_mean, s.eq_search_time_std);
end
if isfinite(s.rel_err_mean)
    fprintf(", rel.err(Pf)=%.2f%% +/- %.2f%%", s.rel_err_mean, s.rel_err_std);
else
    fprintf(", rel.err(Pf)=N/A");
end
fprintf("\n");
end


